function BER = simBER(modType, EbNo_dB, N)
% SIMBER  Monte-Carlo BER over an AWGN channel, using the common modem functions.
%   N : approximate number of bits (rounded up to a multiple of 12)
    N    = 12*ceil(N/12);                       % divisible by 1, 2, 3 and 4
    bits = randi([0 1], 1, N);
    [s, Eb] = mapper(bits, modType);

    BER = zeros(size(EbNo_dB));
    for k = 1:numel(EbNo_dB)
        No = Eb / 10^(EbNo_dB(k)/10);
        r  = s + genNoise(size(s), No);
        BER(k) = mean(demapper(r, modType) ~= bits);
    end
end