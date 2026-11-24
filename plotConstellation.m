function plotConstellation(modType, EbNo_dB, nSym)
% PLOTCONSTELLATION  Labeled ideal points (red) + noisy received samples (grey) over AWGN.
    if nargin < 3, nSym = 2000; end
    kb = bitsPerSymbol(modType);

    % ---- ideal points, with the bit label of each ----
    d       = 0:2^kb-1;                               % every possible label as a number
    lblBits = dec2bin(d, kb) - '0';                   % 2^kb x kb matrix of 0/1
    pts     = mapper(reshape(lblBits.', 1, []), modType);
    labels  = cellstr(dec2bin(d, kb));

    % ---- noisy received samples ----
    bits    = randi([0 1], 1, kb*nSym);
    [s, Eb] = mapper(bits, modType);
    r       = s + genNoise(size(s), Eb/10^(EbNo_dB/10));

    span = max([abs(real(pts)), abs(imag(pts))]);

    figure; hold on;
    plot(real(r), imag(r), '.', 'Color', [0.65 0.65 0.65]);
    plot(real(pts), imag(pts), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 7);
    text(real(pts) + 0.05*span, imag(pts) + 0.08*span, labels);
    grid on; axis equal;
    xlim(1.6*span*[-1 1]);   ylim(1.6*span*[-1 1]);
    if strcmpi(modType, 'BFSK')
        xlabel('\phi_1');  ylabel('\phi_2');
    else
        xlabel('I');       ylabel('Q');
    end
    title(sprintf('%s constellation, E_b/N_o = %g dB', modType, EbNo_dB));
end