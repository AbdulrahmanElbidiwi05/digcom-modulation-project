function ber = sim_rayleigh(bits, EbN0_dB, mapfn, demapfn, k)
% Mapper -> Rayleigh+AWGN -> channel inversion (h known at Rx) -> Demapper -> BER
%   mapfn   : @(bits) -> symbols with mean|s|^2 = k   (Eb = 1)
%   demapfn : @(r)    -> row vector of decided bits
%   k       : bits per symbol
assert(mod(numel(bits), k) == 0, 'numel(bits) must be divisible by k = %d', k);
s  = mapfn(bits);
Es = mean(abs(s).^2);
assert(abs(Es - k) < 0.02*k, ...
    'Mapper violates Eb = 1: mean|s|^2 = %.3f, expected %d', Es, k);

ber = zeros(size(EbN0_dB));
for i = 1:numel(EbN0_dB)
    [y, h]   = rayleigh_channel(s, EbN0_dB(i));
    r        = y ./ h;                 % channel inversion
    bits_hat = demapfn(r);
    ber(i)   = calc_ber(bits, bits_hat);
end
end
