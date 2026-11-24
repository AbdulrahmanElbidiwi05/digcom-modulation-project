function bits = demapper(r, modType)
% DEMAPPER  Minimum-distance hard decisions -> bits.
%   r : received symbols (already channel-compensated), same scale as mapper output
    r = r(:).';
    switch upper(modType)
        case 'BPSK'
            bits = real(r) > 0;                  % uses only the real part
        case 'QPSK'
            bits = reshape([real(r) > 0; imag(r) > 0], 1, []);
        case '8PSK'
            const = exp(1j*(pi/4)*[0 1 3 2 7 6 4 5]);
            [~, idx] = min(abs(r - const.'), [], 1);
            dh = idx - 1;
            bits = reshape([bitget(dh,3); bitget(dh,2); bitget(dh,1)], 1, []);
        case '16QAM'
            levSorted = [-3 -1 1 3];   grayDec = [0 1 3 2];
            [~, iI] = min(abs(real(r) - levSorted.'), [], 1);
            [~, iQ] = min(abs(imag(r) - levSorted.'), [], 1);
            dI = grayDec(iI);   dQ = grayDec(iQ);
            bits = reshape([bitget(dI,2); bitget(dI,1); bitget(dQ,2); bitget(dQ,1)], 1, []);
        case 'BFSK'
            bits = imag(r) > real(r);         % decide 1 if r2 > r1
        otherwise
            error('Unknown modulation: %s', modType);
    end
    bits = double(bits);
end