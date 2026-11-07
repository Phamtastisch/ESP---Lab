% roots_demo.m
%
% US 07-Nov-23
%
% demo for finding M_opt
clear
close all
Fs = 50000;
fpass = 3100;
fstop = 3350;

a = fstop^2 - fpass^2;
b = -(fpass + fstop)^2;
c = 2 * Fs  * (fpass   + fstop);
d = -Fs^2;

my_polynom = [a b c d]
roots(my_polynom)