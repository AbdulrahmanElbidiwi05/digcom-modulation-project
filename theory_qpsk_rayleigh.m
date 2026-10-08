function ber_th = theory_qpsk_rayleigh(EbN0_dB)
% Gray QPSK has the same per-bit BER as BPSK (justify in report)
g = 10.^(EbN0_dB/10);
ber_th = 0.5 * (1 - sqrt(g ./ (1+g)));
end
