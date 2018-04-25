function varargout = cqt(x,varargin)
%Constant-Q nonstationary Gabor transform
%   CFS = CQT(X) returns the constant-Q transform of X. X is a
%   double-precision real- or complex-valued vector or matrix. X must have
%   at least four samples. If X is a matrix, CQT obtains the constant-Q
%   transform of each column of X. CFS is a matrix if X is a vector, or
%   multidimensional array if X is a multichannel signal. The array, CFS,
%   corresponds to the maximally redundant version of the CQT. Each row of
%   the pages of CFS corresponds to passbands with normalized center
%   frequencies (cycles/sample) logarithmically spaced between 0 and 1. A
%   normalized frequency of 1/2 corresponds to the Nyquist frequency. The
%   number of columns, or hops, corresponds to the largest bandwidth center
%   frequency. This usually occurs one frequency bin below (or above) the
%   Nyquist bin. Note that the inverse CQT requires the optional outputs G
%   and FSHIFTS described below.
%
%   [CFS,F] = CQT(X) returns the approximate bandpass center frequencies F
%   corresponding to the rows of CFS. The frequencies are ordered from 0 to
%   1 and are in cycles/sample.
%
%   [CFS,F,G,FSHIFTS] = CQT(X) returns the Gabor frames G used in the
%   analysis of X and the frequency shifts FSHIFTS in discrete Fourier
%   transform (DFT) bins between the passbands in the rows of CFS. CFS, G,
%   and FSHIFTS are required inputs for the inversion of the CQT with ICQT.
%
%   [CFS,F,G,FSHIFTS,FINTERVALS] = CQT(X) returns the frequency intervals
%   FINTERVALS corresponding the rows of CFS. The k-th element of FSHIFTS
%   is the frequency shift in DFT bins between the ((k-1) mod N)-th and (k
%   mod N)-th element of FINTERVALS with k = 0,1,2,...,N-1 where N is the
%   number of frequency shifts. Because MATLAB indexes from 1, this means
%   that FSHIFTS(1) contains the frequency shift between FINTERVALS{end}
%   and FINTERVALS{1}, FSHIFTS(2) contains the frequency shift between
%   FINTERVAL{1} and FINTERVAL{2} and so on.
%
%   [CFS,F,G,FSHIFTS,FINTERVALS,BW] = CQT(X) returns the bandwidths BW in
%   DFT bins of the frequency intervals, FINTERVALS.
%
%   [...] = CQT(X,'SamplingFrequency',Fs) specifies the sampling frequency
%   of X in hertz. Fs is a positive scalar.
%
%   [...] = CQT(...,'BinsPerOctave',B) specifies the number of bins per
%   octave to use in the constant-Q transform as an integer between 1
%   and 96. B defaults to 12.
%
%   [...] = CQT(...,'TransformType',TTYPE) specifies the 'TransformType' as
%   "full" or "sparse". The "sparse" transform is the minimally redundant
%   version of the constant-Q transform. If you specify 'TransformType' as
%   "sparse", CFS is a cell array with the number of elements equal to the
%   number of bandpass frequencies. Each element of the cell array, CFS, is
%   a vector or matrix with the number of rows equal to the value of the
%   bandwidth in DFT bins, BW. If 'TransformType' is "full" without
%   'FrequencyLimits', CFS is a matrix. If 'TransformType' is "full" and
%   frequency limits are specified, CFS is a structure array.
%
%   [...] = CQT(...,'FrequencyLimits',[FMIN FMAX]) specifies the frequency
%   limits over which the constant-Q transform has a logarithmic frequency
%   response with the specified number of frequency bins per octave. FMIN
%   must be greater than or equal to Fs/N where Fs is the sampling
%   frequency and N is the length of the signal. FMAX must be strictly less
%   than the Nyquist frequency. To achieve the perfect reconstruction
%   property of the constant-Q analysis with nonstationary Gabor frames,
%   both the zero frequency (DC) and the Nyquist bin must be prepended and 
%   appended respectively to the frequency interval. The negative
%   frequencies are mirrored versions of the positive center frequencies
%   and bandwidths. If the TransformType is specified as 'full' and you
%   specify frequency limits, CFS is returned as a structure array with the
%   following 4 fields: 
%   c:              Coefficient matrix or multidimensional array for the
%                   frequencies within the specified frequency limits. This
%                   includes both the positive and "negative" frequencies.
%   DCcfs:          Coefficient vector or matrix for the passband from 0 to
%                   the lower frequency limit.
%   Nyquistcfs:     Coefficient vector or matrix for the passband from the
%                   upper frequency limit to the Nyquist.
%   NyquistBin:     DFT bin corresponding to the Nyquist frequency. This
%                   field is used when inverting CQT.
%
%   [...] = CQT(...,'Window',WINNAME) uses the WINNAME window as the
%   prototype function for the nonstationary Gabor frames. Supported
%   options for WINNAME are "hann", "hamming", "blackmanharris",
%   "itersine", and "bartlett". WINNAME defaults to "hann". Note that these
%   are compactly supported functions in frequency defined on the interval
%   (-1/2,1/2) for normalized frequency or (-Fs/2,Fs/2) when you specify a
%   sampling frequency.
%
%   CQT(...) with no output arguments plots the constant-Q transform in the
%   current figure. Plotting is only supported for a single-vector input.
%   If the input signal is real, the CQT is plotted over the range
%   [0,Fs/2]. If the signal is complex-valued, the CQT is plotted over
%   [0,Fs).
%
%   % Example:
%   %   Plot the constant-Q transform of a speech sample using the maximally 
%   %   redundant version of the transform and 48 bins per octave. Set the 
%   %   frequency limits from 100 to 6000 Hz.
%
%   load wavsheep;
%   cqt(sheep,'SamplingFrequency',fs,'BinsPerOctave',48,...
%   'FrequencyLimits',[100 6000])
%
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
%   See also ICQT

% Check number of input and output arguments
narginchk(1,11);
nargoutchk(0,6);

% Validate attributes on signal
validateattributes(x,{'double'},{'finite','nonempty','2d'},'CQT','X');

if isvector(x)
    N = numel(x);
    x = x(:);
    numsig = 1;
else
    % Columns as signals
    N = size(x,1);
    numsig = size(x,2);
end

% Plotting not supported for multidimensional inputs
if nargout == 0 && numsig > 1
    error(message('Wavelet:FunctionOutput:PlotTooManyDims'));
end

% Signal must have at least four samples
if N < 4
    error(message('Wavelet:synchrosqueezed:NumInputSamples'));
end

params = parseinputs(N,varargin{:});
if any(imag(x(:)))
    params.sigtype = 'complex';
end
Fs = params.Fs;
numbins = params.numbins;
fmin = params.freqlimits(1);
fmax = params.freqlimits(2);
% Nyquist frequency
NF = Fs/2;

% Set minimum bandwidth in DFT bins
minbw = 4;

%   Q-factor for CQ-NSGT and inverse for determining bandwidth Bandwidths
%   are $\varepsilon_{k+1}-\varepsilon_{k}$ where $\varepsilon_k$ is the
%   k-th center frequency. Described in Holighaus et. al. (2013). CQ-NSGT
%   Parameters: Windows and Lattices
Q = 1/(2^(1/numbins)-2^(-(1/numbins)));
% BW = CF*Q^(-1) so obtain 1/Q
Qinv = 1/Q;
%   Default number of octaves. Velasco et al., 2011 CQ-NSGT Parameters:
%   Windows and Lattices
bmax = ceil(numbins*log2(fmax/fmin)+1);


%   Note: fmin is rendered exactly. fmax is not necessarily
%   freq = fmin.*2.^((0:numbins*numoct-1)./numbins);
%   frequencies here are in hertz.  
freq = fmin.*2.^((0:bmax-1)./numbins);
freq = freq(:);

% Remove any bins greater than or equal to the Nyquist
% First find the first frequency greater than or equal to fmax, this should
% not be empty by construction. We will append the Nyquist so ensure we
% are not at the Nyquist or beyond.
idxgeqFmax = find(freq >= fmax,1,'first');
if freq(idxgeqFmax) >= NF
    freq = freq(1:idxgeqFmax-1);
else
    freq = freq(1:idxgeqFmax);
end

% First record number of bins, 1,....K prior to pre-pending DC and
% appending the Nyquist
Lbins = numel(freq);
% Now prepend DC and append Nyquist
freq = [0; freq; NF];
% Store Nyquist Bin
params.NyquistBin = Lbins+2;
% Store DC bin
params.DCBin = 1;
% Mirror other filters -- start with one bin below the Nyquist bin and go
% down to one bin above DC
freq = [freq; Fs-freq(end-1:-1:2)];

% Convert the frequency bins to approximate index of DFT bin.
fbins = freq*(N/Fs);

% Determine bandwidths in DFT bins. For everything but the DC bin and the
% Nyquist bins the bandwidth is \epsilon_{k+1}-\epsilon_{k-1}. Total number
% of bandwidths is now 2*Lbins+2
bw = zeros(2*Lbins+2,1);

%   Set bandwidth of DC bin to 2*fmin -- these are bandwidths in samples
%   (approximately), we will round to integer values.
bw(params.DCBin) = 2*fbins(2);
% Set Lbin 1 such that cf/bw = Q
bw(2) = fbins(2)*Qinv;
%   Set the bandwidth for the frequency before the Nyquist such that 
%   cf/bw = Q
bw(Lbins+1) = fbins(Lbins+1)*Qinv;
% Set the original k = 1,....K-1
idxk = [3:Lbins, params.NyquistBin];
% See Velasco et al. and Holighaus et al. CQ-NSGT Parameters: Windows
% and Lattices
bw(idxk) = fbins(idxk+1)-fbins(idxk-1);
% Mirror bandwidths on the negative frequencies
bw(Lbins+3:2*Lbins+2) = bw(Lbins+1:-1:2);
% Round the bandwidths to integers
bw = round(bw);

% Convert frequency centers to integers. Round down up to Nyquist. Round up
% after Nyquist.
cfbins = zeros(size(fbins));
% Up to Nyquist floor round down
cfbins(1:Lbins+2) = floor(fbins(1:Lbins+2));
% From Nyquist to Fs, round up
cfbins(Lbins+3:end) = ceil(fbins(Lbins+3:end));


% Compute the shift between filters in frequency in samples
diffLFDC = N-cfbins(end);
fshift = [diffLFDC; diff(cfbins)];

% Ensure that any bandwidth less than the minimum window is set to the
% minimum window
bw(bw<minbw) = minbw;


% Compute the frequency windows for the CQT-NSGFT
g = wavelet.internal.cswindow(params.winname,bw,Lbins);

% Obtain DFT of input signal
xdft = fft(x);

% Depending on transformtype value
if strcmpi(params.transformtype,'full')
    M = max(cellfun(@(x)numel(x),g))*ones(numel(g),1);
    [cfs,winfreqrange] = cqtfull(xdft,g,cfbins,M,params);
    
elseif strcmpi(params.transformtype,'reduced')
    M = zeros(size(bw));
    HFband = bw(params.NyquistBin-1);
    M([2:params.NyquistBin, params.NyquistBin+1:end]) = HFband;
    M(params.DCBin) = bw(params.DCBin);
    M(params.NyquistBin) = bw(params.NyquistBin);
    [cfs,winfreqrange] = cqtfull(xdft,g,cfbins,M,params);
    
elseif strcmpi(params.transformtype,'sparse')
    [cfs,winfreqrange] = cqtsparse(xdft,g,cfbins,bw,params);

end


if nargout == 0 

    % Plot if no output arguments
    if strcmpi(params.transformtype,'sparse')
        cfs = sparsecoefstofull(cfs,params);
    end
    
    plotcqt(cfs,freq,Fs,N,params);
    
else

    varargout{1} = cfs;
    varargout{2} = freq;
    varargout{3} = g;
    varargout{4} = fshift;
    varargout{5} = winfreqrange;
    varargout{6} = bw;
    
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [cfs,winfreqrange] = cqtsparse(xdft,g,cfbins,M,params)
Nwin = numel(g);
N = size(xdft,1);
winfreqrange = cell(Nwin,1);
numsig = size(xdft,2);
cfs = cell(numel(g),1);
% Algorithm for forward CQT due to Holighaus and Velasco
for kk = 1:Nwin
    Lg = numel(g{kk});
    % Note: Flip halves of windows. This centers the window at zero
    % frequency
    win_order = [ceil(Lg/2)+1:Lg,1:ceil(Lg/2)];
    % The following are the DFT bins corresponding to the frequencies in
    % the bandwidth of the window
    win_range = 1+mod(cfbins(kk)+(-floor(Lg/2):ceil(Lg/2)-1),N);
    winfreqrange{kk} = win_range;
    tmp = zeros(M(kk),numsig);
    % Multiply the DFT of the signal by the compactly supported window in
    % frequency. Then take the inverse Fourier transform to obtain the
    % CQT coefficients
    tmp(win_order,:) = ...
        xdft(win_range,:).*g{kk}(win_order);
    cfs{kk} = ifft(tmp);
    
end

if strcmpi(params.sigtype,'real')
    cfs = cellfun(@(x)(2*size(x,1))/N*x,cfs,'uni',0);
else
    cfs = cellfun(@(x)size(x,1)/N*x,cfs,'uni',0);
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [cfs,winfreqrange] = cqtfull(xdft,g,cfbins,M,params)
N = size(xdft,1);
Nwin = numel(g);
winfreqrange = cell(Nwin,1);
numsig = size(xdft,2);
% Using hop size of highest frequency band before the Nyquist.
cfstmp = cell(Nwin,1);
% Algorithm for forward CQT due to Holighaus and Velasco
for kk = 1:Nwin
    Lg = numel(g{kk});
    % Note: Flip halves of windows 
    win_order = [ceil(Lg/2)+1:Lg,1:ceil(Lg/2)];
    % The following are the DFT bins corresponding to the frequencies in
    % the bandwidth of the window
    win_range = 1+mod(cfbins(kk)+(-floor(Lg/2):ceil(Lg/2)-1),N);
    winfreqrange{kk} = win_range;
    rowdim = M(kk);
    tmp = zeros(M(kk),numsig);
    tmp([rowdim-floor(Lg/2)+1:rowdim,1:ceil(Lg/2)],:) = ...
        xdft(win_range,:).*g{kk}(win_order);
    cfstmp{kk} = ifft(tmp);
        
end

if strcmpi(params.sigtype,'real')
    cfstmp = cellfun(@(x)(2*size(x,1))/N*x,cfstmp,'uni',0);
else
    cfstmp = cellfun(@(x)size(x,1)/N*x,cfstmp,'uni',0);
end

if strcmpi(params.transformtype,'reduced')
    DCcfs = cfstmp{1};
    Nyqcfs = cfstmp{params.NyquistBin};
    cfstmp([1 params.NyquistBin]) = [];
    cfstmp = cell2mat(cfstmp);
    Numtpts = max(M(2:params.NyquistBin-1));
    c = reshape(cfstmp,Numtpts,Nwin-2,numsig);
    % Permute frequency and hop so that the coefficients matrices are
    % frequency by time
    c = permute(c,[2 1 3]);
    cfs = struct('c',c,'DCcfs',DCcfs,'Nyquistcfs',Nyqcfs,'NyquistBin',...
        params.NyquistBin);
else
    cfs = cell2mat(cfstmp);
    Numtpts = max(M);
    cfs = reshape(cfs,Numtpts,Nwin,numsig);
    % Permute frequency and hop so that the coefficients matrices are
    % frequency by time
    cfs = permute(cfs,[2 1 3]);
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function plotcqt(coefs,freq,Fs,L,params)
if strcmpi(params.sigtype,'real') && ...
        (strcmpi(params.transformtype,'full') || ...
        strcmpi(params.transformtype,'sparse'))
    freq = freq(1:params.NyquistBin);
    coefs = coefs(1:params.NyquistBin,:);
elseif strcmpi(params.sigtype,'real') && strcmpi(params.transformtype,'reduced')
    freq = freq(2:params.NyquistBin-1);
    % Nyquist frequency has already been removed from c field
    coefs = coefs.c(1:params.NyquistBin-2,:);
elseif strcmpi(params.sigtype,'complex') && strcmpi(params.transformtype,'reduced')
    freq([1 params.NyquistBin]) = [];
    coefs = coefs.c;
end

Numtimepts = size(coefs,2);
t = linspace(0,L*1/Fs,Numtimepts);

if params.NormalizedFrequency
    frequnitstrs = wgetfrequnitstrs;
    freqlbl = frequnitstrs{1};
    ut = 'Samples';
    xlbl = ...
        [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
    
else
    [freq,~,uf] = engunits(freq,'unicode');
    [t,~,ut] = engunits(t,'unicode','time');
    freqlbl = wgetfreqlbl([uf 'Hz']);
    xlbl = ...
        [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
    
end
ax = newplot;
hndl = surf(ax,t, freq, 20*log10(abs(coefs)+eps(0)));
hndl.EdgeColor = 'none';
axis xy; axis tight;
view(0,90);
h = colorbar;
h.Label.String = getString(message('Wavelet:FunctionOutput:dB'));
ylabel(freqlbl);
xlabel(xlbl);
title(getString(message('Wavelet:FunctionOutput:constantq')));

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function coefs = sparsecoefstofull(cfs,params)

if strcmpi(params.sigtype,'real')
    cfs = cfs(1:params.NyquistBin);
end

numcoefs = max(cellfun(@(x)numel(x),cfs));
coefs = zeros(numel(cfs),numcoefs);

for kk = 1:numel(cfs)
    tmp = cfs{kk};
    x = linspace(0,1,numel(tmp));
    xq = linspace(0,1,numcoefs);
    F = griddedInterpolant(x,tmp);
    F.Method = 'nearest';
    coefs(kk,:) = F(xq);
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function params = parseinputs(N,varargin)
params.sigtype = 'real';
params.NormalizedFrequency = true;
params.Fs = 1;
params.winname = 'hann';
p = inputParser;
addParameter(p,'SamplingFrequency',[]);
addParameter(p,'BinsPerOctave',12);
addParameter(p,'FrequencyLimits',[]);
addParameter(p,'Window','hann');
addParameter(p,'TransformType','full');
parse(p,varargin{:});
if ~isempty(p.Results.SamplingFrequency)
    params.NormalizedFrequency = false;
    params.Fs = p.Results.SamplingFrequency;
    validateattributes(params.Fs,{'numeric'},{'scalar','positive'},...
        'CQT','SamplingFrequency');
end


params.numbins = p.Results.BinsPerOctave;
validateattributes(params.numbins,{'numeric'},...
    {'integer','scalar','>=',1,'<=',96},'CQT','BinsPerOctave');
params.freqlimits = p.Results.FrequencyLimits;
if ~isempty(params.freqlimits)
    validateattributes(params.freqlimits,{'numeric'},{'numel',2,'positive','>=',params.Fs/N,...
        '<=',params.Fs/2,'increasing'},'CQT','FrequencyLimits');
end
params.transformtype = p.Results.TransformType;
validtypes = {'sparse','full'};
params.transformtype = ...
    validatestring(p.Results.TransformType,validtypes,'CQT','TransformType');
if ~isempty(params.freqlimits) && strcmpi(params.transformtype,'full')
    params.transformtype = 'reduced';
end
if isempty(params.freqlimits)
    params.freqlimits = [params.Fs/N params.Fs/2];
end
validwin = {'hann','hamming','itersine','blackmanharris','bartlett'};
params.winname = validatestring(p.Results.Window,validwin,'CQT','Window');
















