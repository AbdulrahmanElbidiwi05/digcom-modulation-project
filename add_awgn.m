function r = add_awgn(s, EbN0_dB)
% ADD_AWGN  Baseband AWGN channel.
% Convention: Eb = 1 (mapper output is normalized so mean|s|^2 = k).
%   N0 = Eb / 10^(EbN0_dB/10)
%   each real dimension has variance N0/2
% Output is complex even for real inputs (BPSK): demappers use real(r).
Eb = 1;
N0 = Eb / 10^(EbN0_dB/10);
n  = sqrt(N0/2) * (randn(size(s)) + 1j*randn(size(s)));
r  = s + n;
end
