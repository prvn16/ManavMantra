function [xrec,gdual] = icqt(cfs,g,shifts,varargin)
%Inverse constant-Q transform using nonstationary Gabor frames
%   XREC = ICQT(CFS,G,FSHIFTS) returns the inverse constant-Q transform
%   XREC of the coefficients CFS. CFS is a matrix, cell array, or structure
%   array. G is the cell array of nonstationary Gabor constant-Q analysis
%   filters used to obtain the coefficients CFS. FSHIFTS is a vector of
%   frequency bin shifts for the constant-Q bandpass filters in G. ICQT
%   assumes by default that the original signal was real-valued. Use the
%   'SignalType' name-value pair to indicate the original input signal was
%   complex-valued. XREC is a vector if the input to CQT was a single
%   signal or a matrix if the CQT was obtained from a multichannel signal.
%   CFS, G, and FSHIFTS must be outputs of CQT.
%
%   XREC = ICQT(...,'SignalType',SIGTYPE) designates whether the original
%   signal was real- or complex-valued. Valid options for SIGTYPE are
%   'real' and 'complex'. If unspecified, SIGTYPE defaults to 'real'.
%
%   [XREC,GDUAL] = ICQT(...) optionally returns the dual frames used in the
%   synthesis of XREC as a cell array the same size as G. The dual frames
%   are the canonical dual frames derived from the analysis filters.
%
%   %Example:
%   %   Obtain the constant-Q transform of the Handel signal using the  
%   %   'sparse' transform option. Invert the CQT and demonstrate perfect
%   %   reconstruction by showing the maximum absolute reconstruction error
%   %   and the relative energy error in dB.
%   load handel;
%   [cfs,f,g,fshifts] = cqt(y,'SamplingFrequency',Fs,...
%                           'TransformType','sparse');
%   xrec = icqt(cfs,g,fshifts);
%   max(abs(xrec-y))
%   20*log10(norm(xrec-y)/norm(y))

%   References: 
%   Holighaus, N., Doerfler, M., Velasco, G.A., & Grill,T.
%   (2013) "A framework for invertible real-time constant-Q transforms",
%   IEEE Transactions on Audio, Speech, and Language Processing, 21, 4, 
%   pp. 775-785.
%
%   Velasco, G.A., Holighaus, N., Doerfler, M., & Grill, Thomas. (2011)
%   "Constructing an invertible constant-Q transform with nonstationary
%   Gabor frames", Proceedings of the 14th International Conference on 
%   Digital Audio Effects (DAFx-11), Paris, France.
%
%   See also CQT

narginchk(3,5);
nargoutchk(0,2);
if numel(g) ~= numel(shifts)
    error(message('Wavelet:FunctionInput:FrameShiftsNotEqual',...
        'G','FSHIFTS'));
end
p = inputParser;
addParameter(p,'SignalType','real');
parse(p,varargin{:});
sigtype = validatestring(p.Results.SignalType,{'real','complex'},...
    'ICQT','SignalType');

siglen = sum(shifts);    

if ~iscell(cfs) && ~isstruct(cfs)
    % The third dimension of the array gives the number of signals
    [Nf,Nt,Ns] = size(cfs);
    % First permute back before reshaping
    cfs = ipermute(cfs,[2 1 3]);
    cfs = reshape(cfs,Nf*Nt,Ns);
    cfs = mat2cell(cfs,Nt*ones(Nf,1),Ns);
    
elseif ~iscell(cfs) && isstruct(cfs)
    cfstmp = cell(numel(g),1);
    [Nf,Nt,Ns] = size(cfs.c);
    % First permute back before reshaping
    cfs.c = ipermute(cfs.c,[2 1 3]);
    cfs.c = reshape(cfs.c,Nf*Nt,Ns);
    cfs.c = mat2cell(cfs.c,Nt*ones(Nf,1),Ns);
    % Put in DC and Nyquist coefficients
    idx = setdiff(1:numel(g),[1 cfs.NyquistBin]);
    cfstmp(idx) = cfs.c;
    cfstmp{1} = cfs.DCcfs;
    cfstmp{cfs.NyquistBin} = cfs.Nyquistcfs;
    cfs = cfstmp;
end

% Scale coefficients prior to inversion
% Note: may be faster to do this prior to reforming into cell array
if  strcmpi(sigtype,'real')
    cfs = cellfun(@(x)(siglen/(2*size(x,1)))*x,cfs,'uni',0);
    
elseif strcmpi(sigtype,'complex')
    cfs = cellfun(@(x)(siglen/size(x,1))*x,cfs,'uni',0);
end

% This is the number of signals, all signals in the cell array of
% coefficients will have the same column size, so we just use the first one
numsignals = size(cfs{1},2);
positions = cumsum(shifts);
N = positions(end);
positions = positions-shifts(1);
xrec = zeros(N,numsignals);



M = cellfun(@(x)size(x,1),cfs);

% Compute dual frames 
gdual = wavelet.internal.dualcswindow(g,shifts,M);

% Algorithm for computing inverse CQT due to Holinghaus and Velasco
for kk = 1:numel(gdual)
    Lg = length(gdual{kk});
    temp = fft(cfs{kk})*M(kk);
    win_range = mod(positions(kk)+(-floor(Lg/2):ceil(Lg/2)-1),N)+1;
    temp = temp(mod([end-floor(Lg/2)+1:end,1:ceil(Lg/2)]-1,M(kk))+1,:);
    xrec(win_range,:) = xrec(win_range,:) + ...
        temp.*gdual{kk}([Lg-floor(Lg/2)+1:Lg,1:ceil(Lg/2)]);
end

if strcmpi(sigtype,'real')
    xrec = ifft(xrec,'symmetric');
elseif strcmpi(sigtype,'complex')
    xrec = ifft(xrec);
end





