%% Point 9: QPSK Figure 2 (Gray) vs Figure 3 (non-Gray)
clear; clc; close all;

N       = 2e6;
EbNo_dB = 0:1:10;
EbNo    = 10.^(EbNo_dB/10);
nPts    = length(EbNo_dB);

bits = randi([0 1], 1, N);

% label d = 2*b0 + b1 :   d=0 (00)   d=1 (01)   d=2 (10)   d=3 (11)
tbl2 = [-1-1j,  -1+1j,   1-1j,   1+1j];     % Figure 2 (Gray)
tbl3 = [-1-1j,  -1+1j,   1+1j,   1-1j];     % Figure 3 (non-Gray)

B  = reshape(bits, 2, []);
d  = 2*B(1,:) + B(2,:);                     % 2 bits -> number 0..3
s2 = tbl2(d+1);
s3 = tbl3(d+1);
Ns = length(d);

BER2 = zeros(1, nPts);
BER3 = zeros(1, nPts);

for k = 1:nPts
    sigma = sqrt(1/EbNo(k)/2);              % Eb = 1 for both
    noise = sigma*(randn(1,Ns) + 1j*randn(1,Ns));   % ONE noise, used twice

    r2 = s2 + noise;
    r3 = s3 + noise;

    % minimum distance demapper, using each scheme's own table
    [~, i2] = min(abs(r2 - tbl2.'), [], 1);
    [~, i3] = min(abs(r3 - tbl3.'), [], 1);
    dh2 = i2 - 1;   dh3 = i3 - 1;

    rx2 = reshape([bitget(dh2,2); bitget(dh2,1)], 1, []);
    rx3 = reshape([bitget(dh3,2); bitget(dh3,1)], 1, []);

    BER2(k) = sum(rx2 ~= bits) / N;
    BER3(k) = sum(rx3 ~= bits) / N;
end

% ---- Theory ----
p   = 0.5 * erfc(sqrt(EbNo));
Th2 = p;                                    % Gray
Th3 = 1.5*p - p.^2;                         % non-Gray

% ---- Plot ----
BER2(BER2==0) = NaN;  BER3(BER3==0) = NaN;
figure;
semilogy(EbNo_dB, BER2, 'bo', 'LineWidth', 1.3); hold on;
semilogy(EbNo_dB, BER3, 'rs', 'LineWidth', 1.3);
semilogy(EbNo_dB, Th2, 'b--', 'LineWidth', 1.2);
semilogy(EbNo_dB, Th3, 'r--', 'LineWidth', 1.2);
grid on; ylim([1e-6 1]);
xlabel('E_b/N_o (dB)'); ylabel('BER');
title('QPSK: Gray (Fig. 2) vs non-Gray (Fig. 3) labeling');
legend('Fig. 2 sim', 'Fig. 3 sim', 'Fig. 2 theory', 'Fig. 3 theory', ...
       'Location', 'southwest');
saveas(gcf, 'ber_qpsk_compare.png');

% ---- Ratio check at 4 dB ----
i4 = find(EbNo_dB == 4);
fprintf('At 4 dB:  BER(Fig.3) / BER(Fig.2) = %.3f   (theory %.3f)\n', ...
        BER3(i4)/BER2(i4), Th3(i4)/Th2(i4));