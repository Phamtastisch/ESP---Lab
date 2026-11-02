% db.m
%
% US 4-Dec-1990, 6-Oct-04
%
% dB computation
%
% Linear to LOG conversion of complex numbers
%
% function arglog20 = dB(arglin);
function arglog20 = dB(arglin);

arglog20 = 20*log10(abs(arglin));
