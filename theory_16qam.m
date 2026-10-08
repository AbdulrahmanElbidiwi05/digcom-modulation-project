function ber_th = theory_16qam(EbN0_dB)
% OWNER: Member 2   (STATUS: partial - verify and justify in the report)
% Pb ~= (3/4) Q( sqrt(0.8 Eb/N0) )              (Gray, high SNR)
g = 10.^(EbN0_dB/10);
ber_th = 0.75 * qfn(sqrt(0.8*g));
end
