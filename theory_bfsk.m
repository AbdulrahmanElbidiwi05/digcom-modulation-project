%% ========================================================================
%  Digital Communications - Project Part 1 - Task 1.5: BFSK
%  Chain (Figure 1):  Data bits -> Mapper -> AWGN channel -> Demapper -> BER
%  Everything is done on the BASEBAND EQUIVALENT system (no carriers).
% ========================================================================

%% STAGE 0 : Clean start
clear; clc; close all;
rng(1);                                  % fixed seed -> same results every run

%% STAGE 1 : Parameters
Tb      = 1;                             % bit duration (normalized)
Eb      = 1;                             % energy per bit (normalized)
Nbits   = 2e6;                           % bits per Eb/No point
EbN0_dB = 0:1:12;                        % Eb/No range in dB
EbN0    = 10.^(EbN0_dB/10);              % linear scale
Q       = @(x) 0.5*erfc(x/sqrt(2));      % Q-function (no toolbox needed)

%% STAGE 2 : Theory (answers for the report questions)
% Signal set:  s_i(t) = sqrt(2Eb/Tb) cos(2*pi*f_i*t),  0<=t<=Tb,  i = 1,2
%              f_i = (nc+i)/Tb  ->  f2 - f1 = 1/Tb
%
% Basis functions:  phi_i(t) = sqrt(2/Tb) cos(2*pi*f_i*t),  0<=t<=Tb
%   unit energy : 2*f_i*Tb is an integer
%   orthogonal  : (f2-f1)*Tb = 1 and (f1+f2)*Tb = 2nc+3 are integers
%   (1/Tb is the smallest spacing that keeps the tones orthogonal for ANY
%    carrier phase; with perfect coherent detection 1/(2Tb) would also work.)
%
% Mapping:  bit 1 -> s1 = sqrt(Eb)*phi1 = [sqrt(Eb) , 0]
%           bit 0 -> s2 = sqrt(Eb)*phi2 = [0 , sqrt(Eb)]      d = sqrt(2Eb)
%
% Baseband equivalent:  s_i(t) = Re{ s_l,i(t) exp(j*2*pi*fc*t) }
%   carrier fc = f1 = (nc+1)/Tb   (a multiple of 1/Tb, so every bit can be
%   generated in local time: the carrier phase is the same at each bit start)
%   s_l,1(t) = sqrt(2Eb/Tb)                       (bit 1, f1-fc = 0)
%   s_l,2(t) = sqrt(2Eb/Tb) * exp(+j*2*pi*t/Tb)   (bit 0, f2-fc = 1/Tb)
%
% Theoretical BER (coherent BFSK):  Pb = Q( sqrt(Eb/No) )

%% STAGE 3 : Mapper -> AWGN -> Demapper -> BER
% With an orthonormal basis the correlator outputs are r = s + n, with
% n ~ N(0, No/2) in EACH dimension, so the BER can be simulated at the
% signal-vector level.
bits    = randi([0 1], 1, Nbits);        % data bits
s       = bfsk_mapper(bits, Eb);         % 2 x Nbits

BER_sim = zeros(size(EbN0_dB));
for k = 1:numel(EbN0_dB)
    r          = awgn_channel(s, Eb, EbN0_dB(k));
    bits_hat   = bfsk_demapper(r);
    BER_sim(k) = ber_calc(bits, bits_hat);
end
BER_theory = Q(sqrt(EbN0));              % BFSK theory
BER_bpsk   = Q(sqrt(2*EbN0));            % BPSK reference (for the 3 dB comment)

fprintf('\n EbN0(dB)   BER_sim      BER_theory   #errors\n');
for k = 1:numel(EbN0_dB)
    fprintf(' %6.1f    %.3e    %.3e    %d\n', EbN0_dB(k), BER_sim(k), ...
            BER_theory(k), round(BER_sim(k)*Nbits));
end

%% STAGE 4 : Plot BER vs Eb/No (simulation vs theory)
figure;
semilogy(EbN0_dB, BER_sim, 'bo-', 'LineWidth', 1.5); hold on;
semilogy(EbN0_dB, BER_theory, 'r--', 'LineWidth', 1.5);
semilogy(EbN0_dB, BER_bpsk, ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);
grid on; xlabel('E_b/N_o (dB)'); ylabel('BER');
title('BFSK (coherent) - BER vs E_b/N_o');
legend('Simulation', 'Theory  Q(\surd(E_b/N_o))', 'BPSK theory (reference)', ...
       'Location', 'southwest');
ylim([1e-6 1]);
save('BFSK_results.mat', 'EbN0_dB', 'BER_sim', 'BER_theory');

%% STAGE 5 : Received constellation at Eb/No = 6 dB
idx = 1:3000;
r6  = awgn_channel(s(:, idx), Eb, 6);
figure;
scatter(r6(1,:), r6(2,:), 6, 'filled'); hold on;
plot([sqrt(Eb) 0], [0 sqrt(Eb)], 'rx', 'MarkerSize', 12, 'LineWidth', 2);
plot([-1 2], [-1 2], 'k--');             % decision boundary r1 = r2
axis equal; grid on;
xlabel('\phi_1'); ylabel('\phi_2');
title('BFSK received constellation at E_b/N_o = 6 dB');

%% STAGE 6 : PSD of the BFSK baseband equivalent (simulation vs theory)
L      = 16;                             % samples per bit
Fs     = L/Tb;                           % sampling frequency
Nb_psd = 20000;
b_psd  = randi([0 1], 1, Nb_psd);
x      = bfsk_baseband(b_psd, Tb, Eb, L);        % complex envelope (column)

% Averaged periodogram (Welch-like, no toolbox). Absolute PSD (power/Hz).
Nfft = L*128;                            % resolution = 1/(128*Tb)
Nblk = floor(numel(x)/Nfft);
nn   = (0:Nfft-1)';
w    = 0.54 - 0.46*cos(2*pi*nn/(Nfft-1));        % Hamming window 
Pxx  = zeros(Nfft,1);
for m = 1:Nblk
    seg = x((m-1)*Nfft+1 : m*Nfft) .* w;
    Pxx = Pxx + abs(fft(seg)).^2;
end
Pxx = fftshift(Pxx / (Nblk*Fs*sum(w.^2)));
f   = (-Nfft/2 : Nfft/2-1)' * (Fs/Nfft);

% Theory: continuous part = (1/(4Tb)) |G1(f) - G2(f)|^2,
%         plus two lines (at f = 0 and f = 1/Tb), each of power A^2/4 = Eb/(2Tb)
A  = sqrt(2*Eb/Tb);
sc = @(u) sin(pi*u + eps) ./ (pi*u + eps);       % sinc without toolbox
G  = @(ff, d) A*Tb * sc((ff - d)*Tb) .* exp(-1j*pi*(ff - d)*Tb);
Sc = abs(G(f, 0) - G(f, 1/Tb)).^2 / (4*Tb);
Pk = (A^2/4) * sum(w)^2 / (Fs*sum(w.^2));        % expected line peak with this window

figure;
plot(f*Tb, 10*log10(Pxx), 'LineWidth', 1.2); hold on;
plot(f*Tb, 10*log10(Sc), 'r--', 'LineWidth', 1.5);
plot([0 1], 10*log10([Pk Pk]), 'kv', 'MarkerFaceColor', 'k');
grid on; xlim([-3 4]); ylim([-60 25]);
xlabel('Frequency \times T_b'); ylabel('PSD (dB)');
title('PSD of BFSK baseband equivalent signal (f_c = f_1)');
legend('Simulation', 'Theory (continuous part)', 'Expected line peak', ...
       'Location', 'northeast');
% Lines at f = 0 and 1/Tb = the two tones after shifting by fc = f1.
% Their height above the continuum depends on the FFT length/window.

%% ======================= LOCAL FUNCTIONS ================================
function s = bfsk_mapper(bits, Eb)
% bit 1 -> [sqrt(Eb); 0] (phi1),  bit 0 -> [0; sqrt(Eb)] (phi2)
s = sqrt(Eb) * [ (bits == 1) ; (bits == 0) ];
end

function r = awgn_channel(s, Eb, EbN0_dB)
% r = s + n,  n ~ N(0, No/2) per dimension,  No = Eb / (Eb/No)
No = Eb / 10^(EbN0_dB/10);
r  = s + sqrt(No/2) * randn(size(s));
end

function bits_hat = bfsk_demapper(r)
% Minimum distance = larger correlator output: r1 > r2 -> bit 1
bits_hat = double(r(1,:) > r(2,:));
end

function ber = ber_calc(bits, bits_hat)
ber = mean(bits ~= bits_hat);
end

function x = bfsk_baseband(bits, Tb, Eb, L)
% Complex envelope with fc = f1; each bit built in local time (fc*Tb is an integer).
t    = (0:L-1)' / L * Tb;
A    = sqrt(2*Eb/Tb);
seg1 = A * ones(L,1);                    % bit 1: f1 - fc = 0
seg0 = A * exp(1j*2*pi*t/Tb);            % bit 0: f2 - fc = 1/Tb
X    = zeros(L, numel(bits));
X(:, bits == 1) = repmat(seg1, 1, sum(bits == 1));
X(:, bits == 0) = repmat(seg0, 1, sum(bits == 0));
x    = X(:);
end