%% Point 6: 8PSK (Gray labeling as in Figure 2)
clear; clc; close all;

N       = 1.5e6;                        % number of bits (multiple of 3)
EbNo_dB = 0:1:12;
M = 8;  kb = log2(M);                   % kb = 3 bits per symbol

bits = randi([0 1], 1, N);

% ---- Constellation table ----
% pos(d+1) = position (0..7, in steps of 45 deg) of the label with decimal value d
%  label: 000 001 010 011 100 101 110 111  (d = 0..7)
pos   = [ 0   1   3   2   7   6   4   5 ];
const = exp(1j*(pi/4)*pos);             % const(d+1) = point for label d

% ---- Mapper ----
B  = reshape(bits, 3, []);              % rows: b0, b1, b2
d  = 4*B(1,:) + 2*B(2,:) + B(3,:);      % 3 bits -> decimal 0..7
s  = const(d+1);                        % symbols (1 x Ns)
Ns = length(s);

Es = 1;  Eb = Es/kb;                    % Eb = 1/3
BER_sim = zeros(1, length(EbNo_dB));

for k = 1:length(EbNo_dB)
    EbNo  = 10^(EbNo_dB(k)/10);
    No    = Eb/EbNo;
    sigma = sqrt(No/2);

    % ---- AWGN channel ----
    r = s + sigma*(randn(1,Ns) + 1j*randn(1,Ns));

    % ---- Demapper: minimum distance ----
    [~, idx] = min(abs(r - const.'), [], 1);   % closest point for each r
    dh = idx - 1;                              % decided label (0..7)
    rx = [bitget(dh,3); bitget(dh,2); bitget(dh,1)];
    rx_bits = reshape(rx, 1, []);

    BER_sim(k) = sum(rx_bits ~= bits) / N;
end

% ---- Theory (Gray-coded M-PSK approximation) ----
EbNo = 10.^(EbNo_dB/10);
BER_theory = (1/3) * erfc( sqrt(3*EbNo) * sin(pi/8) );

% ---- BER plot ----
figure;
semilogy(EbNo_dB, BER_sim, 'bo-', 'LineWidth', 1.5); hold on;
semilogy(EbNo_dB, BER_theory, 'r--', 'LineWidth', 1.5);
grid on; ylim([1e-6 1]);
xlabel('E_b/N_o (dB)'); ylabel('BER');
title('8PSK: BER vs E_b/N_o');
legend('Simulation', 'Theory (approx.)');

% ---- Constellation check with labels ----
figure;
plot(real(const), imag(const), 'ro', 'MarkerFaceColor', 'r'); hold on;
text(1.12*real(const), 1.12*imag(const), cellstr(dec2bin(0:7,3)));
grid on; axis equal; xlim([-1.4 1.4]); ylim([-1.4 1.4]);
xlabel('I'); ylabel('Q'); title('8PSK constellation (compare with Figure 2)');