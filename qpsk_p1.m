%% Point 5: QPSK (Gray mapping as in Figure 2)
clear; clc; close all;

N       = 1e6;                          % number of bits 
EbNo_dB = 0:1:10;

bits = randi([0 1], 1, N);

% ---- Mapper ----
B  = reshape(bits, 2, []);              % 2 rows: row 1 = b0, row 2 = b1
b0 = B(1, :);
b1 = B(2, :);
s  = (2*b0 - 1) + 1j*(2*b1 - 1);        % I + jQ,  Eb = 1, Es = 2

Ns = length(s);                         % number of symbols = N/2
BER_sim = zeros(1, length(EbNo_dB));

for k = 1:length(EbNo_dB)
    EbNo  = 10^(EbNo_dB(k)/10);
    No    = 1/EbNo;                     % Eb = 1
    sigma = sqrt(No/2);                 % per real dimension

    % ---- AWGN channel ----
    noise = sigma * (randn(1, Ns) + 1j*randn(1, Ns));
    r     = s + noise;

    % ---- Demapper ----
    rx_b0 = real(r) > 0;
    rx_b1 = imag(r) > 0;
    rx_bits = reshape([rx_b0; rx_b1], 1, []);   

    BER_sim(k) = sum(rx_bits ~= bits) / N;
end

BER_theory = 0.5 * erfc(sqrt(10.^(EbNo_dB/10)));

% ---- BER plot ----
figure;
semilogy(EbNo_dB, BER_sim, 'bo-', 'LineWidth', 1.5); hold on;
semilogy(EbNo_dB, BER_theory, 'r--', 'LineWidth', 1.5);
grid on; ylim([1e-6 1]);
xlabel('E_b/N_o (dB)'); ylabel('BER');
title('QPSK: BER vs E_b/N_o');
legend('Simulation', 'Theory');

% ---- Constellation at one Eb/No (6 dB) ----
EbNo  = 10^(6/10);
sigma = sqrt(1/EbNo/2);
rr    = s(1:2000) + sigma*(randn(1,2000) + 1j*randn(1,2000));
figure;
plot(real(rr), imag(rr), '.'); hold on;
plot(real(s(1:2000)), imag(s(1:2000)), 'r+', 'MarkerSize', 12, 'LineWidth', 2);
grid on; axis equal;
xlabel('I'); ylabel('Q');
title('QPSK received samples at E_b/N_o = 6 dB');