function ber = sim_bfsk(bits, EbN0_dB)
% OWNER: Member 3.  Team interface for the shared repo (uses common/sim_generic.m).
% bit 1 -> [1 0] (real = phi1 coordinate), bit 0 -> [0 1] (imag = phi2 coordinate)
% mean|s|^2 = 1 = k (Eb = 1).  Decision: r1 > r2 -> bit 1.
mapfn   = @(b) double(b == 1) + 1j*double(b == 0);
demapfn = @(r) double(real(r) > imag(r));
ber = sim_generic(bits, EbN0_dB, mapfn, demapfn, 1);
end