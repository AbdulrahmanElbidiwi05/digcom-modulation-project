function ber = calc_ber(bits, bits_hat)
% CALC_BER  Fraction of bit errors.
ber = mean(bits(:) ~= bits_hat(:));
end
