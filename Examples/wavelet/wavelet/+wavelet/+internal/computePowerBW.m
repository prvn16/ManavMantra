function [bw,flo,fhi,pwr,totpwr] = computePowerBW(Pxx, F, Frange, R)
% This function is for internal use only and may be removed in a future 
% release.
% Pxx is the periodogram
% F is the frequency vector
% Frange is the frequency range [0 Nyquist]
% R is the db-down point to be measured
% R = -10*log10(2);
F = F(:);
status.hasNyquist = true;
status.inputType = 'time';
if isempty(Frange)
  [flo,fhi,pwr,totpwr] = computeFreqBordersFromMaxLevel(Pxx, F, R, status);
else
  [flo,fhi,pwr,totpwr] = computeFreqBordersFromRange(Pxx, F, R, Frange, status);
end

% return the occupied bandwidth and occupied bandpower
bw = fhi - flo;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function  [fLo,fHi,pwr,totpwr] = computeFreqBordersFromMaxLevel(Pxx, F, R, status)
% return the frequency widths of each frequency bin
dF = specfreqwidth(F);

% integrate the PSD to get the power spectrum
P = bsxfun(@times,Pxx,dF);

% correct density if a one-sided spectrum 
if F(1)==0
  Pxx(1,:) = 2*Pxx(1,:);
end

% correct Nyquist bin
if status.hasNyquist && strcmp(status.inputType,'time')
  Pxx(end,:) = 2*Pxx(end,:);
end

% get the reference level for the PSD
[refPSD,iCenter] = max(Pxx);

% drop by the rolloff factor
refPSD = refPSD*10^(R/10);

nChan = size(Pxx,2);
fLo = zeros(1,nChan);
fHi = zeros(1,nChan);
pwr = zeros(1,nChan);

% Cumulative rectangular integration
cumPwr = [zeros(1,size(P,2)); cumsum(P)];
totpwr = cumPwr(end,:);

% place borders halfway between each estimate.
cumF = [F(1); (F(1:end-1)+F(2:end))/2; F(end)];

% loop over each channel
for iChan=1:nChan
  iC = iCenter(iChan);
  iL = find(Pxx(1:iC,iChan)<=refPSD(iChan),1,'last');
  iR = find(Pxx(iC:end,iChan)<=refPSD(iChan),1,'first')+iC-1;
  [fLo(iChan), fHi(iChan), pwr(iChan)] = ...
      getBW(iL,iR,iC,iC,Pxx(:,iChan),F,cumPwr(:,iChan),cumF,refPSD(iChan));
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [fLo,fHi,pwr,totpwr] = computeFreqBordersFromRange(Pxx, F, R, Frange, status)
% return the frequency widths of each frequency bin
dF = specfreqwidth(F);

% multiply the PSD by the width to get the power within each bin
P = bsxfun(@times,Pxx,dF);

% find all elements within the specified range
idx = find(Frange(1)<=F & F<=Frange(2));

% compute the total power within the range
totPwr = sum(P(idx,:));

% get the reference level for the PSD
refPSD = totPwr ./ sum(dF(idx));

% drop by the rolloff factor
refPSD = refPSD*10^(R/10);

% correct dc if a one-sided spectrum 
if F(1)==0
  Pxx(1,:) = 2*Pxx(1,:);
end

% correct Nyquist bin
if status.hasNyquist && strcmp(status.inputType,'time')
  Pxx(end,:) = 2*Pxx(end,:);
end

% search for the frequency in the center of the channel
Fcenter = sum(Frange)/2;
iLeft = find(F<Fcenter,1,'last');
iRight = find(F>Fcenter,1,'first');

nChan = size(Pxx,2);
fLo = zeros(1,nChan);
fHi = zeros(1,nChan);
pwr = zeros(1,nChan);

% Cumulative rectangular integration
cumSxx = [zeros(1,size(P,2)); cumsum(P)];
totpwr = cumSxx(end,:);


% place borders halfway between each estimate.
cumF = [F(1); (F(1:end-1)+F(2:end))/2; F(end)];

% loop over each channel
for iChan=1:nChan
  iL = find(Pxx(1:iRight,iChan)<=refPSD(iChan),1,'last');
  iR = find(Pxx(iLeft:end,iChan)<=refPSD(iChan),1,'first')+iLeft-1;
  [fLo(iChan), fHi(iChan), pwr(iChan)] = ...
      getBW(iL,iR,iLeft,iRight,Pxx(:,iChan),F,cumSxx(:,iChan),cumF,refPSD(iChan));
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [fLo, fHi, pwr] = getBW(iL,iR,iLeft,iRight,Pxx,F,cumPwr,cumF,refPSD)
if isempty(iL)
  fLo = F(1);
elseif iL==iRight
  fLo = NaN;
else
  % use log interpolation to get power bandwidth
  fLo = wavelet.internal.linterp(F(iL),F(iL+1), ...
            log10(max(Pxx(iL),realmin)),log10(max(Pxx(iL+1),realmin)),log10(refPSD));
end

if isempty(iR)
  fHi = F(end);
elseif iR==iLeft
  fHi = NaN;
else
  % use log interpolation to get power bandwidth
  fHi = wavelet.internal.linterp(F(iR),F(iR-1), ...
            log10(max(Pxx(iR),realmin)),log10(max(Pxx(iR-1),realmin)),log10(refPSD));
end

% find the integrated power for the low and high frequency range
pLo = interpPower(cumPwr,cumF,fLo);
pHi = interpPower(cumPwr,cumF,fHi);
pwr = pHi-pLo;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function p = interpPower(cumPwr,cumF,f)
idx = find(f<=cumF, 1,'first');
if ~isempty(idx)
  if idx==1
    p = wavelet.internal.linterp(cumPwr(1,:),cumPwr(2,:),cumF(1),cumF(2),f);
  else
    p = wavelet.internal.linterp(cumPwr(idx,:),cumPwr(idx-1,:), ...
                                cumF(idx),cumF(idx-1),f);
  end
else
  p = nan(1,size(cumPwr,2));
end

%-------------------------------------------------------------------------
function width = specfreqwidth(W)
%SPECFREQWIDTH Spectral frequency width
%   Obtain an estimate of the width of an arbitrary frequency vector.  
%
%   This file is for internal use only and may be changed in a future 
%   release.
%   
%   Copyright 2014 The MathWorks, Inc.

% perform column vector conversion before checking 2d matrix

% Cast to enforce Precision rules
W = double(W);

% force column vector
W = W(:);

% Determine the width of the rectangle used to approximate the integral.
width = diff(W);

% There are two cases when spectrum is twosided, CenterDC or not.
% In both cases, the frequency samples does not cover the entire
% 2*pi (or Fs) region due to the periodicity.  Therefore, the
% missing freq range has to be compensated in the integral.  The
% missing freq range can be calculated as the difference between
% 2*pi (or Fs) and the actual frequency vector span.  For example,
% considering 1024 points over 2*pi, then frequency vector will be
% [0 2*pi*(1-1/1024)], i.e., the missing freq range is 2*pi/1024.
%
% When CenterDC is true, if the number of points is even, the
% Nyquist point (Fs/2) is exact, therefore, the missing range is at
% the left side, i.e., the beginning of the vector.  If the number
% of points is odd, then the missing freq range is at both ends.
% However, due to the symmetry of the real signal spectrum, it can
% still be considered as if it is missing at the beginning of the
% vector.  Even when the spectrum is asymmetric, since the
% approximation of the integral is close when NFFT is large,
% putting it in the beginning of the vector is still ok.
%
% When CenterDC is false, the missing range is always at the end of
% the frequency vector since the frequency always starts at 0.

% assume a relatively uniform interval
missingWidth = (W(end) - W(1)) / (numel(W) - 1);

% if CenterDC was not specified, the first frequency point will
% be 0 (DC).
centerDC = ~isequal(W(1),0);
if centerDC
    width = [missingWidth; width];
else
    width = [width; missingWidth];
end



