function [lutiter1,lutiter2] = createThinningLut
%createThinningLut creates lookup tables stored in lutthin1 and lutthin2.
%   This file does not run in the installed product, and is solely for
%   reference.  It is run to create the lookup tables stored in lutthin1.m and
%   in lutthin2.m.
%
%   Reference:
%   Louisa Lam, Seong-Whan Lee, and Ching Y. Wuen, "Thinning Methodologies-A
%   Comprehensive Survey," IEEE TrPAMI, vol. 14, no. 9, pp. 869-885, 1992.  The
%   algorithm is described at the bottom of the first column and the top of the
%   second column on page 879.

%   Copyright 2007-2009 The MathWorks, Inc.

lutiter1 = makelut(@iter1,3);
lutiter2 = makelut(@iter2,3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newval = iter1(I)

k = 1:4;
twoi = 2*k;
twoiminus1 = twoi - 1;
twoiplus1 = mod(twoi + 1,8);

%get this in the right order. start with east neighbor, move
%counter-clockwise.
x = [I(2,3) I(1,3) I(1,2) I(1,1) I(2,1) I(3,1) I(3,2) I(3,3)];
xtwoi = x(twoi);
xtwoiminus1 = x(twoiminus1);
xtwoiplus1 = x(twoiplus1);

actG1 = computeG1(xtwoi,xtwoiminus1,xtwoiplus1);
actG2 = computeG2(xtwoi,xtwoiminus1,xtwoiplus1);
actG3 = computeG3(x);

removePixel1 = actG1 & actG2 & actG3;

newval = I(2,2) & ~removePixel1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newval = iter2(I)

k = 1:4;
twoi = 2*k;
twoiminus1 = twoi - 1;
twoiplus1 = mod(twoi + 1,8);

%get this in the right order. start with east neighbor, move
%counter-clockwise.
x = [I(2,3) I(1,3) I(1,2) I(1,1) I(2,1) I(3,1) I(3,2) I(3,3)];
xtwoi = x(twoi);
xtwoiminus1 = x(twoiminus1);
xtwoiplus1 = x(twoiplus1);

actG1 = computeG1(xtwoi,xtwoiminus1,xtwoiplus1);
actG2 = computeG2(xtwoi,xtwoiminus1,xtwoiplus1);
actG3prime = computeG3prime(x);

removePixel2 = actG1 & actG2 & actG3prime;
newval = I(2,2) & ~removePixel2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G1calc = computeG1(xtwoi,xtwoiminus1,xtwoiplus1)

b = ~xtwoiminus1 & (xtwoi | xtwoiplus1);
G1calc = sum(b) == 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G2calc = computeG2(xtwoi,xtwoiminus1,xtwoiplus1)

n1 = 0;
n2 = 0;
for j = 1:4
    n1 = n1 + sum(union(xtwoiminus1(j),xtwoi(j)));
    n2 = n2 + sum(union(xtwoi(j),xtwoiplus1(j)));
end
minn1n2 = min(n1,n2);
G2calc = minn1n2 ==2 || minn1n2 == 3;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G3calc = computeG3(x)

G3calc = ( (x(2) | x(3) | ~x(8)) & x(1) ) == 0; 
                       

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G3primecalc = computeG3prime(x)

G3primecalc = ((x(6) | x(7) | ~x(4)) & x(5)) == 0;

