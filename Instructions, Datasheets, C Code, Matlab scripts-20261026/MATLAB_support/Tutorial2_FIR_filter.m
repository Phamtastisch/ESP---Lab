% Tutorial2_FIR_filter.m.m
%
% US 2-Aug-06, revised 12-Jul-23
%
% This version is the starter version for the MES FIR Tutorial
% 
% It designs a filter according to specification done in Tutorial assignment
%
% the FIR filter is used on McBsp0 LEFT only:
% ONE coefficient set generated, ONE delay buffers generated

%*  Fs1= 33333.0 Hz 
%*  pass-band edge frequency 1000 Hz,  
%*  stop-band edge frequency 2000 Hz,
%*  pass-band ripple 0.01
%*  minimum stop-band attenuation 40 dB

clear
close('all');
format compact
help FIR_tutorial_design
Fs = inputs('Fs', 33333.0);

% create a frequency vector
freq=(1:999)/2000;

% stop-band attentuation is in dB, convert to linear for REMEZ
delta_stop_dB = inputs('stop-band attenuation in dB', 40);
delta_stop = dbinv(-delta_stop_dB);
% for pass-band
delta_pass = inputs('pass-band ripple', 0.01);

% edge frequencies
fpass = inputs('fpass', 1000); 
fstop = inputs('fstop', 2000); 

% determine N_FIR and the coefficients using REMEZ ("normal" FIR filter)
[N_FIR,fo,mo,w] = firpmord( [fpass fstop], [1 0], [delta_pass delta_stop], Fs );
% for safety reasons, add 2 to N_FIR to achieve the stop-band attenuation for sure
% N_FIR = N_FIR + 2;
b_FIR_Tutorial = firpm(N_FIR,fo,mo,w);

% round them to 16 bits
b_FIR_Tutorial = round(b_FIR_Tutorial*32768)/32768; 

% compute the amplitude response using frequency vector
hz = freqz(b_FIR_Tutorial, 1, 2*pi*freq);

fprintf('\n Order of filter, N_FIR=%d\n\n', N_FIR);

plot(freq*Fs,db(hz)),grid
title('Amplitude response of desired TUTORIAL FIR filter in dB'),
xlabel('Frequency in Hz, Nyquist range');
ylabel('|H| in dB');
pause

%---------------------------------------------------------------------------
% write to file !
% create header file and info
fprintf('coefficients are written to file ==> ');
filename = 'Tutorial2_FIR_filter.h';
fprintf(filename);
fprintf('\n\n');

file_ID = fopen(filename, 'w');		% generate include-file
fprintf(file_ID, '//------------------------------------------- \n');
fprintf(file_ID, '// designed with -- Tutorial2_FIR_filter.m -- \n');
fprintf(file_ID, ['// ',date,'\n'] );
fprintf(file_ID, '// Fs = %6.2f\n', Fs );
fprintf(file_ID, '// fstop = %6.2f\n', fstop);
fprintf(file_ID, '// fpass = %6.2f\n', fpass);
fprintf(file_ID, '// delta_pass = %6.2f\n', delta_pass);
fprintf(file_ID, '// delta_stop_dB = %6.2f\n', delta_stop_dB);
fprintf(file_ID, '// N_FIR = %d\n',  N_FIR);
fprintf(file_ID, '//------------------------------------------- \n');

fprintf(file_ID, '#define N_DELAYS_FIR_DESIGN_TUTORIAL %d\n', length(b_FIR_Tutorial));
fprintf(file_ID, 'short H_filt_FIR_design_Tutorial_McBsp0[N_DELAYS_FIR_DESIGN_TUTORIAL]; \n');
write_coeff(file_ID, 'b_FIR_Tutorial', b_FIR_Tutorial, length(b_FIR_Tutorial));

fclose(file_ID);
