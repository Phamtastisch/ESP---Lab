% Dateiname:   dBinv.M                     US 18.4.90
%
% dB to linear conversion, earlier version linlog, loglin.m
%
% function arglin = dbinv(argdB);
function arglin = dbinv(argdB);

arglin = 10.^(argdB/20);

return;
