#!/usr/bin/env python3
"""Reproduce the notebook RG I-V and vortex-generation RG calculations."""

from __future__ import annotations

import argparse
import json
from dataclasses import asdict, dataclass
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from scipy.integrate import solve_ivp
from scipy.optimize import root_scalar


@dataclass(frozen=True)
class Parameters:
    # Fundamental constants from the notebook.
    e: float = 1.6e-19
    mu0: float = 1.25e-6
    phiq: float = 2.06e-15
    hb: float = 1.056e-34
    h: float = 6.62e-34
    c: float = 2.99e8
    kB: float = 1.38e-23
    RK: float = 25.8e3
    me: float = 9.1e-31

    # Material and RG parameters from "Scan Temperature" in the notebook.
    Bc2: float = 5.0
    rhoN: float = 7.0
    Tc: float = 7.3
    a0: float = 1.0e-9
    y0: float = 0.02
    min_J: float = 1.0e-2
    max_J: float = 1.0
    num_points: int = 30
    l_max: float = 30.0
    k0_numerators: tuple[float, ...] = (2.1, 2.2, 2.4, 2.6)

    @property
    def mu_v(self) -> float:
        return self.rhoN / (self.phiq * self.Bc2)

    @property
    def xi_v(self) -> float:
        return np.sqrt(self.phiq / (self.Bc2 * 2.0 * np.pi))

    @property
    def Dv(self) -> float:
        return self.mu_v * self.kB * self.Tc

    @property
    def q0(self) -> float:
        return self.kB * self.Tc * 2.0 / np.pi


def solve_rg_flow(KK0: float, params: Parameters):
    def rhs(_l: float, z: np.ndarray) -> list[float]:
        KKm, y = z
        return [4.0 * np.pi**3 * y**2, (2.0 - np.pi / KKm) * y]

    sol = solve_ivp(
        rhs,
        (0.0, params.l_max),
        [1.0 / KK0, params.y0],
        dense_output=True,
        rtol=1e-10,
        atol=1e-12,
        max_step=0.01,
    )
    if not sol.success:
        raise RuntimeError(f"RG ODE solve failed for KK0={KK0}: {sol.message}")

    def K(l_value: float) -> float:
        return float(1.0 / sol.sol(l_value)[0])

    def y(l_value: float) -> float:
        return float(sol.sol(l_value)[1])

    return K, y


def find_lc(J: float, KK0: float, K_func, params: Parameters) -> float:
    def force_balance(l_value: float) -> float:
        r = params.a0 * np.exp(l_value)
        epsilon_t = KK0 / K_func(l_value)
        return params.phiq * J * r * epsilon_t - 2.0 * params.q0

    # Mathematica's FindRoot starts at r=a0 and can extrapolate. A bracketed
    # solve is more deterministic, while still allowing roots outside l >= 0.
    grid = np.linspace(-20.0, params.l_max, 1001)
    values = np.array([force_balance(l_value) for l_value in grid])
    crossings = np.where(np.sign(values[:-1]) * np.sign(values[1:]) <= 0.0)[0]
    if len(crossings) == 0:
        raise RuntimeError(f"Could not bracket lc for J={J:g}, KK0={KK0:g}")

    lo = grid[crossings[0]]
    hi = grid[crossings[0] + 1]
    result = root_scalar(force_balance, bracket=(lo, hi), xtol=1e-13, rtol=1e-13)
    if not result.converged:
        raise RuntimeError(f"Root solve did not converge for J={J:g}, KK0={KK0:g}")
    return float(result.root)


def calculate_series(KK0: float, label: str, J_values: np.ndarray, params: Parameters):
    K_func, y_func = solve_rg_flow(KK0, params)
    rows = []

    for J in J_values:
        lc = find_lc(float(J), KK0, K_func, params)
        rc = params.a0 * np.exp(lc)
        K_lc = K_func(lc)
        y_lc = y_func(lc)
        Rv = 2.0 * params.Dv * (y_lc**2 / rc**4) * np.exp(2.0 * np.pi * K_lc)
        nf = np.sqrt(Rv / (2.0 * np.pi * params.Dv * K_lc))
        Eext = nf * params.mu_v * J * params.phiq**2
        rows.append((J, Eext, Rv, nf, rc, lc, K_lc, y_lc))

    dtype = [
        ("J_A_per_m", "f8"),
        ("E_V_per_m", "f8"),
        ("Rv_per_s_m2", "f8"),
        ("nf_per_m2", "f8"),
        ("rc_m", "f8"),
        ("lc", "f8"),
        ("K_lc", "f8"),
        ("y_lc", "f8"),
    ]
    return label, np.array(rows, dtype=dtype)


def write_csv(path: Path, data: np.ndarray) -> None:
    header = ",".join(data.dtype.names)
    values = np.column_stack([data[name] for name in data.dtype.names])
    np.savetxt(path, values, delimiter=",", header=header, comments="", fmt="%.16e")


def make_j_values(min_J: float, max_J: float, num_points: int, spacing: str) -> np.ndarray:
    if spacing == "log":
        return 10.0 ** np.linspace(np.log10(min_J), np.log10(max_J), num_points)
    if spacing == "linear":
        return np.linspace(min_J, max_J, num_points)
    raise ValueError(f"Unknown spacing: {spacing}")


def plot_observable(
    out_dir: Path,
    series: list[tuple[str, np.ndarray]],
    y_column: str,
    ylabel: str,
    title: str,
    basename: str,
) -> None:
    for loglog in (False, True):
        fig, ax = plt.subplots(figsize=(6.0, 4.2), dpi=150)
        for label, data in series:
            ax.plot(data["J_A_per_m"], data[y_column], marker="o", ms=3.0, lw=1.6, label=label)
        ax.set_xlabel("current density (A/m)")
        ax.set_ylabel(ylabel)
        ax.grid(True, which="both", alpha=0.25)
        ax.legend(frameon=False)
        if loglog:
            ax.set_xscale("log")
            ax.set_yscale("log")
            ax.set_title(f"{title} (log-log)")
            name = f"{basename}_loglog.png"
        else:
            ax.set_title(title)
            name = f"{basename}_linear.png"
        fig.tight_layout()
        fig.savefig(out_dir / name, dpi=300, bbox_inches="tight")
        plt.close(fig)


def plot_outputs(out_dir: Path, series: list[tuple[str, np.ndarray]]) -> None:
    plot_observable(
        out_dir=out_dir,
        series=series,
        y_column="E_V_per_m",
        ylabel="electric field (V/m)",
        title="RG I-V curve",
        basename="iv_rg",
    )
    plot_observable(
        out_dir=out_dir,
        series=series,
        y_column="Rv_per_s_m2",
        ylabel="vortex generation rate (1/s m^2)",
        title="RG vortex generation rate",
        basename="vortex_generation_rg",
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out-dir", type=Path, default=Path("rg/iv_rg_output"))
    parser.add_argument("--min-J", type=float, default=Parameters.min_J)
    parser.add_argument("--max-J", type=float, default=Parameters.max_J)
    parser.add_argument("--num-points", type=int, default=Parameters.num_points)
    parser.add_argument("--spacing", choices=("log", "linear"), default="log")
    args = parser.parse_args()

    params = Parameters()
    args.out_dir.mkdir(parents=True, exist_ok=True)
    J_values = make_j_values(args.min_J, args.max_J, args.num_points, args.spacing)

    series = []
    for i, numerator in enumerate(params.k0_numerators, start=1):
        KK0 = numerator / np.pi
        label = f"Eext{i}_KK0_{numerator:g}_over_pi"
        name, data = calculate_series(KK0, label, J_values, params)
        series.append((name, data))
        write_csv(args.out_dir / f"{name}.csv", data)

    metadata = asdict(params)
    metadata.update(
        {
            "mu_v": params.mu_v,
            "xi_v": params.xi_v,
            "Dv": params.Dv,
            "q0": params.q0,
            "run_min_J": args.min_J,
            "run_max_J": args.max_J,
            "run_num_points": args.num_points,
            "run_spacing": args.spacing,
            "J_values": J_values.tolist(),
            "columns": list(series[0][1].dtype.names),
        }
    )
    (args.out_dir / "parameters.json").write_text(json.dumps(metadata, indent=2) + "\n")

    np.savez(
        args.out_dir / "iv_rg_data.npz",
        J=J_values,
        labels=np.array([label for label, _data in series]),
        E=np.vstack([data["E_V_per_m"] for _label, data in series]),
        Rv=np.vstack([data["Rv_per_s_m2"] for _label, data in series]),
        nf=np.vstack([data["nf_per_m2"] for _label, data in series]),
        rc=np.vstack([data["rc_m"] for _label, data in series]),
    )
    plot_outputs(args.out_dir, series)

    print(f"Wrote RG results to {args.out_dir}")
    for label, data in series:
        print(
            f"{label}: "
            f"E({J_values[0]:.6g} A/m)={data['E_V_per_m'][0]:.6e} V/m, "
            f"E({J_values[-1]:.6g} A/m)={data['E_V_per_m'][-1]:.6e} V/m, "
            f"Rv({J_values[0]:.6g} A/m)={data['Rv_per_s_m2'][0]:.6e} 1/s/m^2, "
            f"Rv({J_values[-1]:.6g} A/m)={data['Rv_per_s_m2'][-1]:.6e} 1/s/m^2"
        )


if __name__ == "__main__":
    main()
