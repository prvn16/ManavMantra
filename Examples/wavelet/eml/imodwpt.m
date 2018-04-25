function xrec = imodwpt(cfs,varargin)
%MATLAB Code Generation Private Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

narginchk(1,4);
ZERO = coder.internal.indexInt(0);
ONE = coder.internal.indexInt(1);
% Input must a real-valued matrix with no Infs or NaNs
validateattributes(cfs,{'double'},{'real','finite'},'imodwpt','CFS');
% The terminal level must be at least j=1, which means that cfs must have
% two rows
coder.internal.assert(~isvector(cfs),'Wavelet:modwt:InvalidCFSSize');
NumPackets = coder.internal.indexInt(size(cfs,1));
% The number of rows in the matrix must be a power of two
coder.internal.assert(coder.internal.sizeIsPow2(NumPackets), ...
    'Wavelet:modwt:InvalidTermSize');
%The level of the transform
level = coder.internal.indexInt(log2(double(NumPackets)));
%Parse inputs
defaultWav = 'fk18';
[~,Lo,Hi] = parseModwptInputs(level,defaultWav,varargin{:});
Lo = Lo/sqrt(2);
Hi = Hi/sqrt(2);
% If the coefficient length is less than the filter length, need to
% periodize the signal in order to use the DFT algorithm
N = coder.internal.indexInt(size(cfs,2));
%For the edge case where the number of samples is less than the scaling
%filter
nLo = coder.internal.indexInt(numel(Lo));
if N < nLo
    ncopies = nLo - N;
    Nrep = (1 + ncopies)*N;
else
    ncopies = coder.internal.indexInt(0);
    Nrep = N;
end
% Allocate storage for a possibly expanded data array.
cfs1 = coder.nullcopy(zeros(size(cfs,1),Nrep));
% Copy one page of elements.
cfs1(:,1:N) = cfs;
if ncopies > 0
    for k = 1:ncopies
        offset = k*N;
        for j = 1:N
            cfs1(:,offset + j) = cfs1(:,j);
        end
    end
end
% Obtain the DFT of the filters
G = fft(Lo,double(Nrep));
H = fft(Hi,double(Nrep));
mcfs = coder.internal.indexInt(size(cfs1,1));
upcfs = zeros(mcfs/2,Nrep);
for jj = level:-1:1
    kk = ONE;
    index = ZERO;
    twopjjm1 = eml_lshift(ONE,jj - 1); 
    for nn = 0:twopjjm1-1
        index = index + 1;
        if eml_bitand(nn,ONE) == 0
            upcfs(index,:) = EvenInvert(cfs1(kk,:),cfs1(kk+1,:),G,H,jj);
        else
            upcfs(index,:) = OddInvert(cfs1(kk,:),cfs1(kk+1,:),G,H,jj);
        end
        kk = kk + 2;
    end
    mcfs = mcfs/2;
    cfs1(1:mcfs,:) = upcfs(1:mcfs,:);
end
%Ensure output length matches the number of columns in the input
xrec = cfs1(1,1:N);

%--------------------------------------------------------------------------

function evencfs = EvenInvert(even,odd,G,H,J)
N = coder.internal.indexInt(numel(even));
ONE = coder.internal.indexInt(1);
evendft = fft(even);
odddft = fft(odd);
upfactor = eml_lshift(ONE,J - 1); % 2^(J - 1);
for k = 1:N
    idx = 1 + mod(upfactor*(k - 1),N);
    Gupk = conj(G(idx));
    Hupk = conj(H(idx));
    % Reuse storage for evendft: evendft = Gup.*evendft + Hup.*odddft.
    evendft(k) = Gupk*evendft(k) + Hupk*odddft(k);
end
evencfs = real(ifft(evendft));

%--------------------------------------------------------------------------

function oddcfs = OddInvert(even,odd,G,H,J)
N = coder.internal.indexInt(numel(even));
ONE = coder.internal.indexInt(1);
evendft = fft(even);
odddft = fft(odd);
upfactor = eml_lshift(ONE,J - 1); % 2^(J - 1);
for k = 1:N
    idx = 1 + mod(upfactor*(k - 1),N);
    Gupk = conj(G(idx));
    Hupk = conj(H(idx));
    % Reuse storage for odddft: odddft = Gup.*odddft + Hup.*evendft.
    odddft(k) = Gupk*odddft(k) + Hupk*evendft(k);
end
oddcfs = real(ifft(odddft));

%--------------------------------------------------------------------------
