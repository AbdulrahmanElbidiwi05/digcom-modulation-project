function ber_th = theory_bfsk(EbN0_dB)
% OWNER: Member 3   (STATUS: TODO - confirm in the report)
% Coherent orthogonal BFSK: Pb = Q( sqrt(Eb/N0) )
ber_th = qfn(sqrt(10.^(EbN0_dB/10)));
end
