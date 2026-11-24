function plotBER(modList, EbNo_dB, N)
% PLOTBER  BER vs Eb/No: simulation (markers) and theory (dashed) for a list of schemes.
%   plotBER({'BPSK','QPSK','8PSK','16QAM'}, 0:12, 1.2e6)
    if ischar(modList), modList = {modList}; end
    colors  = lines(numel(modList));
    markers = {'o', 's', '^', 'd', 'v', 'p'};
    names   = {};

    figure; hold on;
    for i = 1:numel(modList)
        m   = modList{i};
        sim = simBER(m, EbNo_dB, N);
        sim(sim == 0) = NaN;                    % zero errors cannot be drawn on a log axis
        semilogy(EbNo_dB, sim, markers{i}, 'Color', colors(i,:), 'LineWidth', 1.3);
        semilogy(EbNo_dB, theoryBER(m, EbNo_dB), '--', 'Color', colors(i,:), 'LineWidth', 1.2);
        names = [names, {[m ' simulation'], [m ' theory']}];
    end
    set(gca, 'YScale', 'log');
    grid on; ylim([1e-5 1]);
    xlabel('E_b/N_o (dB)'); ylabel('BER');
    title('BER vs E_b/N_o (AWGN channel)');
    legend(names, 'Location', 'southwest');
end