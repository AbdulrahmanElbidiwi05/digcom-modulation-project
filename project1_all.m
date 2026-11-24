%% Point 8: BPSK, QPSK, 8PSK, 16QAM on one graph
clear; clc; close all;

N       = 1.2e6;                       % divisible by 1,2,3,4 bits/symbol
EbNo_dB = 0:1:12;
EbNo    = 10.^(EbNo_dB/10);
nPts    = length(EbNo_dB);

bits = randi([0 1], 1, N);             % the same bits for all schemes

BER_bpsk = zeros(1, nPts);  BER_qpsk = zeros(1, nPts);
BER_8psk = zeros(1, nPts);  BER_16qam = zeros(1, nPts);

%% ---------- BPSK (Eb = 1) ----------
sB = 2*bits - 1;
for k = 1:nPts
    r = addNoise(sB, 1, EbNo(k));
    BER_bpsk(k) = sum((r > 0) ~= bits) / N;
end

%% ---------- QPSK (Eb = 1) ----------
B  = reshape(bits, 2, []);
sQ = (2*B(1,:) - 1) + 1j*(2*B(2,:) - 1);
for k = 1:nPts
    r  = addNoise(sQ, 1, EbNo(k));
    rx = reshape([real(r) > 0; imag(r) > 0], 1, []);
    BER_qpsk(k) = sum(rx ~= bits) / N;
end

%% ---------- 8PSK (Eb = 1/3) ----------
pos   = [0 1 3 2 7 6 4 5];
const = exp(1j*(pi/4)*pos);
B  = reshape(bits, 3, []);
s8 = const(4*B(1,:) + 2*B(2,:) + B(3,:) + 1);
for k = 1:nPts
    r = addNoise(s8, 1/3, EbNo(k));
    [~, idx] = min(abs(r - const.'), [], 1);
    dh = idx - 1;
    rx = reshape([bitget(dh,3); bitget(dh,2); bitget(dh,1)], 1, []);
    BER_8psk(k) = sum(rx ~= bits) / N;
end

%% ---------- 16QAM (Eb = 2.5) ----------
lev       = [-3 -1 3 1];
levSorted = [-3 -1 1 3];
grayDec   = [ 0  1 3 2];
B   = reshape(bits, 4, []);
s16 = lev(2*B(1,:) + B(2,:) + 1) + 1j*lev(2*B(3,:) + B(4,:) + 1);
for k = 1:nPts
    r = addNoise(s16, 2.5, EbNo(k));
    [~, iI] = min(abs(real(r) - levSorted.'), [], 1);
    [~, iQ] = min(abs(imag(r) - levSorted.'), [], 1);
    dI = grayDec(iI);  dQ = grayDec(iQ);
    rx = reshape([bitget(dI,2); bitget(dI,1); bitget(dQ,2); bitget(dQ,1)], 1, []);
    BER_16qam(k) = sum(rx ~= bits) / N;
end

%% ---------- Theory ----------
Th_bpsk = 0.5 * erfc(sqrt(EbNo));                    % also QPSK
Th_8psk = (1/3) * erfc(sqrt(3*EbNo) * sin(pi/8));
Th_16   = (3/8) * erfc(sqrt(0.4*EbNo));

%% ---------- Plot ----------
% zero errors cannot be drawn on a log axis -> hide those points
BER_bpsk(BER_bpsk==0) = NaN;   BER_qpsk(BER_qpsk==0)   = NaN;
BER_8psk(BER_8psk==0) = NaN;   BER_16qam(BER_16qam==0) = NaN;

figure;
semilogy(EbNo_dB, BER_bpsk,  'bo', 'LineWidth', 1.3); hold on;
semilogy(EbNo_dB, BER_qpsk,  'gs', 'LineWidth', 1.3);
semilogy(EbNo_dB, BER_8psk,  'm^', 'LineWidth', 1.3);
semilogy(EbNo_dB, BER_16qam, 'kd', 'LineWidth', 1.3);
semilogy(EbNo_dB, Th_bpsk, 'b--', 'LineWidth', 1.2);
semilogy(EbNo_dB, Th_8psk, 'm--', 'LineWidth', 1.2);
semilogy(EbNo_dB, Th_16,   'k--', 'LineWidth', 1.2);
grid on; ylim([1e-5 1]);
xlabel('E_b/N_o (dB)'); ylabel('BER');
title('BER vs E_b/N_o for BPSK, QPSK, 8PSK and 16QAM');
legend('BPSK sim', 'QPSK sim', '8PSK sim', '16QAM sim', ...
       'BPSK/QPSK theory', '8PSK theory (approx.)', '16QAM theory (approx.)', ...
       'Location', 'southwest');
saveas(gcf, 'ber_all.png');            % saves the figure for your report

%% ---------- Local function (must be at the END of the script) ----------
function r = addNoise(s, Eb, EbNo)
    sigma = sqrt(Eb/EbNo/2);                         % std per real dimension
    if isreal(s)
        r = s + sigma*randn(size(s));                % BPSK: real noise only
    else
        r = s + sigma*(randn(size(s)) + 1j*randn(size(s)));   % I and Q noise
    end
end