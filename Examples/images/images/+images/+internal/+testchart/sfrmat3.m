function [status, dat, e, fitme, esf, nbin, del2, contrast_test, slope_deg] = sfrmat3(~, del, ~, a, ~)
% sfrmat3 Compute spatial frequency response (SFR). This is a trimmed down version of code provided
% by Peter D. Burns(http://losburns.com/imaging/software/SFRedge/index.htm).

% This code is a modified version of that found in:
%
% sfrmat3, Peter D. Burns(http://losburns.com/imaging/software/SFRedge/index.htm)
% 
% Copyright (c) 2009-2015 Peter D. Burns, pdburns@ieee.org
% Licensed under the Simplified BSD License [see sfrmat3.rights]

status = 0;
e = [];
%ITU-R Recommendation  BT.709 weighting
weight =  [0.213 0.715 0.072];

oldflag = 0;
nbin = 4;

a = double(a);

[nlin, npix, ncol] = size(a);

% Form luminance record using the weight vector for red, green and blue

if ncol == 3
    
    lum = weight(1)*a(:,:,1) + weight(2)*a(:,:,2) + weight(3)*a(:,:,3);
    cc = [ a(:, :, 1), a(:, :, 2), a(:,:, 3), lum];
    cc = reshape(cc,nlin,npix,4);
    
    a = cc;
    clear cc;
    clear lum;
    ncol = 4;
end

if size(a,1) < size(a,2)
    a = rot90(a);
    temp=nlin;
    nlin = npix;
    npix = temp;
    rflag = 1;
else
    rflag = 0;
end

loc = zeros(ncol, nlin);

fil1 = [0.5 -0.5];
fil2 = [0.5 0 -0.5];
% We Need 'positive' edge
tleft  = sum(sum(a(:,      1:5,  1),2));
tright = sum(sum(a(:, npix-5:npix,1),2));
if tleft>tright
    fil1 = [-0.5 0.5];
    fil2 = [-0.5 0 0.5];
end
% Test for low contrast edge;
contrast_test = abs( (tleft-tright)/(tleft+tright) );

fitme = zeros(ncol, 3);
slout = zeros(ncol, 1);

% Smoothing window for first part of edge location estimation -
%  to be used on each line of ROI
win1 = images.internal.testchart.ahamming(npix, (npix+1)/2);    % Symmetric window

for color=1:ncol                      % Loop for each color
     
    c = zeros(nlin, npix);
    nn = length(fil1);
    temp = conv2(a(:,:,color),fil1);
    c(:,nn:npix) = temp(:,nn:npix);
    c(:,nn-1) = c(:,nn);
    
    % compute centroid for derivative array for each line in ROI. NOTE WINDOW array 'win'
    for n=1:nlin
        loc(color, n) = images.internal.testchart.centroid( c(n, 1:npix )'.*win1) - 0.5;   % -0.5 shift for FIR phase
    end
    
    
    fitme(color,1:2) = images.internal.testchart.findedge(loc(color,:), nlin);
    place = zeros(nlin,1);
    for n=1:nlin
        place(n) = fitme(color,2) + fitme(color,1)*n;
        win2 = images.internal.testchart.ahamming(npix, place(n));
        loc(color, n) = images.internal.testchart.centroid( c(n, 1:npix )'.*win2) -0.5;
    end
    
    fitme(color,1:2) = images.internal.testchart.findedge(loc(color,:), nlin);
    
end

midloc = zeros(ncol,1);

for i=1:ncol
    slout(i) = - 1./fitme(i,1);      % slope is as normally defined in image coods.
    if rflag==1                        % positive flag it ROI was rotated
        slout(i) =  - fitme(i,1);
    end
    
    % evaluate equation(s) at the middle line as edge location
    midloc(i) = fitme(i,2) + fitme(i,1)*((nlin-1)/2);
end

if ncol>2
    misreg = zeros(ncol,1);
    for i=1:ncol
        misreg(i) = midloc(i) - midloc(2);
        fitme(i,3) = misreg(i);
    end
end  

% Full linear fit is available as variable fitme. Note that the fit is for
% the projection onto the X-axis,
%       x = fitme(color, 1) y + fitme(color, 2)
% so the slope is the inverse of the one that you may expect

% Limit number of lines to integer(npix*line slope as per ISO algorithm
% except if processing as 'sfrmat2'
if oldflag ~= 1
    nlin1 = round(floor(nlin*abs(fitme(1,1)))/abs(fitme(1,1)));
    a = a(1:nlin1, :, 1:ncol);
end

vslope = fitme(1,1);
slope_deg= 180*atan(abs(vslope))/pi;

del2=0;
if oldflag ~= 1
    %Correct sampling inverval for sampling parallel to edge
    delfac = cos(atan(vslope));
    del = del*delfac;
    del2 = del/nbin;
end

nn =   floor(npix *nbin);
mtf =  zeros(nn, ncol);
nn2 =  floor(nn/2) + 1;

if oldflag ~=1
    dcorr = images.internal.testchart.fir2fix(nn2, 3);    % dcorr corrects SFR for response of FIR filter
end

freq = zeros(nn, 1);
for n=1:nn
    freq(n) = nbin*(n-1)/(del*nn);
end

freqlim = 1;
if nbin == 1
    freqlim = 2;
end
nn2out = round(nn2*freqlim/2);

win = images.internal.testchart.ahamming(nbin*npix,(nbin*npix+1)/2);      % centered Hamming window
esf = zeros(nn,ncol);
for color=1:ncol
    % project and bin data in 4x sampled array
    [point, status] = images.internal.testchart.project(a(:,:,color), loc(color, 1), fitme(color,1), nbin);    
    esf(:,color) = point;
    
    % compute first derivative via FIR (1x3) filter fil
    c = zeros(1, nn);
    nn1 = length(fil2);
    temp = conv2(point',fil2);
    c(:,nn1:nn) = temp(:,nn1:nn);
    c(:,nn1-1) = c(:,nn1);
    c = c';
    
    mid = images.internal.testchart.centroid(c);
    temp = images.internal.testchart.cent(c, round(mid));              % shift array so it is centered
    c = temp;
    clear temp;
    
    % apply window (symmetric Hamming)
    c = win.*c;
    
    
    % Transform, scale and correct for FIR filter response    
    temp = abs(fft(c, nn));
    mtf(1:nn2, color) = temp(1:nn2)/temp(1);
    if oldflag ~=1
        mtf(1:nn2, color) = mtf(1:nn2, color).*dcorr;
    end
end 

dat = zeros(nn2out, ncol+1);
for i=1:nn2out
    dat(i,:) = [freq(i), mtf(i,:)];
end

