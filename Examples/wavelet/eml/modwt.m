function w = modwt(x,varargin)
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

narginchk(1,5);
validateattributes(x,{'double'},{'real','nonnan','finite'},mfilename);
coder.internal.assert(isvector(x),'Wavelet:modwt:OneD_Input');
datalength = coder.internal.indexInt(length(x));
coder.internal.assert(datalength >= 2,'Wavelet:modwt:LenTwo');
%Parse input arguments
defaultLev = coder.internal.indexInt(floor(log2(double(datalength))));
defaultWave = 'sym4';
[lev,Lo,Hi,reflection] = parseModwtInputs( ...
    defaultLev,defaultWave,varargin{:});
%Check that the level of the transform does not exceed floor(log2(numel(x))
maxlev = floor(log2(double(datalength)));
coder.internal.assert(lev > 0 && lev <= maxlev,'Wavelet:modwt:MRALevel');
% Scale the scaling and wavelet filters for the MODWT
Lo = Lo./sqrt(2);
Hi = Hi./sqrt(2);
% increase signal length if 'reflection' is specified
nLo = coder.internal.indexInt(numel(Lo));
if reflection
    siglen = 2*datalength;
else
    siglen = datalength;
end
% If the signal length is less than the filter length, need to
% periodize the signal in order to use the DFT algorithm
if siglen < nLo
    ncopies = nLo - siglen;
    Nrep = (1 + ncopies)*siglen;
else
    ncopies = coder.internal.indexInt(0);
    Nrep = siglen;
end
% Allocate storage for a possibly expanded data array.
xx = coder.nullcopy(zeros(1,Nrep));
% Copy one siglen worth of elements.
if reflection
    xx(1:datalength) = x;
    xx(datalength+1:siglen) = x(end:-1:1);
else
    xx(1:datalength) = x;
end
if ncopies > 0
    % x = [x,repmat(x,1,nLo - siglen)];
    for k = 1:ncopies
        offset = k*siglen;
        for j = 1:siglen
            xx(offset + j) = xx(j);
        end
    end
end
% Allocate coefficient array
w = zeros(lev+1,siglen);
% Obtain the DFT of the filters
G = fft(Lo,double(Nrep));
H = fft(Hi,double(Nrep));
%Obtain the DFT of the data
Vhat = fft(xx);
% Main MODWT algorithm
for jj = 1:lev
    [Vhat,What] = modwtdec(Vhat,G,H,jj);
    wtmp = real(ifft(What));
    % Truncate data to length of boundary condition
    w(jj,:) = wtmp(1:siglen);
end
wtmp = real(ifft(Vhat));
% Truncate data to length of boundary condition
w(lev+1,:) = wtmp(1:siglen);

%----------------------------------------------------------------------

function [Vhat,What] = modwtdec(X,G,H,J)
% [Vhat,What] = modwtfft(X,G,H,J)
ONE = coder.internal.indexInt(1);
N = coder.internal.indexInt(length(X));
upfactor = eml_lshift(ONE,J - 1); % 2^(J - 1);
Vhat = coder.nullcopy(X);
What = coder.nullcopy(X);
for k = 1:N
    idx = 1 + mod(upfactor*(k - 1),N);
    Vhat(k) = G(idx)*X(k);
    What(k) = H(idx)*X(k);
end

%--------------------------------------------------------------------------
