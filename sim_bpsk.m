function ber = sim_bpsk(bits, EbN0_dB)
% REFERENCE IMPLEMENTATION - copy this pattern for every scheme.
ber = sim_generic(bits, EbN0_dB, @map_bpsk, @demap_bpsk, 1);
end
