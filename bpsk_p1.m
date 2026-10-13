%% Point 1: Bits and BPSK mapper
clear; clc; close all;

N = 1e6;                         % number of bits

bits = randi([0 1], 1, N);       % random bits this is row vector

symbols = 2*bits - 1;            % BPSK mapping: 0 -> -1, 1 -> +1

% --- just to check ---
disp(size(bits));                % size of the vector
disp(mean(bits));                % fraction of ones (should be ~0.5)
disp(unique(symbols));           % the distinct symbol values

% --- look at the first 20 bits and their symbols ---
figure;
subplot(2,1,1); stem(bits(1:20));    title('First 20 bits');
subplot(2,1,2); stem(symbols(1:20)); title('First 20 BPSK symbols');

%% Point 2: AWGN channel (one Eb/No value for now)
EbNo_dB = 4;                          % Eb/No in dB
EbNo    = 10^(EbNo_dB/10);            % convert to linear scale

Eb    = 1;                            % BPSK: Es = Eb = 1
No    = Eb/EbNo;                      % noise PSD
sigma = sqrt(No/2);                   % noise standard deviation

noise = sigma * randn(1, N);          % AWGN, same size as the symbols
r     = symbols + noise;              % received signal

% --- checks ---
fprintf('Eb/No (linear)        = %.4f\n', EbNo);
fprintf('Expected noise var    = %.4f\n', No/2);
fprintf('Measured noise var    = %.4f\n', var(noise));
fprintf('Measured noise mean   = %.4f\n', mean(noise));

figure;
histogram(r, 100);
title('Received signal r (Eb/No = 4 dB)');
xlabel('r'); ylabel('Count');
subplot(1,1,1); stem(r(1:20)); title('First 20 BPSK symbols received');

%% Point 3: Demapper and BER (still at one Eb/No value)
rx_bits = double(r > 0);              % decision: 1 if r>0, else 0

errors = sum(rx_bits ~= bits);        % count positions where bits differ
BER    = errors / N;                  % error rate

% --- theoretical BER for BPSK, as a check ---
BER_theory = 0.5 * erfc(sqrt(EbNo));

fprintf('Number of errors = %d out of %d bits\n', errors, N);
fprintf('Simulated   BER  = %.5f\n', BER);
fprintf('Theoretical BER  = %.5f\n', BER_theory);
figure;
subplot(1,1,1); stem(rx_bits(1:20)); title('First 20 BPSK symbols after demapper');

%% Point 4: BER curve for BPSK just point 2 and 3 again but not for only 1 value of Eb/No
EbNo_dB  = 0:1:10;                      
BER_sim = zeros(1, length(EbNo_dB));    % preallocate result vector

for k = 1:length(EbNo_dB)
    EbNo  = 10^(EbNo_dB(k)/10);         % dB -> linear
    No    = 1/EbNo;                     % Eb = 1 for BPSK
    sigma = sqrt(No/2);

    r       = symbols + sigma*randn(1, N);   % AWGN channel
    rx_bits = r > 0;                         % demapper

    BER_sim(k) = sum(rx_bits ~= bits) / N;   
end

% theoretical BPSK BER 
BER_theory = 0.5 * erfc(sqrt(10.^(EbNo_dB/10)));

% --- plot ---
figure;
semilogy(EbNo_dB, BER_sim, 'bo-', 'LineWidth', 1.5); hold on;
semilogy(EbNo_dB, BER_theory, 'r--', 'LineWidth', 1.5);
grid on;
xlabel('E_b/N_o (dB)');
ylabel('BER');
title('BPSK: BER vs E_b/N_o');
legend('Simulation', 'Theory');
ylim([1e-6 1]);