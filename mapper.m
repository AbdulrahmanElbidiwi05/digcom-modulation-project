function [s, Eb] = mapper(bits, modType)
% MAPPER  Bits -> constellation symbols (Project Part 1 mappings).
%   bits    : vector of 0/1, length a multiple of the bits per symbol
%   modType : 'BPSK' | 'QPSK' | '8PSK' | '16QAM'
%   s       : row vector of complex symbols
%   Eb      : average energy per bit of this constellation
    bits = bits(:).';
    switch upper(modType)
        case 'BPSK'
            s  = 2*bits - 1;                                  Eb = 1;
        case 'QPSK'
            B  = reshape(bits, 2, []);
            s  = (2*B(1,:) - 1) + 1j*(2*B(2,:) - 1);          Eb = 1;
        case '8PSK'
            const = exp(1j*(pi/4)*[0 1 3 2 7 6 4 5]);
            B  = reshape(bits, 3, []);
            s  = const(4*B(1,:) + 2*B(2,:) + B(3,:) + 1);     Eb = 1/3;
        case '16QAM'
            lev = [-3 -1 3 1];
            B  = reshape(bits, 4, []);
            s  = lev(2*B(1,:) + B(2,:) + 1) + 1j*lev(2*B(3,:) + B(4,:) + 1);
            Eb = 2.5;
        case 'BFSK'
            s  = (1 - bits) + 1j*bits;        % bit 0 -> (1,0),  bit 1 -> (0,1)
            Eb = 1;
        otherwise
            error('Unknown modulation: %s', modType);
    end
end