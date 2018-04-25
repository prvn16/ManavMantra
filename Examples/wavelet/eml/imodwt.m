function xrec = imodwt(w,varargin)
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

narginchk(1,5);
validateattributes(w,{'double'},{'real','nonnan','finite'},mfilename);
coder.internal.assert(~isvector(w),'Wavelet:modwt:InvalidCFSSize');
ncw = coder.internal.indexInt(size(w,2));
N = coder.internal.indexInt(ncw);
Nrep = N;
J = coder.internal.indexInt(size(w,1)) - 1;
ZERO = coder.internal.indexInt(0);
ONE = coder.internal.indexInt(1);
%Parse input arguments
defaultLev = ZERO;
defaultWave = 'sym4';
[lev,Lo,Hi,reflection] = parseModwtInputs( ...
    defaultLev,defaultWave,varargin{:});
lev = lev + 1;
coder.internal.assert(lev <= J,'Wavelet:modwt:Incorrect_ReconLevel');
% Scale the scaling and wavelet filters for the MODWT
Lo = Lo./sqrt(2);
Hi = Hi./sqrt(2);
% Adjust final output length if MODWT obtained with 'reflection'
if reflection
    N = eml_rshift(N,ONE);
end
% If the number of samples is less than the length of the scaling filter
% we have to periodize the data and then truncate.
nLo = coder.internal.indexInt(numel(Lo));
if Nrep < nLo
    ncopies = nLo - Nrep;
    Nrep = (1 + ncopies)*N;
else
    ncopies = ZERO;
end
% Allocate storage for a possibly expanded data array.
ww = coder.nullcopy(zeros(size(w,1),Nrep));
% Copy one page of elements.
ww(:,1:ncw) = w;
if ncopies > 0
    for k = 1:ncopies
        offset = k*ncw;
        for j = 1:ncw
            ww(:,offset + j) = ww(:,j);
        end
    end
end
% Obtain the DFT of the filters
G = fft(Lo,double(Nrep));
H = fft(Hi,double(Nrep));
% IMODWT algorithm
vout = ww(J+1,:);
for jj = J:-1:lev
    vout = imodwtrec(vout,ww(jj,:),G,H,jj);
end
% Return proper output length
xrec = vout(1:N);

%----------------------------------------------------------------------

function V = imodwtrec(V,W,G,H,J)
N = coder.internal.indexInt(length(V));
ONE = coder.internal.indexInt(1);
upfactor = eml_lshift(ONE,J - 1); % 2^(J - 1);
Vhat = fft(V);
What = fft(W);
for k = 1:N
    idx = 1 + mod(upfactor*(k - 1),N);
    Gupk = conj(G(idx));
    Hupk = conj(H(idx));
    % Reuse storage for Vhat: Vhat = Gup.*Vhat + Hup.*What
    Vhat(k) = Gupk*Vhat(k) + Hupk*What(k);
end
V = real(ifft(Vhat));

%--------------------------------------------------------------------------
