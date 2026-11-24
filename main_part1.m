%% Project Part 1 : single-carrier modulation over AWGN
clear; clc; close all;


chosen  = '16QAM';                            % scheme used for constellation + PSD
EbNo_dB = 0:1:12;

%% 1) BER of BPSK, QPSK, 8PSK, 16QAM with theory
plotBER({'BPSK','QPSK','8PSK','16QAM'}, EbNo_dB, 1.2e6);
saveas(gcf, 'ber_all.png');

%% 2) QPSK Figure 2 vs Figure 3
plotQPSKcompare(0:1:10, 2e6);
saveas(gcf, 'ber_qpsk_compare.png');

%% 3) BFSK: BER with theory
plotBER('BFSK', EbNo_dB, 2e6);
saveas(gcf, 'ber_bfsk.png');

%% 4) BFSK: PSD
plotPSD('BFSK');
saveas(gcf, 'psd_bfsk.png');

%% 5) Chosen scheme: constellation (at 8 dB) and PSD
plotConstellation(chosen, 8);
saveas(gcf, ['const_' chosen '.png']);
plotPSD(chosen);
saveas(gcf, ['psd_' chosen '.png']);



