%% Point 7: 16QAM (Gray labeling as in Figure 2)
clear; clc; close all;

N       = 4e6;                          % number of bits (multiple of 4)
EbNo_dB = 0:1:12;
M = 16;  kb = log2(M);                  % 4 bits per symbol

bits = randi([0 1], 1, N);

% ---- Gray table: decimal value of 2 bits -> amplitude level ----
%  bits:  00  01  10  11   (decimal 0 1 2 3)
lev = [-3  -1   3   1];                 % lev(d+1)

% ---- Mapper ----
B  = reshape(bits, 4, []);              % rows: b0 b1 b2 b3
dI = 2*B(1,:) + B(2,:);                 % (b0 b1) as a number 0..3
dQ = 2*B(3,:) + B(4,:);                 % (b2 b3) as a number 0..3
s  = lev(dI+1) + 1j*lev(dQ+1);          % complex symbols
Ns = length(s);

Es = mean(abs(s).^2);                   % should be ~10
Eb = Es/kb;                             % ~2.5
fprintf('Measured Es = %.3f  ->  Eb = %.3f\n', Es, Eb);

% ---- Demapper tables ----
levSorted = [-3 -1 1 3];                % levels in increasing order
grayDec   = [ 0  1 3 2];                % their 2-bit labels: 00 01 11 10

BER_sim = zeros(1, length(EbNo_dB));

for k = 1:length(EbNo_dB)
    EbNo  = 10^(EbNo_dB(k)/10);
    No    = Eb/EbNo;
    sigma = sqrt(No/2);

    % ---- AWGN channel ----
    r = s + sigma*(randn(1,Ns) + 1j*randn(1,Ns));

    % ---- Demapper: nearest level on each axis ----
    [~, iI] = min(abs(real(r) - levSorted.'), [], 1);
    [~, iQ] = min(abs(imag(r) - levSorted.'), [], 1);
    dIh = grayDec(iI);                  % decided 2-bit number for I
    dQh = grayDec(iQ);                  % decided 2-bit number for Q

    rx = [bitget(dIh,2); bitget(dIh,1); bitget(dQh,2); bitget(dQh,1)];
    rx_bits = reshape(rx, 1, []);

    BER_sim(k) = sum(rx_bits ~= bits) / N;
end

% ---- Theory (Gray-coded 16QAM approximation) ----
EbNo = 10.^(EbNo_dB/10);
BER_theory = (3/8) * erfc( sqrt(0.4*EbNo) );

% ---- BER plot ----
figure;
semilogy(EbNo_dB, BER_sim, 'bo-', 'LineWidth', 1.5); hold on;
semilogy(EbNo_dB, BER_theory, 'r--', 'LineWidth', 1.5);
grid on; ylim([1e-6 1]);
xlabel('E_b/N_o (dB)'); ylabel('BER');
title('16QAM: BER vs E_b/N_o');
legend('Simulation', 'Theory (approx.)');

% ---- Constellation check with labels ----
d    = 0:15;
pts  = lev(floor(d/4)+1) + 1j*lev(mod(d,4)+1);
figure;
plot(real(pts), imag(pts), 'ro', 'MarkerFaceColor', 'r'); hold on;
text(real(pts)+0.15, imag(pts)+0.25, cellstr(dec2bin(d,4)));
grid on; axis equal; xlim([-4.5 4.5]); ylim([-4.5 4.5]);
xlabel('I'); ylabel('Q'); title('16QAM constellation (compare with Figure 2)');