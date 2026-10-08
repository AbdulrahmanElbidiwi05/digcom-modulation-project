function ber_th = theory_bpsk_rayleigh(EbN0_dB)
% Pb = 0.5*(1 - sqrt(g/(1+g))),  g = average Eb/N0
g = 10.^(EbN0_dB/10);
ber_th = 0.5 * (1 - sqrt(g ./ (1+g)));
end
