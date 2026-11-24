function kb = bitsPerSymbol(modType)
% BITSPERSYMBOL  Number of bits carried by one symbol.
    switch upper(modType)
        case {'BPSK', 'BFSK'},  kb = 1;
        case 'QPSK',            kb = 2;
        case '8PSK',            kb = 3;
        case '16QAM',           kb = 4;
        otherwise, error('Unknown modulation: %s', modType);
    end
end
