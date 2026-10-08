function ber = sim_qpsk(bits, EbN0_dB)
% OWNER: Member 1   (STATUS: TODO)
% Figure 2 labeling (b0 b1):  00 -> (-1,-1)   01 -> (-1,+1)
%                             11 -> (+1,+1)   10 -> (+1,-1)
% i.e. b0 -> I (0:-1, 1:+1), b1 -> Q (0:-1, 1:+1);  mean|s|^2 = 2 = k (Eb = 1).
% Create map_qpsk.m / demap_qpsk.m and call sim_generic(..., 2).
warning('sim_qpsk:todo', 'sim_qpsk not implemented yet - returning NaN');
ber = nan(size(EbN0_dB));
end
