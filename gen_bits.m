function bits = gen_bits(cfg)
% GEN_BITS  Random row vector of equiprobable bits (double 0/1).
bits = randi([0 1], 1, cfg.N_BITS);
end
