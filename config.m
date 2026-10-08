function cfg = config()
% Shared settings. Changes only via PR approved by all 3 members.
cfg.N_BITS      = 999996;     % divisible by 1,2,3,4
cfg.EbN0_dB     = 0:1:10;     % Part 1 (AWGN)
cfg.EbN0_ray_dB = 0:2:40;     % Part 2 (Rayleigh: BER falls ~1/SNR, needs high SNR)
cfg.seed        = 2026;
cfg.colors      = lines(7);
end
