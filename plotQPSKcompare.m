function plotQPSKcompare(EbNo_dB, N)
% PLOTQPSKCOMPARE  QPSK Figure 2 (Gray) vs Figure 3 (non-Gray), same noise for both.
    EbNo = 10.^(EbNo_dB/10);
    N    = 2*ceil(N/2);
    bits = randi([0 1], 1, N);
    B    = reshape(bits, 2, []);
    d    = 2*B(1,:) + B(2,:);                     % labels 00,01,10,11 -> 0..3

    tbl2 = [-1-1j, -1+1j,  1-1j,  1+1j];          % Figure 2 (Gray)
    tbl3 = [-1-1j, -1+1j,  1+1j,  1-1j];          % Figure 3 (non-Gray)
    s2 = tbl2(d+1);   s3 = tbl3(d+1);

    BER2 = zeros(size(EbNo));   BER3 = BER2;
    for k = 1:numel(EbNo)
        n = genNoise(size(s2), 1/EbNo(k));        % Eb = 1  ->  No = 1/EbNo
        BER2(k) = mean(decideBits(s2 + n, tbl2) ~= bits);
        BER3(k) = mean(decideBits(s3 + n, tbl3) ~= bits);
    end

    p   = 0.5*erfc(sqrt(EbNo));                   % error probability per axis
    Th2 = p;                                      % Gray
    Th3 = 1.5*p - p.^2;                           % non-Gray
    BER2(BER2 == 0) = NaN;   BER3(BER3 == 0) = NaN;

    figure;
    semilogy(EbNo_dB, BER2, 'bo', 'LineWidth', 1.3); hold on;
    semilogy(EbNo_dB, BER3, 'rs', 'LineWidth', 1.3);
    semilogy(EbNo_dB, Th2, 'b--', 'LineWidth', 1.2);
    semilogy(EbNo_dB, Th3, 'r--', 'LineWidth', 1.2);
    grid on; ylim([1e-6 1]);
    xlabel('E_b/N_o (dB)'); ylabel('BER');
    title('QPSK: Gray (Fig. 2) vs non-Gray (Fig. 3) labeling');
    legend('Fig. 2 sim', 'Fig. 3 sim', 'Fig. 2 theory', 'Fig. 3 theory', 'Location', 'southwest');
end

function bits = decideBits(r, tbl)
% Minimum-distance decision against a 4-point table whose position = label + 1.
    [~, idx] = min(abs(r - tbl.'), [], 1);
    dh   = idx - 1;
    bits = reshape([bitget(dh,2); bitget(dh,1)], 1, []);
end