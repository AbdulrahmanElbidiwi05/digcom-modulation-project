function plotPSD(modType, Nseg)
% PLOTPSD  Simulated PSD of the baseband equivalent signal (+ theory), f in units of 1/Tb.
    if nargin < 2, Nseg = 500; end
    Tb = 1;   Ns = 16;   fs = Ns/Tb;                 % samples per bit
    kb   = bitsPerSymbol(modType);
    Lseg = 64;                                       % symbols per segment
    Nsym = Lseg*Nseg;
    bits = randi([0 1], 1, kb*Nsym);
    isFSK = strcmpi(modType, 'BFSK');

    % ---- build the baseband waveform: one column = one symbol ----
    if isFSK
        Eb = 1;   spS = Ns;                          % samples per symbol
        t  = (0:Ns-1).'/fs;
        G  = sqrt(2*Eb/Tb) * [exp(-1j*pi*t/Tb), exp(+1j*pi*t/Tb)];
        X  = G(:, bits+1);
    else
        [s, Eb] = mapper(bits, modType);
        Ts  = kb*Tb;   spS = kb*Ns;
        p   = ones(spS, 1)/sqrt(Ts);                 % rectangular pulse
        X   = p * s;                                 % spS x Nsym
    end
    x = X(:).';                                      % samples in time order

    % ---- PSD estimate: average of periodograms ----
    L   = Lseg*spS;                                  % samples per segment
    Xs  = reshape(x, L, Nseg);
    P   = abs(fft(Xs)).^2 / (fs*L);
    Pxx = fftshift(mean(P, 2));
    df  = fs/L;
    f   = (-L/2 : L/2-1).' * df;
    fprintf('%s: signal power = %.3f, area under PSD = %.3f\n', ...
            modType, mean(abs(x).^2), sum(Pxx)*df);

    % ---- theory ----
    if isFSK
        Th = (Eb/2) * (mysinc(f*Tb + 0.5) + mysinc(f*Tb - 0.5)).^2;   % continuous part
        nn = [-4:-1, 1:4];
        Pn = (2*Eb/(pi^2*Tb)) * nn.^2 ./ (nn.^2 - 0.25).^2;           % spectral lines
        ytop = 20;
    else
        Th = (kb*Eb) * mysinc(f*Ts).^2;
        ytop = 10;
    end

    % ---- plot (normalized to Eb) ----
    figure;
    plot(f*Tb, 10*log10(Pxx/Eb), 'b', 'LineWidth', 1); hold on;
    plot(f*Tb, 10*log10(Th/Eb + 1e-12), 'r--', 'LineWidth', 1.5);
    if isFSK
        plot(nn, 10*log10(Pn/df/Eb), 'kv', 'MarkerFaceColor', 'k');
        legend('Simulation', 'Theory: continuous part', 'Theory: spectral lines');
    else
        legend('Simulation', 'Theory');
    end
    grid on; xlim([-4 4]); ylim([-40 ytop]);
    xlabel('f T_b'); ylabel('PSD / E_b  (dB)');
    title(sprintf('PSD of the baseband equivalent %s signal', modType));
end

function y = mysinc(x)
% sinc without the Signal Processing Toolbox (sin(pi x)/(pi x), equal to 1 at x = 0).
    y = sin(pi*x)./(pi*x + (x==0)) + (x==0);
end