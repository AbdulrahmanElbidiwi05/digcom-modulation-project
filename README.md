# Digital Communications: Modulation Project

MATLAB simulation of single-carrier and OFDM communication systems.
Cairo University, Faculty of Engineering, Electronics and Communications Dept., 3rd year.
**Deadline for all parts: 14 Dec 2026, 11:59 PM.**

| Part | Topic | Folder | Owner |
|---|---|---|---|
| 1 | Single-carrier modulation over AWGN: BPSK, QPSK, 8PSK, 16QAM, BFSK (BER, constellations, PSD) | `part1/` | Ahmed Hassan |
| 2 | BPSK, QPSK and 16QAM over a Rayleigh flat-fading channel | `part2/` | *(name)* |
| 3 | OFDM (256-point IFFT, coding, interleaver, two fading channels) | `part3/` | *(name)* |

Parts 2 and 3 do **not** re-implement the modulation. They call the shared functions in `common/`.

---

## 1. Folder layout

| Path | Contents |
|---|---|
| `common/` | Shared modem library: `mapper.m`, `demapper.m`, `genNoise.m`, `bitsPerSymbol.m`, and the test `test_modem.m` |
| `part1/` | Part 1 scripts and plotting functions: `main_part1.m`, `simBER.m`, `theoryBER.m`, `plotBER.m`, `plotQPSKcompare.m`, `plotConstellation.m`, `plotPSD.m`, `centerAxes.m` |
| `part2/` | Part 2 code (Rayleigh flat fading) |
| `part3/` | Part 3 code (OFDM) |

## 2. Requirements

- **MATLAB R2016b or newer.** The code relies on implicit expansion (for example `r - const.'`).
- **No toolboxes needed.** The code avoids `sinc`, `pwelch`, `awgn` and so on, so it also runs on a plain MATLAB installation.

## 3. Quick start

```matlab
% 1) Clone the repository and open MATLAB in the repo folder
% 2) Check that the modem library works:
cd common
test_modem                      % every line must print: loopback OK = 1

% 3) Run all of Part 1:
cd ../part1
main_part1                      % makes the figures and saves them as PNG files
```

`main_part1.m` starts with `addpath('../common')`, so it must be run from inside `part1/`.
Any script you write in `part2/` or `part3/` should start with the same line.

The BER simulations take the longest. For a quick test, lower the number of bits (last argument of `plotBER`, for example `2e5`).

---

## 4. The modem library (`common/`)

### 4.1 Supported modulations

| `modType` | Bits per symbol | Eb returned by `mapper` | Mapping |
|---|---|---|---|
| `'BPSK'` | 1 | 1 | bit 0 → -1, bit 1 → +1 |
| `'QPSK'` | 2 | 1 | b0 sets I, b1 sets Q (0 → -1, 1 → +1). Gray, as in the project figure |
| `'8PSK'` | 3 | 1/3 | Gray labels on a unit circle, as in the project figure |
| `'16QAM'` | 4 | 2.5 | (b0 b1) sets I and (b2 b3) sets Q, levels -3, -1, +1, +3 (Gray: 00, 01, 11, 10) |
| `'BFSK'` | 1 | 1 | Signal-space coordinates: bit 0 → `1`, bit 1 → `1j`. The two axes are φ1 and φ2, **not** I and Q |

### 4.2 `mapper`

```matlab
[s, Eb] = mapper(bits, modType)
```

| Argument | Meaning |
|---|---|
| `bits` | Vector of 0/1. Its length must be a multiple of the bits per symbol |
| `modType` | One of the names in the table above (not case sensitive) |
| `s` | Row vector of complex symbols |
| `Eb` | Average energy per bit of the constellation (see the table) |

### 4.3 `demapper`

```matlab
bits = demapper(r, modType)
```

Minimum-distance hard decisions. `r` is the received symbol vector, **already compensated for the channel**
and on the same scale as the output of `mapper`. BPSK uses only the real part of `r`.
The output is a row vector of 0/1.

### 4.4 `genNoise`

```matlab
n = genNoise(sz, No)
```

Complex white Gaussian noise with variance `No/2` on **each** of the real and imaginary parts.
`sz` is the output size, for example `size(s)` or `[1 N]`.

### 4.5 `bitsPerSymbol`

```matlab
kb = bitsPerSymbol(modType)
```

Returns 1, 2, 3 or 4 (see the table in 4.1).

---

## 5. Conventions (please follow them)

Most "my curve is wrong" problems come from one of these.

1. **Bits are 0/1 vectors**, and their length is a multiple of the bits per symbol.
2. **Set the noise level with `No = Eb / EbNo`**, where `Eb` is the value returned by `mapper` and `EbNo` is the **linear** ratio (`10^(EbNo_dB/10)`). Never hard-code `Eb`, because it differs per scheme.
3. **Noise is complex with variance `No/2` per dimension.** Use `genNoise`.
4. **Give `demapper` channel-compensated symbols** (for example `y ./ h` for a flat fading channel).
5. **`Eb` is the energy per bit at the mapper input.** If your system adds a repetition code or a cyclic prefix, convert to energy per *information* bit yourself before you set `No`.

## 6. Usage examples

### Part 2 pattern: Rayleigh flat fading

```matlab
addpath('../common');
N = 1e6;   EbNo_dB = 0:2:30;   mod = 'QPSK';

bits = randi([0 1], 1, N);
[s, Eb] = mapper(bits, mod);

BER = zeros(size(EbNo_dB));
for k = 1:numel(EbNo_dB)
    No = Eb / 10^(EbNo_dB(k)/10);
    h  = (randn(size(s)) + 1j*randn(size(s))) / sqrt(2);   % Rayleigh, E|h|^2 = 1
    y  = h .* s + genNoise(size(s), No);
    r  = y ./ h;                                           % channel is known at the receiver
    BER(k) = mean(demapper(r, mod) ~= bits);
end
```

### Part 3 pattern: OFDM

```matlab
X = mapper(bitsIn, '16QAM');        % frequency-domain symbols (one per subcarrier)
% ... IFFT, cyclic extension, channel, remove extension, FFT, per-subcarrier compensation ...
rxBits = demapper(Xeq, '16QAM');    % Xeq = compensated symbols after the FFT
```

---

## 7. Part 1 functions (`part1/`)

| Function | What it does |
|---|---|
| `simBER(modType, EbNo_dB, N)` | Simulated BER over AWGN for one scheme. Returns a vector with one value per Eb/No |
| `theoryBER(modType, EbNo_dB)` | Theoretical BER (exact for BPSK, QPSK, BFSK; tight Gray-coded approximation for 8PSK and 16QAM) |
| `plotBER(modList, EbNo_dB, N)` | BER vs Eb/No, simulation (markers) and theory (dashed). `modList` is a cell array, for example `{'BPSK','QPSK'}`, or one name |
| `plotQPSKcompare(EbNo_dB, N)` | QPSK Figure 2 (Gray) vs Figure 3 (non-Gray) on one graph, both fed with the same noise |
| `plotConstellation(modType, EbNo_dB, nSym)` | Labeled ideal points and noisy received samples. `nSym` is optional (default 2000) |
| `plotPSD(modType, Nseg)` | Simulated PSD of the baseband equivalent signal, with theory. Frequency axis in units of 1/Tb. `Nseg` is optional (default 500) |
| `centerAxes(xName, yName)` | Moves the axes to the origin (used by the constellation plots) |
| `main_part1` | Runs everything required in the Part 1 PDF and saves the figures |

Examples:

```matlab
plotBER({'BPSK','QPSK','8PSK','16QAM'}, 0:12, 1.2e6);   % BER of the four schemes
plotBER('BFSK', 0:12, 2e6);                              % BFSK alone
plotConstellation('16QAM', 8);                           % at Eb/No = 8 dB
plotPSD('QPSK');
```

To get the constellation and PSD of another scheme, change the variable `chosen` at the top of `main_part1.m`.

### Figures produced by `main_part1`

| File | Content |
|---|---|
| `ber_all.png` | BER of BPSK, QPSK, 8PSK, 16QAM with theory |
| `ber_qpsk_compare.png` | QPSK Figure 2 vs Figure 3 |
| `ber_bfsk.png` | BFSK BER with theory |
| `psd_bfsk.png` | BFSK PSD |
| `const_<scheme>.png`, `psd_<scheme>.png` | Constellation and PSD of the chosen scheme |

---

## 8. Testing

`common/test_modem.m` sends random bits through `mapper` and then `demapper` with **no noise** and checks:

- the bits come back unchanged (`loopback OK = 1`),
- the `Eb` returned by `mapper` equals the measured energy per bit (1, 1, 0.333, 2.5, 1 for BPSK, QPSK, 8PSK, 16QAM, BFSK).

Run it after **every** change to `common/`.

## 9. Adding a new modulation

1. Add a `case` to `mapper.m` (symbols and `Eb`).
2. Add the matching `case` to `demapper.m`.
3. Add it to `bitsPerSymbol.m`.
4. Add its theory formula to `part1/theoryBER.m` if it applies to AWGN.
5. Add it to the list in `test_modem.m` and run the test.

## 10. Common problems

| Symptom | Likely cause |
|---|---|
| BER stays near 0.5 | Wrong `No` (check convention 2) or `demapper` got symbols that were not compensated (convention 4) |
| Curve shifted left or right of theory | `Eb` hard-coded instead of taken from `mapper`, or a dB/linear mix-up |
| Error about `reshape` | Number of bits is not a multiple of the bits per symbol |
| "Undefined function mapper" | Missing `addpath('../common')` or MATLAB is open in the wrong folder |
| Points missing at high Eb/No | Zero errors cannot be drawn on a log axis. Increase the number of bits |
| Memory error in 8PSK | Reduce the number of bits `N` (the demapper builds an 8 × N distance matrix) |

## 11. Working together

- Pull before you start (`git pull`) and push small, clear commits.
- **Do not change files in `common/` without telling the others.** A change in `mapper.m` or `demapper.m` affects every part. After any change, run `test_modem` and say so in the commit message.
- Keep each part's code inside its own folder, and write repeated code as functions.
- Comment your code. The TA grades by discussion, so everyone should be able to explain the functions they call.
