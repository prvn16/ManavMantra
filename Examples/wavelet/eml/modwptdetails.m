function [W,packetlevels,F] = modwptdetails(x,varargin)
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

narginchk(1,6);
ONE = coder.internal.indexInt(1);
N = coder.internal.indexInt(numel(x));
defaultLev = coder.internal.indexInt(min(4,floor(log2(double(N)))));
defaultWav = 'fk18';
[J,Lo,Hi,fulltree] = parseModwptInputs( ...
    defaultLev,defaultWav,varargin{:});
validateinputs(x,J,Lo,Hi,fulltree);
% This is the initial DFT length for the input
Lo = Lo/sqrt(2);
Hi = Hi/sqrt(2);
% If the signal length is less than the filter length, need to
% periodize the signal in order to use the DFT algorithm
nLo = coder.internal.indexInt(numel(Lo));
if N < nLo
    ncopies = nLo - N;
    Nrep = (1 + ncopies)*N;
else
    ncopies = coder.internal.indexInt(0);
    Nrep = N;
end
% Allocate storage for a possibly expanded data array.
xx = coder.nullcopy(zeros(1,Nrep));
xx(1:N) = x;
if ncopies > 0
    % x = [x,repmat(x,1,ncopies)];
    for k = 1:ncopies
        offset = k*N;
        for j = 1:N
            xx(offset + j) = xx(j);
        end
    end
end
% Obtain the DFT of the filters
% G is the DFT of the scaling filter, H is DFT of wavelet filter
G = fft(Lo,double(Nrep));
H = fft(Hi,double(Nrep));
% Obtain DFT of original data
X = fft(xx,double(Nrep));
% Create array to hold wavelet packets and packet levels
% Initially create full tree
mcfs = eml_lshift(ONE,J+1) - 2;
cfs = zeros(mcfs,Nrep,'like',X);
cfs(1,:) = X;
% MODWPT algorithm
p2 = ONE;
for kk = 1:J
    nIdx = p2;
    p2 = p2*2; % p2 = 2^kk
    % Determine first packet for a given level
    jj = p2 - 1;
    if kk > 1
        Idx2 = lengthPacketLevels(kk - 1);
        Idx = Idx2 + 1 - nIdx;
    else
        Idx = ONE;
    end
    nnhi = p2/2 - 1;
    for nn = 0:nnhi
        X = cfs(Idx + nn,:);
        [vhat,what] = modwptdecxcorr(X,G,H,kk);
        if eml_bitand(nn,ONE) == ONE % odd
            cfs(jj + 2*nn,:) = what;
            cfs(jj + 2*nn + 1,:) = vhat;
        else % even
            cfs(jj + 2*nn + 1,:) = what;
            cfs(jj + 2*nn,:) = vhat;
        end
    end
end
% Now p2 = 2^J, but let's be explicit.
pow2J = eml_lshift(ONE,J);
W1 = coder.nullcopy(zeros(mcfs,N));
for k = 1:mcfs
    v = real(ifft(cfs(k,:)));
    % Ensure output length matches signal length
    W1(k,:) = v(1:N);
end
if fulltree
    W = W1;
else
    offset = mcfs - pow2J;
    W = coder.nullcopy(zeros(pow2J,N,'like',W1));
    for j = 1:N
        for i = 1:pow2J
            W(i,j) = W1(offset + i,j);
        end
    end
end
if nargout > 1
    [packetlevels,F] = calcModwptPLandF(J,fulltree);
end

%--------------------------------------------------------------------------

function [Vhat,What] = modwptdecxcorr(X,G,H,J)
% [Vhat,What] = modwtfft(X,G,H,J)
ONE = coder.internal.indexInt(1);
N = coder.internal.indexInt(length(X));
upfactor = eml_lshift(ONE,J - 1); % 2^(J - 1);
Vhat = coder.nullcopy(X);
What = coder.nullcopy(X);
for k = 1:N
    idx = 1 + mod(upfactor*(k - 1),N);
    Vhat(k) = abs(G(idx)).^2*X(k);
    What(k) = abs(H(idx)).^2*X(k);
end

%--------------------------------------------------------------------------

function validateinputs(x,J,Lo,Hi,fulltree)
coder.inline('always');
coder.internal.prefer_const(J,Lo,Hi,fulltree);
%Input must be real-valued, double with no Infs or NaNs
validateattributes(x,{'double'},{'real','finite'},'modwpt','X');
%Input must be 1-D
coder.internal.assert(isvector(x), ...
    'Wavelet:modwt:OneD_Input');
%Input must contain at least two samples
N = numel(x);
coder.internal.assert(N >= 2,'Wavelet:modwt:LenTwo');
% J is the transform level
% validateattributes(J,{'double'},{'integer','positive'},'modwpt','LEVEL');
%Check the transform level does not exceed the maximum
coder.internal.assert(J <= floor(log2(N)),'Wavelet:modwt:MRALevel');

%--------------------------------------------------------------------------

