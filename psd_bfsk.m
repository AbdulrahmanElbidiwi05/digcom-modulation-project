function psd_bfsk()
% OWNER: Member 3.  PSD of the BFSK baseband equivalent (fc = f1), team-repo version.
Tb = 1; Eb = 1; L = 16; Fs = L/Tb; A = sqrt(2*Eb/Tb);
bits = randi([0 1], 1, 20000);
t    = (0:L-1)'/L*Tb;
X    = zeros(L, numel(bits));
X(:, bits == 1) = repmat(A*ones(L,1), 1, sum(bits == 1));
X(:, bits == 0) = repmat(A*exp(1j*2*pi*t/Tb), 1, sum(bits == 0));
x = X(:);

Nfft = L*128; Nblk = floor(numel(x)/Nfft);
w = 0.54 - 0.46*cos(2*pi*(0:Nfft-1)'/(Nfft-1));
Pxx = zeros(Nfft,1);
for m = 1:Nblk
    Pxx = Pxx + abs(fft(x((m-1)*Nfft+1:m*Nfft) .* w)).^2;
end
Pxx = fftshift(Pxx / (Nblk*Fs*sum(w.^2)));
f   = (-Nfft/2:Nfft/2-1)' * (Fs/Nfft);

sc = @(u) sin(pi*u + eps) ./ (pi*u + eps);
G  = @(ff, d) A*Tb*sc((ff-d)*Tb) .* exp(-1j*pi*(ff-d)*Tb);
Sc = abs(G(f,0) - G(f,1/Tb)).^2 / (4*Tb);

plot(f*Tb, 10*log10(Pxx), 'LineWidth', 1.2); hold on;
plot(f*Tb, 10*log10(Sc), 'r--', 'LineWidth', 1.5);
grid on; xlim([-3 4]); ylim([-60 25]);
xlabel('Frequency \times T_b'); ylabel('PSD (dB)');
title('PSD of BFSK baseband equivalent');legend('Simulation', 'Theory (continuous part)', 'Expected line peak', 'Location', 'northeast');
end