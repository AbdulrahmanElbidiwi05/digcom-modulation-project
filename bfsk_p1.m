
%% Point 10A: BFSK BER (coherent detection, signal-space model)
clear; clc; close all;

N       = 2e6;
EbNo_dB = 0:1:12;
EbNo    = 10.^(EbNo_dB/10);
nPts    = length(EbNo_dB);

Eb   = 1;
bits = randi([0 1], 1, N);

% ---- Mapper: bit 0 -> [sqrt(Eb); 0],  bit 1 -> [0; sqrt(Eb)] ----
S = sqrt(Eb) * [1 - bits; bits];          % 2 x N matrix, one column per bit

BER_sim = zeros(1, nPts);

for k = 1:nPts
    No    = Eb/EbNo(k);
    sigma = sqrt(No/2);                   % per coordinate

    % ---- AWGN channel: independent noise on both coordinates ----
    R = S + sigma*randn(2, N);

    % ---- Demapper ----
    rx_bits = R(2,:) > R(1,:);            % decide 1 if r2 > r1

    BER_sim(k) = sum(rx_bits ~= bits) / N;
end

% ---- Theory ----
BER_bfsk = 0.5 * erfc(sqrt(EbNo/2));      % BFSK (orthogonal, coherent)
BER_bpsk = 0.5 * erfc(sqrt(EbNo));        % BPSK, for comparison

% ---- Plot ----
BER_sim(BER_sim==0) = NaN;
figure;
semilogy(EbNo_dB, BER_sim, 'bo', 'LineWidth', 1.3); hold on;
semilogy(EbNo_dB, BER_bfsk, 'r--', 'LineWidth', 1.3);
semilogy(EbNo_dB, BER_bpsk, 'k:', 'LineWidth', 1.3);
grid on; ylim([1e-5 1]);
xlabel('E_b/N_o (dB)'); ylabel('BER');
title('BFSK: BER vs E_b/N_o');
legend('BFSK simulation', 'BFSK theory', 'BPSK theory', 'Location', 'southwest');
saveas(gcf, 'ber_bfsk.png');


%%PSD
%% Point 10B: PSD of the BFSK baseband equivalent signal
clear all;

Eb = 1;  Tb = 1;                        % normalized units
Ns = 16;                                % samples per bit
fs = Ns/Tb;                             % sampling frequency
A  = sqrt(2*Eb/Tb);                     % pulse amplitude

Lseg = 64;                              % bits per segment
Nseg = 1000;                            % number of segments to average
Nb   = Lseg*Nseg;                       % total number of bits

bits = randi([0 1], 1, Nb);

% ---- One-bit baseband pulses (0 <= t < Tb) ----
t  = (0:Ns-1).'/fs;                     % Ns x 1 column of time instants
g1 = A*exp(-1j*pi*t/Tb);                % bit 0 : s_1l(t)
g2 = A*exp(+1j*pi*t/Tb);                % bit 1 : s_2l(t)
G  = [g1, g2];                          % Ns x 2, one pulse per column

% ---- Build the whole waveform ----
X = G(:, bits+1);                       % Ns x Nb, column n = pulse of bit n
x = X(:).';                             % row vector, samples in time order

fprintf('Average power   = %.3f  (expected 2Eb/Tb = %.3f)\n', ...
        mean(abs(x).^2), 2*Eb/Tb);

% ---- Look at the first 6 bits ----
tt = (0:6*Ns-1)/fs;
figure;
subplot(2,1,1); plot(tt/Tb, real(x(1:6*Ns)), 'LineWidth', 1.3); grid on;
ylabel('Real part'); title(['First 6 bits: ' num2str(bits(1:6))]);
subplot(2,1,2); plot(tt/Tb, imag(x(1:6*Ns)), 'LineWidth', 1.3); grid on;
ylabel('Imag part'); xlabel('t / T_b');

% ---- PSD estimate: average of periodograms ----
L   = Lseg*Ns;                          % samples per segment
Xs  = reshape(x, L, Nseg);              % each column = one segment
F   = fft(Xs);                          % FFT of every column
P   = abs(F).^2 / (fs*L);               % periodogram of every segment
Pxx = fftshift(mean(P, 2));             % average over segments, centre f = 0
df  = fs/L;                             % frequency resolution
f   = (-L/2 : L/2-1).' * df;            % frequency axis

fprintf('Power from PSD  = %.3f\n', sum(Pxx)*df);

% ---- Theory ----
mysinc = @(x) sin(pi*x)./(pi*x + (x==0)) + (x==0);   % sinc without toolbox
Cont   = (Eb/2) * ( mysinc(f*Tb + 0.5) + mysinc(f*Tb - 0.5) ).^2;

nn = [-4:-1, 1:4];                                   % line positions n/Tb
Pn = (2*Eb/(pi^2*Tb)) * nn.^2 ./ (nn.^2 - 0.25).^2;  % power in each line

fprintf('Continuous part = %.3f  (theory: half of the total power)\n', ...
        sum(Cont)*df);

% ---- Plot ----
figure;
plot(f*Tb, 10*log10(Pxx), 'b', 'LineWidth', 1); hold on;
plot(f*Tb, 10*log10(Cont + 1e-12), 'r--', 'LineWidth', 1.5);
plot(nn, 10*log10(Pn/df), 'kv', 'MarkerFaceColor', 'k');
grid on; xlim([-4 4]); ylim([-40 25]);
xlabel('f T_b   (offset from the carrier f_c)'); ylabel('PSD (dB)');
title('PSD of the BFSK baseband equivalent signal');
legend('Simulation', 'Theory: continuous part', 'Theory: spectral lines');
saveas(gcf, 'psd_bfsk.png');

