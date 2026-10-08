function ber_th = theory_8psk(EbN0_dB)
% OWNER: Member 2   (STATUS: partial - verify and justify in the report)
% Pb ~= (2/3) Q( sqrt(6 Eb/N0) sin(pi/8) )     (Gray, high SNR)
g = 10.^(EbN0_dB/10);
ber_th = (2/3) * qfn(sqrt(6*g) * sin(pi/8));
end
