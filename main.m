%% MAIN  Runs all simulations (Part 1 + Part 2), saves figures to results/
clear; clc; close all;
addpath(genpath(fileparts(mfilename('fullpath'))));
if ~exist('results', 'dir'), mkdir('results'); end

cfg = config();  rng(cfg.seed);  bits = gen_bits(cfg);
E1  = cfg.EbN0_dB;  E2 = cfg.EbN0_ray_dB;  c = cfg.colors;

%% ===== PART 1 (AWGN) =====
keys  = {'bpsk','qpsk','8psk','16qam'};
names = {'BPSK','QPSK','8PSK','16QAM'};
figure(1); clf;
for i = 1:4
    plot_ber(E1, feval(['sim_' keys{i}], bits, E1), ...
                 feval(['theory_' keys{i}], E1), names{i}, c(i,:));
end
title('Part 1: BER vs E_b/N_0 (AWGN)'); saveas(gcf, 'results/fig1_ber_all.png');

figure(2); clf;
plot_ber(E1, sim_qpsk(bits,E1),      theory_qpsk(E1), 'QPSK Fig. 2', c(2,:));
plot_ber(E1, sim_qpsk_fig3(bits,E1), [],              'QPSK Fig. 3', c(6,:));
title('QPSK: Fig. 2 vs Fig. 3'); saveas(gcf, 'results/fig2_qpsk.png');

figure(3); clf;
plot_ber(E1, sim_bfsk(bits,E1), theory_bfsk(E1), 'BFSK', c(5,:));
title('BFSK BER'); saveas(gcf, 'results/fig3_bfsk.png');

figure(4); clf; psd_bfsk(); saveas(gcf, 'results/fig4_bfsk_psd.png');

%% ===== PART 2 (Rayleigh flat fading) =====
figure(5); clf;
plot_ber(E2, sim_bpsk_rayleigh(bits,E2),  theory_bpsk_rayleigh(E2),  'BPSK',  c(1,:));
plot_ber(E2, sim_qpsk_rayleigh(bits,E2),  theory_qpsk_rayleigh(E2),  'QPSK',  c(2,:));
plot_ber(E2, sim_16qam_rayleigh(bits,E2), theory_16qam_rayleigh(E2), '16QAM', c(4,:));
title('Part 2: BER over Rayleigh flat fading'); saveas(gcf, 'results/fig5_rayleigh.png');

figure(6); clf;   % BPSK: AWGN vs Rayleigh
plot_ber(E2, sim_bpsk(bits,E2),          theory_bpsk(E2),          'BPSK AWGN',     c(1,:));
plot_ber(E2, sim_bpsk_rayleigh(bits,E2), theory_bpsk_rayleigh(E2), 'BPSK Rayleigh', c(6,:));
title('BPSK: AWGN vs Rayleigh'); saveas(gcf, 'results/fig6_awgn_vs_rayleigh.png');
