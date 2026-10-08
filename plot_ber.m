function plot_ber(EbN0_dB, ber_sim, ber_th, label, color)
% PLOT_BER  Adds one scheme to the current BER figure (markers = sim, dashed = theory).
% Zero-error points are dropped (log axis cannot show them).
ber_sim(ber_sim == 0) = NaN;
semilogy(EbN0_dB, ber_sim, 'o-', 'Color', color, 'LineWidth', 1.5, ...
    'DisplayName', [label ' (sim)']); hold on;
if ~isempty(ber_th)
    semilogy(EbN0_dB, ber_th, '--', 'Color', color, 'LineWidth', 1.5, ...
        'DisplayName', [label ' (theory)']);
end
grid on; xlabel('E_b/N_0 (dB)'); ylabel('BER');
ylim([1e-6 1]); legend('show', 'Location', 'southwest');
end
