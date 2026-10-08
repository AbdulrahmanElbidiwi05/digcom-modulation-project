function ber_th = theory_bpsk(EbN0_dB)
% Pb = Q(sqrt(2 Eb/N0))
ber_th = qfn(sqrt(2 * 10.^(EbN0_dB/10)));
end
