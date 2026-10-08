function bits_hat = demap_bpsk(r)
% Minimum-distance decision = sign of the real part.
bits_hat = double(real(r) > 0);
end
