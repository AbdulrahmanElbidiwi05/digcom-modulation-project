function n = genNoise(sz, No)
% GENNOISE  Complex AWGN: variance No/2 on each of the real and imaginary parts.
%   sz : size of the output, e.g. [1 N]
    n = sqrt(No/2) * (randn(sz) + 1j*randn(sz));
end