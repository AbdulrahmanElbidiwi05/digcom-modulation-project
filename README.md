# Digital Communications - Modulation Project, Part 1

Baseband simulation of a single-carrier system (Mapper -> AWGN -> Demapper -> BER)
for BPSK, QPSK, 8PSK, 16QAM and BFSK. Cairo University, Faculty of Engineering,
Electronics and Communications Dept., 3rd year. **Due: 14 Dec 2026, 11:59 PM.**

## Team and ownership
| Member | Folder | Scope |
|---|---|---|
| Member 1 (name) | `bpsk_qpsk/`, `rayleigh/*qpsk*` | Part 1: BPSK, QPSK (Fig. 2), QPSK (Fig. 3), comparison. Part 2: QPSK over Rayleigh. Report assembly (Parts 1+2) and printing |
| Member 2 (name) | `psk8_qam16/`, `rayleigh/*16qam*` | Part 1: 8PSK, 16QAM. Part 2: 16QAM over Rayleigh (+ theory) |
| Member 3 (name) | `bfsk/`, `rayleigh/*bpsk*` | Part 1: BFSK (basis, baseband, BER, PSD). Part 2: BPSK over Rayleigh + AWGN vs Rayleigh comparison |

`common/` is shared and read-only for everyone (changes only via PR approved by all three).

## Conventions (the agreement)
- **Eb = 1.** Every mapper is normalized so `mean(abs(s).^2) = k` (bits per symbol). `sim_generic` asserts this.
- `N0 = 1/10^(EbN0_dB/10)`, noise `sqrt(N0/2)*(randn + 1j*randn)` (done in `common/add_awgn.m`).
- `N_BITS = 999996` (divisible by 1, 2, 3, 4), `EbN0_dB = 0:1:10`, `rng(2026)` - see `common/config.m`.
- Labeling follows Figure 2 / Figure 3 of the project PDF exactly.
- Interface (per scheme):
  ```matlab
  ber    = sim_xxx(bits, EbN0_dB);     % simulated BER, same length as EbN0_dB
  ber_th = theory_xxx(EbN0_dB);        % theoretical BER / tight bound
  ```
- Reference implementation: `bpsk_qpsk/sim_bpsk.m` (+ `map_bpsk`, `demap_bpsk`, `theory_bpsk`). Copy the pattern.
- Stubs return `NaN` with a warning until implemented, so `main.m` always runs.
- **Part 2 (Rayleigh):** `common/rayleigh_channel.m` + `common/sim_rayleigh.m`. New h = (hr + j hi), each N(0,1/2), for every symbol; receiver divides `y./h` (h known). Sweep: `cfg.EbN0_ray_dB = 0:2:40`. Interface: `sim_xxx_rayleigh(bits, EbN0_dB)`, `theory_xxx_rayleigh(EbN0_dB)`.
- Keep this repo **private** and never share code/report with other groups (similar reports = zero for both).
- Plotting: use `plot_ber` (semilogy, markers = simulation, dashed = theory).

## Run
In MATLAB, from the repo root: `main` (figures are saved to `results/`).

## Git workflow
1. `git pull` on `main`, then branch: `git checkout -b m1/qpsk` (`m2/...`, `m3/...`).
2. Commit small, push the branch, open a Pull Request using the template.
3. A teammate (not the author) reviews, then merges. `main` must always run.
4. Never edit another member's folder without telling them; `common/` changes need all 3 approvals.

## Report
Each member writes their section in `report/` (explanation, figure, comment; 1-2 pages).
Member 1 merges them. Hold a 20-minute walkthrough before submission: every member must be
able to explain every part.
