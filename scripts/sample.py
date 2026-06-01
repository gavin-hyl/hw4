"""
scripts/sample.py  —  Generate and compare samples (Parts 5C, 6B, 6D)
=======================================================================

Usage::
    # EM samples  (5.C.iii)
    python scripts/sample.py --method em --checkpoint runs/vp/best.pt \\
        --beta_min 0.01 --beta_max 5.0 --num_steps 1000

    # PC samples  (5.C.iv)
    python scripts/sample.py --method pc --checkpoint runs/vp/best.pt \\
        --beta_min 0.01 --beta_max 5.0 --num_steps 1000 --n_corrector 1
    python scripts/sample.py --method pc --checkpoint runs/vp/best.pt \\
        --beta_min 0.01 --beta_max 5.0 --num_steps 1000 --n_corrector 3

    # Rectified Flow Euler  (6.B)
    python scripts/sample.py --method rectflow --checkpoint runs/rectflow/best.pt \\
        --num_steps 100

    # One-step reflow  (6.C)
    python scripts/sample.py --method rectflow --checkpoint runs/rectflow_reflow/best.pt \\
        --num_steps 1

    # Side-by-side grid  (6.D): pass a fixed seed file
    python scripts/sample.py --method all --vp_checkpoint runs/vp/best.pt \\
        --rf_checkpoint runs/rectflow/best.pt \\
        --reflow_checkpoint runs/rectflow_reflow/best.pt \\
        --seed 42 --out comparison_grid.png
"""

from __future__ import annotations

import argparse
import os

import matplotlib.pyplot as plt
import torch
from torchvision.utils import make_grid

from diffusion.unet import UNet
from diffusion.vp import VPSDE
from diffusion.rectflow import RectifiedFlow


FASHION_CLASSES = [
    "T-shirt/top", "Trouser", "Pullover", "Dress", "Coat",
    "Sandal", "Shirt", "Sneaker", "Bag", "Ankle boot",
]


def save_grid(samples: torch.Tensor, path: str, nrow: int = 8, title: str = ""):
    """Save a (B,1,H,W) tensor as an image grid."""
    grid = make_grid(samples.clamp(-1, 1) * 0.5 + 0.5, nrow=nrow)
    plt.figure(figsize=(nrow, samples.size(0) // nrow + 1))
    plt.imshow(grid.permute(1, 2, 0).cpu().numpy(), cmap="gray")
    plt.title(title)
    plt.axis("off")
    plt.tight_layout()
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"Saved: {path}")


def get_args():
    p = argparse.ArgumentParser()
    p.add_argument("--method",      type=str, default="em",
                   choices=["em", "pc", "rectflow", "all"],
                   help="Sampler to run (or 'all' for side-by-side grid).")
    # VP checkpoints
    p.add_argument("--checkpoint",    type=str, default=None)
    p.add_argument("--vp_checkpoint", type=str, default=None)
    # Rect-flow checkpoints
    p.add_argument("--rf_checkpoint",     type=str, default=None)
    p.add_argument("--reflow_checkpoint", type=str, default=None)
    # VP schedule
    p.add_argument("--beta_min", type=float, default=0.01)
    p.add_argument("--beta_max", type=float, default=5.0)
    p.add_argument("--T",        type=int,   default=1000)
    # Sampler params
    p.add_argument("--num_steps",   type=int, default=1000)
    p.add_argument("--n_corrector", type=int, default=1)
    p.add_argument("--snr",         type=float, default=0.16)
    p.add_argument("--n_samples",   type=int, default=64)
    # Output
    p.add_argument("--out",    type=str, default="samples.png")
    p.add_argument("--seed",   type=int, default=0)
    p.add_argument("--device", type=str, default="cuda" if torch.cuda.is_available() else "cpu")
    return p.parse_args()


def _load_unet(checkpoint: str, device) -> UNet:
    model = UNet(in_channels=1, base_channels=64).to(device)
    model.load_state_dict(torch.load(checkpoint, map_location=device))
    model.eval()
    return model


def load_vp_model(checkpoint: str, device, beta_min=0.01, beta_max=5.0, T=1000) -> tuple[VPSDE, UNet]:
    sde = VPSDE(beta_min=beta_min, beta_max=beta_max, T=T)
    return sde, _load_unet(checkpoint, device)


def load_rf_model(checkpoint: str, device) -> tuple[RectifiedFlow, UNet]:
    return RectifiedFlow(), _load_unet(checkpoint, device)


def main():
    args = get_args()
    torch.manual_seed(args.seed)
    device = torch.device(args.device)
    shape = (args.n_samples, 1, 28, 28)
    os.makedirs(os.path.dirname(args.out) or ".", exist_ok=True)

    if args.method == "em":
        # 5.C.iii — Euler-Maruyama samples.
        sde, model = load_vp_model(args.checkpoint, device, args.beta_min, args.beta_max, args.T)
        samples = sde.euler_maruyama(model, shape, num_steps=args.num_steps, device=device)
        save_grid(samples, args.out, title=f"EM ({args.num_steps} steps)")

    elif args.method == "pc":
        # 5.C.iv — Predictor-Corrector samples.
        sde, model = load_vp_model(args.checkpoint, device, args.beta_min, args.beta_max, args.T)
        samples = sde.predictor_corrector(
            model, shape, num_steps=args.num_steps,
            n_corrector=args.n_corrector, snr=args.snr, device=device,
        )
        save_grid(samples, args.out, title=f"PC ({args.num_steps} steps, {args.n_corrector} corr.)")

    elif args.method == "rectflow":
        # 6.B / 6.C — Rectified-flow Euler ODE samples.
        flow, model = load_rf_model(args.checkpoint, device)
        samples = flow.euler_sample(model, shape, num_steps=args.num_steps, device=device)
        save_grid(samples, args.out, title=f"Rectified Flow ({args.num_steps} steps)")

    elif args.method == "all":
        # 6.D — side-by-side 4×8 grid sharing the same 8 initial-noise seeds.
        n = 8
        img_shape = (n, 1, 28, 28)
        rows, titles = [], []

        # Fix the shared initial noise X_0 once so every method starts identically.
        torch.manual_seed(args.seed)
        x0_shared = torch.randn(img_shape, device=device)

        # Row 1: DDPM EM, 1000 steps.
        sde, vp_model = load_vp_model(args.vp_checkpoint, device, args.beta_min, args.beta_max, args.T)
        rows.append(_em_from_noise(sde, vp_model, x0_shared, num_steps=1000, device=device))
        titles.append("DDPM EM (1000)")

        # Row 2: Rectified flow, 100 steps.
        flow, rf_model = load_rf_model(args.rf_checkpoint, device)
        rows.append(_rf_from_noise(flow, rf_model, x0_shared, num_steps=100, device=device))
        titles.append("Rect. Flow (100)")

        # Row 3: Rectified flow, 1 step.
        rows.append(_rf_from_noise(flow, rf_model, x0_shared, num_steps=1, device=device))
        titles.append("Rect. Flow (1)")

        # Row 4: Reflow, 1 step.
        if args.reflow_checkpoint:
            _, reflow_model = load_rf_model(args.reflow_checkpoint, device)
            rows.append(_rf_from_noise(flow, reflow_model, x0_shared, num_steps=1, device=device))
            titles.append("Reflow (1)")

        grid = torch.cat(rows, dim=0)  # (4*8, 1, 28, 28), row-major
        save_grid(grid, args.out, nrow=n, title="  |  ".join(titles))


@torch.no_grad()
def _em_from_noise(sde, model, x0, num_steps, device, eps=1e-3):
    """EM reverse-SDE starting from a *given* initial noise x0 (for fixed-seed grids)."""
    B = x0.shape[0]
    ts = torch.linspace(1.0, eps, num_steps + 1, device=device)
    x = x0 * sde.sigma(ts[:1])
    x_mean = x
    for i in range(num_steps):
        dt = ts[i] - ts[i + 1]
        t = torch.full((B,), ts[i], device=device)
        beta_t = sde.beta(t).view(-1, 1, 1, 1)
        g_t = sde.diffusion(t).view(-1, 1, 1, 1)
        score = model(x, t)
        x_mean = x + (0.5 * beta_t * x + beta_t * score) * dt
        x = x_mean + g_t * torch.sqrt(dt) * torch.randn_like(x)
    return x_mean


@torch.no_grad()
def _rf_from_noise(flow, model, x0, num_steps, device):
    """Rectified-flow Euler ODE starting from a *given* initial noise x0."""
    B = x0.shape[0]
    x = x0.clone()
    dt = 1.0 / num_steps
    for i in range(num_steps):
        t = torch.full((B,), i * dt, device=device)
        x = x + model(x, t) * dt
    return x


if __name__ == "__main__":
    main()
