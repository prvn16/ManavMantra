function mra = modwtmra(w,varargin)
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

narginchk(1,4);
coder.internal.assert(~isvector(w),'Wavelet:modwt:MRASize');
validateattributes(w,{'double'},{'real','nonnan','finite'},mfilename);
ncw = coder.internal.indexInt(size(w,2));
% get the size of the output coefficients
cfslength = coder.internal.indexInt(ncw);
J0 = coder.internal.indexInt(size(w,1)) - 1;
N = cfslength;
ZERO = coder.internal.indexInt(0);
ONE = coder.internal.indexInt(1);
%Parse input arguments
defaultLev = ZERO;
defaultWave = 'sym4';
[~,Lo,Hi,reflection] = parseModwtInputs( ...
    defaultLev,defaultWave,varargin{:});
% Scale the scaling and wavelet filters for the MODWT
Lo = Lo./sqrt(2);
Hi = Hi./sqrt(2);
% Adjust final output length if MODWT obtained with 'reflection'
if reflection
    N = eml_rshift(N,ONE);
end
nLo = coder.internal.indexInt(numel(Lo));
if cfslength < nLo
    ncopies = nLo - cfslength;
    cfslength = (1 + ncopies)*cfslength;
else
    ncopies = ZERO;
end
% Allocate storage for a possibly expanded data array.
nullinput = zeros(1,cfslength);
ww = coder.nullcopy(zeros(size(w,1),cfslength));
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
G = fft(Lo,double(cfslength));
H = fft(Hi,double(cfslength));
% Allocate array for MRA
mra = zeros(J0+1,N);
for J = J0:-1:1
    details = imodwtDetails(ww(J,:),nullinput,J,G,H,cfslength);
    mra(J,:) = details(1:N);
end
% scalingcoefs = w(J0+1,:);
smooth = imodwtSmooth(ww(J0+1,:),nullinput,G,H,cfslength,J0);
mra(J0+1,:) = smooth(1:N);

%-----------------------------------------------------------------------

function details = imodwtDetails(coefs,nullinput,lev,Lo,Hi,N)
v = nullinput;
w = coefs;
for jj = lev:-1:1
    vout = imodwtrec(v,w,Lo,Hi,jj);
    v = vout;
    w = nullinput;
end
details = v(1:N);

%-----------------------------------------------------------------------
function smooth = imodwtSmooth(scalingcoefs,nullinput,Lo,Hi,N,J0)
v = scalingcoefs;
for J = J0:-1:1
    vout = imodwtrec(v,nullinput,Lo,Hi,J);
    v = vout;
end
smooth = v(1:N);

%----------------------------------------------------------------------

function Vout = imodwtrec(Vin,Win,G,H,J)
N = coder.internal.indexInt(length(Vin));
ONE = coder.internal.indexInt(1);
upfactor = eml_lshift(ONE,J - 1); % 2^(J - 1);
Vhat = fft(Vin);
What = fft(Win);
for k = 1:N
    idx = 1 + mod(upfactor*(k - 1),N);
    Gupk = conj(G(idx));
    Hupk = conj(H(idx));
    % Reuse storage for Vhat: Vhat = Gup.*Vhat + Hup.*What
    Vhat(k) = Gupk*Vhat(k) + Hupk*What(k);
end
Vout = real(ifft(Vhat));

%--------------------------------------------------------------------------
