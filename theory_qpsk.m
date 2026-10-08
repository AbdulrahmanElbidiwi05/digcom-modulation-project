function ber_th = theory_qpsk(EbN0_dB)
% OWNER: Member 1   (STATUS: TODO)
% Gray QPSK: Pb = Q(sqrt(2 Eb/N0))
ber_th = qfn(sqrt(2 * 10.^(EbN0_dB/10)));
end
