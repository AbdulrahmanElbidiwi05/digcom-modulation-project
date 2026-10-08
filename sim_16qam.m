function ber = sim_16qam(bits, EbN0_dB)
% OWNER: Member 2   (STATUS: TODO)
% Figure 2 labeling b0 b1 b2 b3:
%   (b0 b1) -> I : 00:-3  01:-1  11:+1  10:+3
%   (b2 b3) -> Q : 00:-3  01:-1  11:+1  10:+3
% Raw levels give Es = 10, so scale by 1/sqrt(2.5) to get Es = 4 = k (Eb = 1).
warning('sim_16qam:todo', 'sim_16qam not implemented yet - returning NaN');
ber = nan(size(EbN0_dB));
end
