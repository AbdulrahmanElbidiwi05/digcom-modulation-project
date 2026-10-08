function ber = sim_bfsk(bits, EbN0_dB)
% OWNER: Member 3   (STATUS: TODO)
% Orthogonal BFSK as a 2-D signal set (basis functions phi_1, phi_2):
%   bit 0 -> sqrt(Eb)*[1, 0]   bit 1 -> sqrt(Eb)*[0, 1]
% Represent as complex: 0 -> 1+0j, 1 -> 0+1j  (mean|s|^2 = 1 = k, Eb = 1).
% Decision: compare |real(r)| vs |imag(r)| (coherent detection).
warning('sim_bfsk:todo', 'sim_bfsk not implemented yet - returning NaN');
ber = nan(size(EbN0_dB));
end
