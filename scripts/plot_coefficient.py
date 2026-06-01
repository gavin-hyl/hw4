"""
scripts/plot_coefficient.py  —  Part 1.8
=========================================
Plot the DDPM loss coefficient
    β_t² / (2 σ_t² α_t (1 - ᾱ_t))
vs. t on a log-scale y-axis.

Usage::
    python scripts/plot_coefficient.py --T 1000 --beta_start 1e-4 --beta_end 0.02
"""

import argparse
import matplotlib.pyplot as plt
import numpy as np


def linear_schedule(T: int, beta_start: float, beta_end: float):
    return np.linspace(beta_start, beta_end, T)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--T",          type=int,   default=1000)
    parser.add_argument("--beta_start", type=float, default=1e-4)
    parser.add_argument("--beta_end",   type=float, default=0.02)
    parser.add_argument("--out",        type=str,   default="assets/1-8.png")
    args = parser.parse_args()

    # Discrete DDPM schedule (Section 4 / Eq. 7 of Ho et al. 2020).
    t = np.arange(1, args.T + 1)
    betas = linear_schedule(args.T, args.beta_start, args.beta_end)   # β_t
    alphas = 1.0 - betas                                              # α_t = 1 - β_t
    alpha_bars = np.cumprod(alphas)                                   # ᾱ_t = ∏_{s≤t} α_s
    sigma_sq = betas                                                  # σ_t² = β_t  (Eq. 7 choice)

    # Coefficient of the simplified DDPM loss:
    #   β_t² / (2 σ_t² α_t (1 - ᾱ_t))
    coeff = betas**2 / (2.0 * sigma_sq * alphas * (1.0 - alpha_bars))

    plt.figure(figsize=(8, 5))
    plt.semilogy(t, coeff, lw=2)
    plt.xlabel(r"$t$")
    plt.ylabel(r"$\dfrac{\beta_t^2}{2\sigma_t^2 \alpha_t (1-\bar\alpha_t)}$  (log scale)")
    plt.title(
        rf"DDPM loss coefficient vs $t$  "
        rf"(linear schedule, $T={args.T}$, $\sigma_t^2=\beta_t$)"
    )
    plt.grid(True, which="both", alpha=0.3)
    plt.tight_layout()
    plt.savefig(args.out, dpi=150)
    print(f"Saved: {args.out}")


if __name__ == "__main__":
    main()
