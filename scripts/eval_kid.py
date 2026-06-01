"""
scripts/eval_kid.py  —  Part 6B: KID evaluation
=================================================
Compute KID (Kernel Inception Distance) for each method and step count
to fill in the table in Problem 6.B.

Requires: pip install torch-fidelity

Usage::
    python scripts/eval_kid.py \\
        --vp_checkpoint  runs/vp/best.pt \\
        --rf_checkpoint  runs/rectflow/best.pt \\
        --beta_min 0.01 --beta_max 5.0 \\
        --n_samples 1000 --device cuda

The script prints a markdown table with KID mean ± std for each
(method, num_steps) combination.
"""

from __future__ import annotations

import argparse
import os
import tempfile

import torch
from torchvision import datasets, transforms
from torchvision.utils import save_image

try:
    import torch_fidelity
except ImportError:
    raise ImportError(
        "torch-fidelity is required. Install with: pip install torch-fidelity"
    )

from diffusion.unet import UNet
from diffusion.vp import VPSDE
from diffusion.rectflow import RectifiedFlow


STEP_COUNTS = [1, 5, 10, 50, 100, 200, 1000]
METHODS = ["rectflow", "ddim", "em"]


def get_args():
    p = argparse.ArgumentParser()
    p.add_argument("--vp_checkpoint", type=str, required=True)
    p.add_argument("--rf_checkpoint", type=str, required=True)
    p.add_argument("--beta_min",  type=float, default=0.01)
    p.add_argument("--beta_max",  type=float, default=5.0)
    p.add_argument("--T",         type=int,   default=1000)
    p.add_argument("--n_samples", type=int,   default=1000)
    p.add_argument("--device",    type=str,   default="cuda" if torch.cuda.is_available() else "cpu")
    return p.parse_args()


def save_samples_to_dir(samples: torch.Tensor, directory: str):
    """Save (B,1,H,W) samples to individual PNG files for torch-fidelity."""
    os.makedirs(directory, exist_ok=True)
    samples = (samples.clamp(-1, 1) * 0.5 + 0.5)  # [0,1]
    for i, img in enumerate(samples):
        save_image(img, os.path.join(directory, f"{i:05d}.png"))


def compute_kid(generated_dir: str, real_dir: str) -> dict:
    metrics = torch_fidelity.calculate_metrics(
        input1=generated_dir,
        input2=real_dir,
        kid=True,
        kid_subset_size=min(1000, len(os.listdir(generated_dir))),
        verbose=False,
    )
    return metrics


def load_unet(checkpoint: str, device) -> UNet:
    model = UNet(in_channels=1, base_channels=64).to(device)
    model.load_state_dict(torch.load(checkpoint, map_location=device))
    model.eval()
    return model


def prepare_real_dir(n_samples: int, device) -> str:
    """Dump n_samples real FashionMNIST test images to a temp dir for KID."""
    tf = transforms.Compose([transforms.ToTensor(), transforms.Normalize((0.5,), (0.5,))])
    ds = datasets.FashionMNIST("data", train=False, download=True, transform=tf)
    idx = torch.randperm(len(ds))[:n_samples]
    imgs = torch.stack([ds[i][0] for i in idx])  # (N,1,28,28) in [-1,1]
    real_dir = tempfile.mkdtemp(prefix="kid_real_")
    save_samples_to_dir(imgs, real_dir)
    return real_dir


@torch.no_grad()
def generate(method: str, num_steps: int, sde: VPSDE, vp_model, flow: RectifiedFlow,
             rf_model, n_samples: int, device) -> torch.Tensor:
    """Generate n_samples for a given (method, num_steps) in batches of 250."""
    out, bs = [], 250
    for start in range(0, n_samples, bs):
        b = min(bs, n_samples - start)
        shape = (b, 1, 28, 28)
        if method == "rectflow":
            out.append(flow.euler_sample(rf_model, shape, num_steps=num_steps, device=device).cpu())
        elif method == "em":
            out.append(sde.euler_maruyama(vp_model, shape, num_steps=num_steps, device=device).cpu())
        elif method == "ddim":
            out.append(ddim_sample(sde, vp_model, shape, num_steps=num_steps, device=device).cpu())
        else:
            raise ValueError(method)
    return torch.cat(out, dim=0)


@torch.no_grad()
def ddim_sample(sde: VPSDE, model, shape, num_steps, device, eps=1e-3) -> torch.Tensor:
    """Deterministic DDIM-style sampler for the VP score model.

    Uses the score → noise relation  ε̂ = -σ(t) s_θ(x,t)  and the
    probability-flow / DDIM update  x_s = c(s) x̂_0 + σ(s) ε̂  with
    x̂_0 = (x - σ(t) ε̂) / c(t).
    """
    B = shape[0]
    ts = torch.linspace(1.0, eps, num_steps + 1, device=device)
    x = torch.randn(shape, device=device) * sde.sigma(ts[:1])
    for i in range(num_steps):
        t = torch.full((B,), ts[i], device=device)
        s = torch.full((B,), ts[i + 1], device=device)
        c_t, sig_t = sde.c(t).view(-1, 1, 1, 1), sde.sigma(t).view(-1, 1, 1, 1)
        c_s, sig_s = sde.c(s).view(-1, 1, 1, 1), sde.sigma(s).view(-1, 1, 1, 1)
        eps_hat = -sig_t * model(x, t)            # predicted noise
        x0_hat = (x - sig_t * eps_hat) / c_t      # predicted clean image
        x = c_s * x0_hat + sig_s * eps_hat        # deterministic step to next level
    return x


def main():
    args = get_args()
    device = torch.device(args.device)

    sde = VPSDE(beta_min=args.beta_min, beta_max=args.beta_max, T=args.T)
    vp_model = load_unet(args.vp_checkpoint, device)
    flow = RectifiedFlow()
    rf_model = load_unet(args.rf_checkpoint, device)

    real_dir = prepare_real_dir(args.n_samples, device)

    print(f"\n| Method | Steps | KID mean | KID std |")
    print(f"|--------|-------|----------|---------|")
    for method in METHODS:
        for steps in STEP_COUNTS:
            if method == "em" and steps != 1000:
                continue  # EM baseline reported at 1000 steps only
            samples = generate(method, steps, sde, vp_model, flow, rf_model, args.n_samples, device)
            gen_dir = tempfile.mkdtemp(prefix=f"kid_{method}_{steps}_")
            save_samples_to_dir(samples, gen_dir)
            m = compute_kid(gen_dir, real_dir)
            print(f"| {method} | {steps} | {m['kernel_inception_distance_mean']:.5f} "
                  f"| {m['kernel_inception_distance_std']:.5f} |")


if __name__ == "__main__":
    main()
