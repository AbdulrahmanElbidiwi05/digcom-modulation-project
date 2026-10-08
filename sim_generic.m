function ber = sim_generic(bits, EbN0_dB, mapfn, demapfn, k)
% SIM_GENERIC  Runs Mapper -> AWGN -> Demapper -> BER for every Eb/N0.
%   mapfn   : @(bits) -> complex symbols, normalized so mean|s|^2 = k (Eb = 1)
%   demapfn : @(r)    -> row vector of decided bits (0/1)
%   k       : bits per symbol
assert(mod(numel(bits), k) == 0, 'numel(bits) must be divisible by k = %d', k);
s  = mapfn(bits);
Es = mean(abs(s).^2);
assert(abs(Es - k) < 0.02*k, ...
    'Mapper violates Eb = 1: mean|s|^2 = %.3f, expected %d', Es, k);

ber = zeros(size(EbN0_dB));
for i = 1:numel(EbN0_dB)
    r        = add_awgn(s, EbN0_dB(i));
    bits_hat = demapfn(r);
    ber(i)   = calc_ber(bits, bits_hat);
end
end
