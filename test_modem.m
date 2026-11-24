%% test_modem.m : noiseless loop-back check
for m = {'BPSK', 'QPSK', '8PSK', '16QAM'}
    mt   = m{1};
    bits = randi([0 1], 1, 12000);                 % divisible by 1, 2, 3 and 4
    [s, Eb] = mapper(bits, mt);
    kb   = length(bits)/length(s);                 % bits per symbol
    fprintf('%-6s  loopback OK = %d   Eb returned = %.3f   Eb measured = %.3f\n', ...
            mt, isequal(demapper(s, mt), bits), Eb, mean(abs(s).^2)/kb);
end