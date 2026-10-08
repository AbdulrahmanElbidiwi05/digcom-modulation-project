function [y, h] = rayleigh_channel(s, EbN0_dB)
% Flat Rayleigh fading + AWGN, baseband (symbol level), Eb = 1.
%   y = h.*s + n
%   h = hr + j*hi, each ~ N(0,1/2)  -> E|h|^2 = 1, new h for EVERY symbol
%   n = nc + j*ns, each ~ N(0,N0/2), N0 = 1/10^(EbN0_dB/10)
N0 = 1 / 10^(EbN0_dB/10);
h  = sqrt(1/2)  * (randn(size(s)) + 1j*randn(size(s)));
n  = sqrt(N0/2) * (randn(size(s)) + 1j*randn(size(s)));
y  = h .* s + n;
end
