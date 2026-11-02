function write_coeff(file_ID, b_fir_name, b_fir, N_del);
% function write_coeff(file_ID, b_fir_name, b_fir, N_del);
%
% US May 2006
%
% Note : file must be open !!
%
% changes: 
%            only 5 coeffs per LINE. This shows ONE BIQUAD per line (incl. b0=1 !!)!
% 14-Aug-08: if N_del is larger than b_fir, zeros are appended !! 
%
% usage : write_coeff(file_ID, 'h_coeff', b_fir, N_del)
fprintf(file_ID, 'short ');
fprintf(file_ID, b_fir_name);
fprintf(file_ID,['[',num2str(N_del),']={\n']);

% append zeros to b_fir, if N_del is larger than length(b_fir)
if length(b_fir) < N_del
    b_fir = [b_fir,zeros(1,N_del-length(b_fir))];
end;

j = 0;
for i= 1:N_del;
   fprintf(file_ID,' %6.0f,', round(b_fir(i)*32768) );
   j = j + 1;
   if j >5 % was 7
     fprintf(file_ID, '\n');
     j = 0;
  end
end
fprintf(file_ID,'};\n\n');



