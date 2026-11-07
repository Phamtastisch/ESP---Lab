%% ESP Lab 1 - Preparation: Signal Modulation by Decimation and Interpolation
% Lab group ESPL/01
%   M = L = 3, chirp 18 ... 21 kHz, length 2.5 s, f_bat = 18 kHz
%   fs (ADC, DAC) = 50 kHz, polyphases at DAC: CH0 -> lambda = 0, CH1 -> lambda = 2
%
% Requirements: Signal Processing Toolbox (chirp, spectrogram, firpmord, firpm, freqz)
%               write_coeff.m (Moodle) in the same folder
%
% Run section by section (Ctrl+Enter) or the whole script (F5).

clear; close all; clc;

%% Parameters (Table 1, ESPL/01)
fs     = 50e3;      % sampling frequency ADC and DAC [Hz]
M      = 3;         % downsampling factor
L      = 3;         % upsampling factor (M = L)
f0     = 18e3;      % chirp start frequency [Hz]
f1     = 21e3;      % chirp stop frequency [Hz]
T      = 2.5;       % chirp length [s]
f_bat  = 18e3;      % bat sound frequency [Hz]
fs_low = fs/M;      % low sampling frequency f_s' = 16.667 kHz

% identical spectrogram settings for all plots -> figures are comparable
Nwin  = 1024;       % window length (Hamming)
Nover = 762;        % overlap (75 %)
Nfft  = 1024;       % FFT length

% section for the stem plots: n = n1 ... n2 (60 samples, far from the start)
n1 = 2000;
n2 = 2059;

%% 3.1 Chirp signal x[n]
n = 0:round(T*fs)-1;            % sample index n = 0 ... 124999
t = n/fs;                        % time axis [s]
x = chirp(t, f0, T, f1);         % linear chirp, f(t) = f0 + (f1-f0)*t/T, amplitude 1

figure('Name', '3.1 Chirp x[n]');
subplot(2,1,1);
spectrogram(x, hamming(Nwin), Nover, Nfft, fs, 'yaxis');
title(sprintf('3.1  Spectrogram X[l,k]: chirp %g ... %g kHz, f_s = %g kHz', ...
      f0/1e3, f1/1e3, fs/1e3));

subplot(2,1,2);
sel = (n >= n1) & (n <= n2);     % logical index of the section
stem(n(sel), x(sel), 'filled', 'MarkerSize', 3); grid on;
xlabel('n'); ylabel('x[n]');
title(sprintf('3.1 Time Domain Signal x[n] for n = %d ... %d ', ...
      n1, n2));

%% 3.2 Downsampling by M and polyphase signals x_lambda[m] = x[m*M + lambda]
Nshow = 100;                     % first 100 samples of each polyphase
m     = 0:Nshow-1;               % low-rate index
xpoly = cell(1, M);              % xpoly{lambda+1} = x_lambda[m]

figure('Name', '3.2 Polyphase signals');
for lambda = 0:M-1
    % MATLAB indices start at 1: index 1+lambda corresponds to n = lambda,
    % step M takes every M-th sample -> n = lambda, lambda+M, lambda+2M, ...
    xpoly{lambda+1} = x(1+lambda : M : end);

    subplot(M, 1, lambda+1);
    stem(m, xpoly{lambda+1}(1:Nshow), 'filled', 'MarkerSize', 3); grid on;
    ylabel(sprintf('x_{%d}[m]', lambda));
    title(sprintf('3.2  Polyphase \\lambda = %d:  x_{%d}[m] = x[%dm + %d],  f_s'' = %.3f kHz', ...
          lambda, lambda, M, lambda, fs_low/1e3));
end


% expected aliased frequency in the low-rate domain (fold into 0 ... fs'/2)
falias = @(f) abs(f - round(f/fs_low)*fs_low);
fprintf('3.2: chirp %g ... %g kHz appears at %.3f ... %.3f kHz after downsampling\n', ...
        f0/1e3, f1/1e3, falias(f0)/1e3, falias(f1)/1e3);

%% 3.3 Upsampling of x_0[m] by L WITHOUT interpolation filter
x0 = xpoly{1};                       % polyphase lambda = 0
yu = zeros(1, L*length(x0));         % y'[n] at high rate fs
yu(1:L:end) = x0;                    % y'[nL] = x_0[n], L-1 zeros in between

figure('Name', '3.3 Upsampler output y''[n]');
subplot(2,1,1);
spectrogram(yu, hamming(Nwin), Nover, Nfft, fs, 'yaxis');
title(sprintf('3.3  Spectrogram Y''[l,k]: x_0[m] upsampled by L = %d, no interpolation filter', L));

subplot(2,1,2);
nu  = 0:length(yu)-1;
sel = (nu >= n1) & (nu <= n2);
stem(nu(sel), yu(sel), 'filled', 'MarkerSize', 3); grid on;
xlabel('n'); ylabel('y''[n]');
title(sprintf('3.3  y''[n] for n = %d ... %d  (every %d-th sample non-zero)', n1, n2, L));

% where does a bat tone f_bat appear at the DAC output?
fa    = falias(f_bat);                              % frequency in the low-rate domain
f_img = [fa + (0:L-1)*fs_low, (1:L)*fs_low - fa];   % all images k*fs' +/- fa
f_img = unique(f_img(f_img <= fs/2));               % only 0 ... fs/2 is visible
fprintf('3.3: f_bat = %g kHz -> %.3f kHz after downsampling\n', f_bat/1e3, fa/1e3);
fprintf('     upsampler output (0 ... %g kHz): %s kHz, each with amplitude 1/L = %.1f dB\n', ...
        fs/2e3, mat2str(round(f_img)/1e3), 20*log10(1/L));

%% 3.4 Interpolation (anti-imaging) filter
d_pass = 0.001;                  % pass-band ripple
d_stop = 0.001;                  % stop-band ripple (-60 dB)

% After upsampling the useful band of x_0 is 0 ... fs'/2 = fs/(2L).
% The first image starts at fs' - fs'/2 = fs/(2L) -> the stop band must start there.
f_stop = fs/(2*L);               % 8.333 kHz
f_pass = f_stop - 1e3;           % 7.333 kHz, transition width 1 kHz

[N_FIR, fo, mo, w] = firpmord([f_pass f_stop], [1 0], [d_pass d_stop], fs);
N_firpmord = N_FIR;              % order estimated by firpmord

% firpmord only ESTIMATES the order. The filter on the DSP uses 16-bit
% coefficients, so check the quantised filter and increase N if necessary.
while true
    b = L * firpm(N_FIR, fo, mo, w);     % gain L compensates the 1/L of zero insertion
    b = round(b*32768)/32768;            % Q15 quantisation exactly as on the DSP
    [H, fH] = freqz(b, 1, 2^15, fs);
    ripple  = max(abs(abs(H(fH <= f_pass))/L - 1));        % relative to gain L
    att_dB  = -20*log10(max(abs(H(fH >= f_stop)))/L);      % relative to gain L
    if ripple <= d_pass && att_dB >= -20*log10(d_stop)
        break;
    end
    N_FIR = N_FIR + 1;
end
fprintf('3.4: f_pass = %.3f kHz, f_stop = %.3f kHz\n', f_pass/1e3, f_stop/1e3);
fprintf('     firpmord order %d, final order %d (%d coefficients)\n', ...
        N_firpmord, N_FIR, length(b));
fprintf('     quantised filter: pass-band ripple %.5f, stop-band attenuation %.1f dB\n', ...
        ripple, att_dB);

figure('Name', '3.4 Interpolation filter');
plot(fH/1e3, 20*log10(abs(H)/L)); grid on; hold on;
xline(f_pass/1e3, '--', 'f_{pass}'); xline(f_stop/1e3, '--', 'f_{stop}');
yline(-60, ':', '-60 dB');
xlim([0 fs/2e3]);                % 0 ... 25 kHz
xticks(0:1:fs/2e3);              % tick every 1 kHz
xlabel('f [kHz]'); ylabel('|H(f)| / L [dB]');
title(sprintf('3.4  Interpolation filter, order %d, Q15 coefficients, gain L = %d', N_FIR, L));
ylim([-100 5]);

% apply the filter to the upsampler output
y = filter(b, 1, yu);

figure('Name', '3.4 Interpolation filter output y[n]');
subplot(2,1,1);
spectrogram(y, hamming(Nwin), Nover, Nfft, fs, 'yaxis');
title('3.4  Spectrogram Y[l,k]: after interpolation filter');

subplot(2,1,2);
% longer section than in 3.1/3.3: the 1.333 kHz output has 37.5 samples per
% period, 120 samples show about 3 periods
n2_34 = n1 + 119;
sel34 = (nu >= n1) & (nu <= n2_34);
stem(nu(sel34), y(sel34), 'filled', 'MarkerSize', 3); grid on;
xlabel('n'); ylabel('y[n]');
title(sprintf('3.4  y[n] for n = %d ... %d  (group delay %.1f samples)', n1, n2_34, N_FIR/2));

%% 3.5 Export filter coefficients to a C header file
coeff_q15 = round(b*32768);                 % integer values written by write_coeff
if any(coeff_q15 > 32767) || any(coeff_q15 < -32768)
    error('Coefficient outside 16-bit range -> reduce gain or rescale!');
end

filename = 'interp_filter_L3.h';
file_ID  = fopen(filename, 'w');
fprintf(file_ID, '//------------------------------------------- \n');
fprintf(file_ID, '// designed with -- ESP_Lab1_Prep_ESPL01.m -- \n');
fprintf(file_ID, ['// ', date, '\n']);
fprintf(file_ID, '// interpolation filter, L = %d, gain = L\n', L);
fprintf(file_ID, '// Fs = %8.2f\n', fs);
fprintf(file_ID, '// fpass = %8.2f\n', f_pass);
fprintf(file_ID, '// fstop = %8.2f\n', f_stop);
fprintf(file_ID, '// delta_pass = %6.4f\n', d_pass);
fprintf(file_ID, '// delta_stop = %6.4f (%.0f dB)\n', d_stop, 20*log10(d_stop));
fprintf(file_ID, '// N_FIR = %d (firpmord estimate %d)\n', N_FIR, N_firpmord);
fprintf(file_ID, '//------------------------------------------- \n');
fprintf(file_ID, '#define N_DELAYS_INTERP %d\n', length(b));
fprintf(file_ID, 'short H_interp_delays[N_DELAYS_INTERP]; \n');
write_coeff(file_ID, 'b_interp', b, length(b));
fclose(file_ID);

fprintf('3.5: header %s written\n', filename);
fprintf('     number of coefficients: %d\n', length(coeff_q15));
fprintf('     largest  value: %6d  (%.4f)\n', max(coeff_q15), max(coeff_q15)/32768);
fprintf('     smallest value: %6d  (%.4f)\n', min(coeff_q15), min(coeff_q15)/32768);
fprintf('     sum of coefficients (DC gain): %.4f\n', sum(b));

%% Extra: expected DAC spectra for a sine with f_bat (for lab tasks 4.2 / 4.3)
% CH0: lambda = 0, upsampled, with interpolation filter (4.3)
% CH1: lambda = 2, upsampled, without filter
xs   = 0.5*cos(2*pi*f_bat*t);              % test sine, amplitude 0.5
ch0u = zeros(1, length(xs)); ch0u(1:L:end) = xs(1:M:end);            % lambda = 0
ch1u = zeros(1, length(xs)); n_l2 = length(xs(3:M:end));
ch1u(1:L:L*n_l2) = xs(3:M:end);                                       % lambda = 2
ch0f = filter(b, 1, ch0u);

Nf  = 2^14;  win = hann(Nf)';
spec = @(s) 20*log10(abs(fft(s(end-Nf+1:end).*win))/(sum(win)/2) + eps);
fax  = (0:Nf-1)*fs/Nf;  k = fax <= fs/2;

S0u = spec(ch0u);  S0f = spec(ch0f);  S1u = spec(ch1u);

figure('Name', 'Expected DAC spectra for f_bat');
subplot(2,1,1); plot(fax(k)/1e3, S0u(k)); hold on; plot(fax(k)/1e3, S0f(k)); grid on;
legend('CH0 without filter (4.2)', 'CH0 with filter (4.3)', 'Location', 'southeast');
ylabel('dB re full scale'); ylim([-100 0]);
title(sprintf('Expected spectrum, input sine %g kHz, amplitude 0.5', f_bat/1e3));
subplot(2,1,2); plot(fax(k)/1e3, S1u(k)); grid on;
legend('CH1 (\lambda = 2), no filter', 'Location', 'southeast');
xlabel('f [kHz]'); ylabel('dB re full scale'); ylim([-100 0]);