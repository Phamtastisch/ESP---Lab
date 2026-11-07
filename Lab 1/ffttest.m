%% ESP Lab 1 - Test script: FFT of the chirp at a few time instants
% Shows the amplitude spectrum of short signal sections at three points in
% time (i.e. three chirp frequencies) after each stage of the system:
%   row 1: x[n]   input chirp, fs = 50 kHz
%   row 2: x0[m]  polyphase lambda = 0 after downsampling, fs' = 16.67 kHz
%   row 3: y'[n]  after upsampling (zeros inserted), fs = 50 kHz
%   row 4: y[n]   after the interpolation filter, fs = 50 kHz
% Dashed lines mark the frequencies expected from theory.
% Standalone: needs only the Signal Processing Toolbox.

clear; close all; clc;

%% Parameters (ESPL/01)
fs     = 50e3;          % sampling frequency [Hz]
M      = 3;  L = 3;     % down-/upsampling factor
f0     = 18e3;          % chirp start frequency [Hz]
f1     = 21e3;          % chirp stop frequency [Hz]
T      = 2.5;           % chirp length [s]
fs_low = fs/M;          % f_s' = 16.667 kHz

t_check = [0.1 1.25 2.4];   % time instants to look at [s]
Nseg    = 3*1365;           % section length at fs (about 82 ms, multiple of 3)
Nfft    = 2^15;             % FFT length (zero padding -> smooth curve)

%% Signals (same processing as in the preparation script)
n  = 0:round(T*fs)-1;
t  = n/fs;
x  = chirp(t, f0, T, f1);               % input chirp
x0 = x(1:M:end);                         % polyphase lambda = 0
yu = zeros(1, L*length(x0));
yu(1:L:end) = x0;                        % upsampling: L-1 zeros in between

% interpolation filter: f_pass = 7.33 kHz, f_stop = 8.33 kHz, gain L
f_stop = fs/(2*L);  f_pass = f_stop - 1e3;
[N_FIR, fo, mo, w] = firpmord([f_pass f_stop], [1 0], [0.001 0.001], fs);
b = L * firpm(N_FIR + 4, fo, mo, w);    % +4: same order as after Q15 check (167)
b = round(b*32768)/32768;                % Q15 coefficients as on the DSP
y = filter(b, 1, yu);

%% Helper: one-sided amplitude spectrum of a section (Hann window)
% scaled so that a sine with amplitude A gives 20*log10(A) dB
ampspec = @(s, fsamp) deal( ...
    20*log10(abs(fft(s(:).' .* hann(length(s))', Nfft)) / (sum(hann(length(s)))/2) + 1e-12), ...
    (0:Nfft-1)*fsamp/Nfft);

%% Plot: rows = stages, columns = time instants
stages = {'x[n] (input)', 'x_0[m] (after \downarrow3)', 'y''[n] (after \uparrow3)', 'y[n] (after filter)'};
figure('Name', 'FFT of the chirp at three time instants', 'Position', [50 50 1400 900]);

for c = 1:numel(t_check)
    tc  = t_check(c);
    f   = f0 + (f1 - f0)*tc/T;          % instantaneous chirp frequency
    fa  = f - fs_low;                    % alias after downsampling (f is between fs' and 1.5 fs')
    n_c = round(tc*fs);                  % start index of the section at fs
    idx = n_c + (1:Nseg);                % section at fs
    idx0 = floor(n_c/M) + (1:Nseg/M);    % same time span at fs'

    sig    = {x(idx), x0(idx0), yu(idx), y(idx)};
    fsamp  = [fs, fs_low, fs, fs];
    expect = {f, fa, [fa, fs_low - fa, fs_low + fa], fa};

    for r = 1:4
        [S, fax] = ampspec(sig{r}, fsamp(r));
        k = fax <= fsamp(r)/2;
        subplot(4, numel(t_check), (r-1)*numel(t_check) + c);
        plot(fax(k)/1e3, S(k), 'LineWidth', 1); grid on; hold on;
        for fe = expect{r}
            xline(fe/1e3, '--', sprintf('%.2f', fe/1e3), ...
                'LabelVerticalAlignment', 'bottom', 'Color', [0.85 0.33 0.1]);
        end
        xlim([0 25]); xticks(0:2:24); ylim([-100 5]);
        if r == 1
            title(sprintf('t = %.2f s,  f = %.2f kHz', tc, f/1e3));
        end
        if c == 1, ylabel({stages{r}, 'Amplitude [dB]'}); end
        if r == 4, xlabel('f [kHz]'); end
    end
end
sgtitle('Amplitude spectra (0 dB = amplitude 1); dashed: expected frequencies');

%% Print expected frequencies
fprintf('t [s]   f [kHz]   f'' [kHz]   images after upsampling [kHz]\n');
for tc = t_check
    f = f0 + (f1 - f0)*tc/T;  fa = f - fs_low;
    fprintf('%4.2f    %6.2f    %6.2f     %6.2f  %6.2f  %6.2f\n', tc, f/1e3, fa/1e3, ...
        fa/1e3, (fs_low - fa)/1e3, (fs_low + fa)/1e3);
end
fprintf('expected levels: x, x0, y: 0 dB   y'': %.1f dB (factor 1/L)\n', 20*log10(1/L));