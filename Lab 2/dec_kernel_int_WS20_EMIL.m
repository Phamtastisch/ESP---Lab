% dec_kernel_int_WS20_EMIL.m
%
% US 30-Jul-06, 06-Nov-20
%
% This version is the starter version for the MES LAB
% 
% designs a filter according to specification done in Lab assignment
%
clc
clear
close('all');
format compact
Fs = inputs('Fs',50000);

% create a frequency vector
freq=(1:999)/2000;

% stop-band attentuation is in DB, convert to linear for REMEZ
delta_stop_dB = inputs('stop-band attenuation in dB', 40);
delta_stop = dbinv(-delta_stop_dB);
% for pass-band
delta_pass = 0.01;

% edge frequencies
fpass = inputs('fpass', 2500); 
fstop = inputs('fstop', 2800); 

% determine N_FIR and the coefficients using REMEZ ("normal" FIR filter)
[N_FIR,fo,mo,w] = firpmord( [fpass fstop], [1 0], [delta_pass delta_stop], Fs );
% for safety reasons, add 2 to N_FIR to achieve the stop-band attenuation for sure
N_FIR = N_FIR + 2;
b_FIR = firpm(N_FIR,fo,mo,w);

% compute the amplitude response using frequency vector
hz = freqz(b_FIR,1, 2*pi*freq);

fprintf('\n N_FIR=%d, "normal" implementation\n\n', N_FIR);

figure; 
% lowpass filter
subplot(1,2,1);
plot(freq*2*pi,db(hz),'LineWidth',1.2),grid
title('Magnitude response of lowpass FIR filter'),
xlabel('Normalized frequency $\Omega$','Interpreter', 'latex');
ylabel('$|H(e^{j\Omega})|$ in dB','Interpreter', 'latex');
axis([0 pi -50 10]);

% highpass filter
subplot(1,2,2);
plot(freq*2*pi,db(1-abs(hz)),'LineWidth',1.2),grid
title('Magnitude response of highpass FIR filter'),
xlabel('Normalized frequency $\Omega$','Interpreter', 'latex');
ylabel('$|H(e^{j\Omega})|$ in dB','Interpreter', 'latex');
axis([0 pi -50 10]);

pause

% add here the design of the decimation/interpolation filter and of the KERNEL filter
% ---- 3.2 multirate filter design ----
% optimum factor (see roots_demo.m) and factor for the lab (Table 2)
r = roots([fstop^2-fpass^2, -(fpass+fstop)^2, 2*Fs*(fpass+fstop), -Fs^2]);
MMmin = real(r(abs(imag(r)) < 1e-6));
MM = 4;
Fs_low = Fs/MM;

% decimation / interpolation filter (at Fs), ripple 1/3 each
fpass_dec = fpass;                % 3100 Hz
fstop_dec = Fs_low - fstop;       % 12500 - 3350 = 9150 Hz
[N_FIR_Dec_Int,fo,mo,w] = firpmord([fpass_dec fstop_dec], [1 0], [delta_pass/3 delta_stop], Fs);
N_FIR_Dec_Int = N_FIR_Dec_Int + 2;
b_dec = firpm(N_FIR_Dec_Int,fo,mo,w);

% kernel filter (at Fs/M), ripple 1/3
[N_FIR_kernel_MM,fo,mo,w] = firpmord([fpass fstop], [1 0], [delta_pass/3 delta_stop], Fs_low);
N_FIR_kernel_MM = N_FIR_kernel_MM + 2;
b_kernel = firpm(N_FIR_kernel_MM,fo,mo,w);

fprintf('\n M_opt = %.4f, M = %d, N_FIR_Dec_Int = %d, N_FIR_kernel = %d\n\n', ...
        MMmin, MM, N_FIR_Dec_Int, N_FIR_kernel_MM);

% magnitude responses at Fs
f = linspace(0, Fs/2, 4000);
H_dec = freqz(b_dec, 1, f, Fs);
H_ker = freqz(b_kernel, 1, f, Fs_low);   % kernel runs at Fs/M -> periodic with Fs/M
figure;
title('Kernel filter (at f_s/M)');
plot(f/1e3, db(H_dec.*H_ker.*H_dec)), grid, axis([0 Fs/2e3 -80 10]);
title('Cascade: decimation, kernel, interpolation filter');
xlabel('f in kHz');

% decimation and kernel filter in one plot
figure;
plot(f/1e3, db(H_dec)), hold on
plot(f/1e3, db(H_ker)), grid
axis([0 Fs/2e3 -80 5]);
legend('Decimation / interpolation filter', 'Kernel filter (at f_s/M, periodic)', 'Location', 'northeast');
title('Magnitude response (dB)'); xlabel('f in kHz'); ylabel('|H| in dB');

%---------------------------------------------------------------------------
% write to file !
% create header file and info
filename = 'FIR_normal_WS20_EMIL.h';
file_ID = fopen(filename, 'w');		% generate include-file
fprintf(file_ID, '//------------------------------------------- \n');
fprintf(file_ID, '// designed with -- dec_kernel_int.m -- \n', Fs );
fprintf(file_ID, '// Fs = %6.2f\n', Fs );
fprintf(file_ID, '// fstop = %6.2f\n', fstop);
fprintf(file_ID, '// fpass = %6.2f\n', fpass);
fprintf(file_ID, '// delta_pass = %6.2f\n', delta_pass);
fprintf(file_ID, '// delta_stop_dB = %6.2f\n', delta_stop_dB);
fprintf(file_ID, '// N_FIR = %d\n',  N_FIR);
fprintf(file_ID, '//------------------------------------------- \n');

fprintf(file_ID, '#define N_delays_FIR_dki_normal %d\n', length(b_FIR));
fprintf(file_ID, '\n// DEC FILTER\n');
fprintf(file_ID, 'short H_filt_FIR_normal[N_delays_FIR_dki_normal]; \n');

write_coeff(file_ID, 'b_FIR_normal', b_FIR, length(b_FIR));
fclose(file_ID);

%---------------------------------------------------------------------------
% DEC, KERNEL, INT filter : write to file !
% create header file and info
filename = 'dec_kernel_int_WS20_EMIL.h';
file_ID = fopen(filename, 'w');		% generate include-file
fprintf(file_ID, '//------------------------------------------- \n');
fprintf(file_ID, '// designed with -- dec_kernel_int_WS20_EMIL.m -- \n', Fs );
fprintf(file_ID, '// Fs = %6.2f\n', Fs );
fprintf(file_ID, '// MMmin = %6.2f\n', MMmin );
fprintf(file_ID, '// fstop = %6.2f\n', fstop);
fprintf(file_ID, '// fpass = %6.2f\n', fpass);
fprintf(file_ID, '// delta_pass = %6.2f\n', delta_pass);
fprintf(file_ID, '// delta_stop_dB = %6.2f\n', delta_stop_dB);
fprintf(file_ID, '// N_FIR = %d, instead two stages with N_FIR_Dec_Int = %d, N_FIR_KERNEL = %d\n', ...
    N_FIR, N_FIR_Dec_Int, N_FIR_kernel_MM);
fprintf(file_ID, '//------------------------------------------- \n');





% polyphase filters of the decimation filter (also used for interpolation)
N_poly = ceil(length(b_dec)/MM);
fprintf(file_ID, '#define N_delays_poly %d\n\n', N_poly);
for lambda = 0:MM-1
    fprintf(file_ID, 'short H_dec_%d_delays[N_delays_poly];\n', lambda);
    fprintf(file_ID, 'short H_int_%d_delays[N_delays_poly];\n', lambda);
    write_coeff(file_ID, sprintf('b_poly_%d', lambda), b_dec(lambda+1:MM:end), N_poly);
end

% kernel filter
fprintf(file_ID, '#define N_delays_kernel %d\n', length(b_kernel));
fprintf(file_ID, 'short H_kernel_delays[N_delays_kernel];\n');
write_coeff(file_ID, 'b_kernel', b_kernel, length(b_kernel));

fclose(file_ID);
