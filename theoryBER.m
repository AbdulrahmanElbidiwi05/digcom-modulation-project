function P = theoryBER(modType, EbNo_dB)
% THEORYBER  Theoretical BER (exact, or tight approximation for Gray-coded 8PSK/16QAM).
    EbNo = 10.^(EbNo_dB/10);
    switch upper(modType)
        case {'BPSK', 'QPSK'}, P = 0.5*erfc(sqrt(EbNo));
        case '8PSK',           P = (1/3)*erfc(sqrt(3*EbNo)*sin(pi/8));
        case '16QAM',          P = (3/8)*erfc(sqrt(0.4*EbNo));
        case 'BFSK',           P = 0.5*erfc(sqrt(EbNo/2));
        otherwise, error('Unknown modulation: %s', modType);
    end
end