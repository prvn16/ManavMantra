function varargout = wdenoise(x,varargin)
% WDENOISE Wavelet signal denoising
%   XDEN = WDENOISE(X) denoises the data in X using an empirical Bayesian
%   method with a Cauchy prior. The 'sym4' wavelet is used with a posterior
%   median threshold rule. Denoising is down to the minimum of
%   floor(log2(N)) and wmaxlev(N,'sym4') where N is the number of samples
%   in the data. X is a real-valued vector, matrix, or timetable. If X is a
%   matrix, WDENOISE denoises each column of X. If X is a timetable, X must
%   contain real-valued vectors in separate variables, or one real-valued
%   matrix of data. X cannot contain both vectors and matrices or multiple
%   matrices. X is assumed to be uniformly sampled. If X is a
%   timetable and the timestamps are not linearly spaced, WDENOISE issues a
%   warning.
%
%   XDEN is the denoised vector, matrix, or timetable version of X. For a
%   timetable input, XDEN has the same variable names and timestamps as the
%   original timetable.
%
%   XDEN = WDENOISE(X,LEVEL) denoises X down to LEVEL. LEVEL is a positive
%   integer less than or equal to floor(log2(N)) where N is the number of
%   samples in the data. If unspecified, LEVEL defaults to the minimum of
%   floor(log2(N)) and wmaxlev(N,'sym4'). For James-Stein block
%   thresholding, 'BlockJS', there must be floor(log(N)) coefficients at
%   the coarsest resolution level, LEVEL.
%
%   XDEN = WDENOISE(...,'Wavelet',WNAME) uses the orthogonal or
%   biorthogonal wavelet WNAME for denoising. Orthogonal and biorthogonal
%   wavelets are designated as type 1 and type 2 wavelets respectively in
%   the wavelet manager. Valid built-in orthogonal wavelet families begin
%   with 'haar', 'dbN', 'fkN', 'coifN', or 'symN' where N is the number of
%   vanishing moments for all families except 'fk'. For 'fk', N is the
%   number of filter coefficients. Valid biorthogonal wavelet families begin
%   with 'biorNr.Nd' or 'rbioNd.Nr', where Nr and Nd are the number of
%   vanishing moments in the reconstruction (synthesis) and decomposition
%   (analysis) wavelet. Determine valid values for the vanishing moments by
%   using waveinfo with the wavelet family short name. For example, enter
%   waveinfo('db') or waveinfo('bior'). Use wavemngr('type',WNAME) to
%   determine if a wavelet is orthogonal (returns 1) or biorthogonal
%   (returns 2).   
%
%   XDEN = WDENOISE(...,'DenoisingMethod',DMETHOD) uses the denoising
%   method DMETHOD to determine the denoising thresholds for the data X.
%   DMETHOD can be one of 'BlockJS','Bayes','FDR','Minimax','SURE', or
%   'UniversalThreshold'. If unspecified, DMETHOD defaults to the empirical
%   Bayesian method, 'Bayes'.
%
%       * For 'FDR', there is an optional argument for the Q-value, which
%       is the proportion of false positives. Q is a real-valued scalar
%       between 0 and 1/2, (0<Q<=1/2). To specify FDR with a Q-value, use a
%       cell array where the second element is the Q-value. For example,
%       'DenoisingMethod',{'FDR',0.01}. If unspecified, Q defaults to 0.05.
%
%   XDEN = WDENOISE(...,'ThresholdRule',THRESHRULE) uses the threshold rule
%   THRESHRULE to shrink the wavelet coefficients. THRESHRULE is valid for
%   all denoising methods but the valid options and defaults depend on the
%   denoising method.
%
%   THRESHRULE valid options for the denoising methods:
%   For 'BlockJS', the only supported option is 'James-Stein'. You do not
%   need to specify THRESHRULE for 'BlockJS'.
%
%   For 'SURE','Minimax', and 'UniversalThreshold', valid options are
%   'Soft' or 'Hard'. The default is 'Soft'.
%
%   For 'Bayes', valid options are 'Median', 'Mean', 'Soft', or
%   'Hard'. The default is 'Median'.
%
%   For 'FDR', the only supported option is 'Hard'. You do not need to
%   specify THRESHRULE for 'FDR'.
%
%   XDEN = WDENOISE(...,'NoiseEstimate',NOISEESTIMATE) estimates the
%   variance of the noise in the data using NOISEESTIMATE. Valid options
%   are 'LevelIndependent' and 'LevelDependent'. If unspecified, the
%   default is 'LevelIndependent'. 'LevelIndependent' estimates the
%   variance of the noise based on the finest-scale (highest-resolution)
%   wavelet coefficients. 'LevelDependent' estimates the variance of the
%   noise based the wavelet coefficients at each resolution level. For the
%   block James-Stein estimator ('BlockJS'), 'LevelIndependent' is the only
%   supported option.
%
%   [XDEN,DENOISEDCFS] = WDENOISE(...) returns the denoised wavelet and
%   scaling coefficients in the cell array DENOISEDCFS. The elements of
%   DENOISEDCFS are in order of decreasing resolution. The final element of
%   DENIOSEDCFS contains the approximation (scaling) coefficients.
%
%   [XDEN,DENOISEDCFS,ORIGCFS] = WDENOISE(...) returns the original wavelet
%   and scaling coefficients in the cell array ORIGCFS. The elements of
%   ORIGCFS are in order of decreasing resolution. The final element of
%   ORIGCFS contains the approximation (scaling) coefficients.
%
%   %Example 1
%   % Denoise a noisy frequency-modulated signal using the default Bayesian
%   % method.
%
%   load noisdopp;
%   xden = wdenoise(noisdopp);
%   plot([noisdopp' xden'])
%
%   %Example 2
%   % Denoise a timetable of noisy data down to level 5 using block
%   % thresholding.
%
%   load wnoisydata
%   xden = wdenoise(wnoisydata,5,'DenoisingMethod','BlockJS');
%   hl = plot(wnoisydata.t,[wnoisydata.noisydata(:,1) xden.noisydata(:,1)]);
%   hl(2).LineWidth = 2; legend('Original','Denoised');

% Check number of output arguments: denoised signal, denoised coefficients,
% original coefficients
nargoutchk(0,3);
% Check number of input arguments
narginchk(1,10);

% Handle both timetable and vector inputs
TTable = false;
if istimetable(x)
    tt = x;
    TTable = true;
    % Check whether the time-table is valid for WDENOISE
    
    % Get the RowTimes from the timetable
    SampleTimes = tt.Properties.RowTimes;
    % Convert the RowTimes from a duration or datetime array to
    % time vector.
    times = wavelet.internal.convertDuration(SampleTimes);
    % Check the time vector for uniform sampling
    Tunif = wavelet.internal.isuniform(times);
    if ~Tunif
        warning(message('Wavelet:FunctionInput:NonuniformlySampled'));
    end
    % validate that the times are increasing
    validateattributes(times,{'double'},{'increasing'},'WDENOISE','RowTimes');
    % Extract valid numeric data from time table
    % Return VariableNames as cell array
    [x,VariableNames] = wavelet.internal.CheckAndExtractTT(tt);
end

% Validate the data
validateattributes(x,{'double'},{'real','nonempty','finite','2d'},'WDENOISE','X');
IsRow = isrow(x);

% Work on column vectors -- return orientation to row on output if needed
if isvector(x) && IsRow
    x = x(:);
end

N = size(x,1);
if N < 2
   error(message('Wavelet:modwt:LenTwo'));
end

params = parseinputs(N,varargin{:});

% The following denoising methods are handled by wden()
if any(strcmpi(params.DenoisingMethod,{'SURE','UniversalThreshold','Minimax'}))
    DJIn = DJInputs(x,params);
    [xden,denoisedcfs,origcfs] = ...
        wavelet.internal.DonohoJohnstone(DJIn{:});
    % Denoising by FDR
elseif strcmpi(params.DenoisingMethod,'fdr')
    FDRin = FDRInputs(x,params);
    [xden,denoisedcfs,origcfs] = wavelet.internal.FDRDenoise(FDRin{:});
elseif strcmpi(params.DenoisingMethod,'Bayes')
    % Denoising with empirical Bayes
    Ebayesin = ebayesInputs(x,params);
    [xden,denoisedcfs,origcfs] = wavelet.internal.ebayesdenoise(Ebayesin{:});
elseif strcmpi(params.DenoisingMethod,'BlockJS')
    % Denoising by block JS
    blockin = blockInputs(x,params);
    [xden,denoisedcfs,origcfs] = wavelet.internal.blockthreshold(blockin{:});
end

% Return row vector if input is row vector
if IsRow
    xden = xden.';
end

if TTable
    % Create timetable output
    xden = wavelet.internal.createTimeTable(SampleTimes,xden,VariableNames);
    
end
% Assign variable number output arguments -- keep MATLAB convention of
% returning one output as ans
if nargout <= 1
    varargout = {xden};
elseif nargout == 2
    varargout = {xden,denoisedcfs};
elseif nargout == 3
    varargout = {xden,denoisedcfs,origcfs};
end

%-------------------------------------------------------------------------
function params = parseinputs(N,varargin)
params.DenoisingMethod = [];
params.NoiseEstimate = [];
params.ThresholdRule = [];
params.Q = [];
params.Wavelet = 'sym4';
% Assign default level. Edge case is when wmaxlev(N,'sym4') == 0 
if wmaxlev(N,'sym4') == 0
    params.Level = floor(log2(N));
elseif wmaxlev(N,'sym4')>0
    params.Level = min(wmaxlev(N,'sym4'),floor(log2(N)));
end
maxlev = floor(log2(N));

% See if a level is specified
levelidx = cellfun(@(x) isscalar(x) && ~ischar(x) && ~isstring(x),varargin);


if any(levelidx) && nnz(levelidx)==1
    params.Level = varargin{levelidx};
    validateattributes(params.Level,{'numeric'},...
        {'integer','scalar','<=',maxlev,'>=',1},'WDENOISE','LEVEL');
    varargin(levelidx) = [];
    
elseif nnz(levelidx) > 1
    error(message('Wavelet:FunctionInput:Invalid_LevelInput'));
end

% If varargin is empty, use default denoising method, noise estimate
% and wavelet
if isempty(varargin)
    params.DenoisingMethod = 'Bayes';
    params.ThresholdRule = 'Median';
    params.NoiseEstimate = 'LevelIndependent';
    params.Wavelet = 'sym4';
    
    return;
end


% valid denoising methods
validDenoisingMethod = {'SURE','Bayes',...
    'UniversalThreshold','FDR','Minimax','BlockJS'};

% valid noise estimation schemes
validNoiseEstimate = {'LevelIndependent','LevelDependent'};

% valid thresholding rules -- string comparisons will be case-insensitive
% and partial matching is supported
validThreshRule = {'soft','hard'};
validFDRRule = {'hard'};
validblockJSRule = {'James-Stein'};
validBayesRules = {'median','mean','soft','hard'};

p = inputParser;
addParameter(p,"Wavelet",params.Wavelet);
addParameter(p,"DenoisingMethod",[]);
addParameter(p,"NoiseEstimate",[]);
addParameter(p,"ThresholdRule",[]);
parse(p,varargin{:});
params.DenoisingMethod = p.Results.DenoisingMethod;

% Only for FDR is a cell array input support
if iscell(params.DenoisingMethod)
    params.Q = params.DenoisingMethod{2};
    validateattributes(params.Q,{'numeric'},{'scalar','nonempty','>',0,'<=',1/2},...
        'WDENOISE','Q');
    params.DenoisingMethod = params.DenoisingMethod{1};
    
end
if ~isempty(params.DenoisingMethod)
    params.DenoisingMethod = validatestring(params.DenoisingMethod,validDenoisingMethod, 'WDENOISE', 'DMETHOD');
else
    % Default denoising method is Bayesian
    params.DenoisingMethod = 'Bayes';
end

params.NoiseEstimate = p.Results.NoiseEstimate;
if ~isempty(params.NoiseEstimate)
    params.NoiseEstimate = validatestring(params.NoiseEstimate,validNoiseEstimate);
else
    % Default noise estimation scheme
    params.NoiseEstimate = 'LevelIndependent';
end

params.ThresholdRule = p.Results.ThresholdRule;

if ~isempty(params.ThresholdRule) && ~any(strcmpi(params.DenoisingMethod,{'Bayes','FDR','BlockJS'}))
    params.ThresholdRule = validatestring(params.ThresholdRule,validThreshRule, 'WDENOISE', 'THRESHRULE');
elseif ~isempty(params.ThresholdRule) && strcmpi(params.DenoisingMethod,'FDR')
    params.ThresholdRule = validatestring(params.ThresholdRule, validFDRRule, 'WDENOISE', 'THRESHRULE');
elseif ~isempty(params.ThresholdRule) && strcmpi(params.DenoisingMethod,'blockJS')
    params.ThresholdRule = validatestring(params.ThresholdRule,validblockJSRule, 'WDENOISE', 'THRESHRULE');
elseif ~isempty(params.ThresholdRule) && strcmpi(params.DenoisingMethod,'Bayes')
    params.ThresholdRule = validatestring(params.ThresholdRule,validBayesRules, 'WDENOISE', 'THRESHRULE');
elseif isempty(params.ThresholdRule) && strcmpi(params.DenoisingMethod,'FDR')
    params.ThresholdRule = 'hard';
elseif isempty(params.ThresholdRule) && any(strcmpi(params.DenoisingMethod,{'SURE','UniversalThreshold','Minimax'}))
    params.ThresholdRule = 'Soft';
elseif isempty(params.ThresholdRule) && strcmpi(params.DenoisingMethod,'Bayes')
    params.ThresholdRule = 'median';
end


params.Wavelet = p.Results.Wavelet;
wtype = wavemngr('fields',params.Wavelet,'type');
if (wtype ~= 1) && (wtype ~= 2)
    error(message('Wavelet:FunctionInput:OrthorBiorthWavelet'));
end




%------------------------------------------------------------------------
function DJIn = DJInputs(x,params)
% Prepare inputs for WDEN() call
switch lower(params.DenoisingMethod)
    case 'sure'
        params.DenoisingMethod = 'rigrsure';
    case 'universalthreshold'
        params.DenoisingMethod = 'sqtwolog';
    case 'minimax'
        params.DenoisingMethod = 'minimaxi';
end



switch lower(params.ThresholdRule)
    case 'soft'
        params.ThresholdRule = 's';
    case 'hard'
        params.ThresholdRule = 'h';
end

DJIn = {x,params.Level,params.Wavelet,params.DenoisingMethod,params.ThresholdRule,...
    params.NoiseEstimate};
%------------------------------------------------------------------------
function ebayesin = ebayesInputs(x,params)
ebayesin = {x,params.Wavelet,params.Level,params.NoiseEstimate,...
    params.ThresholdRule};


%------------------------------------------------------------------------
function blockin = blockInputs(x,params)
% lambda is solution of equation
% \lambda \ln{(3)} - 3 = 0
% See section 6 for the derivation of the values for \lambda and L
%
% Cai, T.T. (1999) Adaptive wavelet estimation: A block thresholding and
% oracle inequality approach. The Annals of Statistics, 27(3), 898-924.

lambda = 4.50524;
L = floor(log(size(x,1)));

blockin = {x,params.Wavelet,params.Level,lambda,L};




%------------------------------------------------------------------------
function FDRin = FDRInputs(x,params)
FDRin = {x,params.Wavelet,params.Level,params.Q,params.NoiseEstimate};

















