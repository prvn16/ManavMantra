function [wvar,wvarCI,NJ]   = modwtvar(w,varargin)
%MODWTVAR Maximal overlap discrete wavelet transform multiscale variance.
%   WVAR = MODWTVAR(W) returns unbiased estimates of the wavelet variance
%   by scale for the maximal overlap discrete wavelet transform (MODWT) in
%   the LEV+1-by-N matrix W where LEV is the level of the input MODWT. For
%   unbiased estimates, MODWTVAR returns variance estimates only where
%   there are nonboundary coefficients. This condition is satisfied when
%   the transform level is not greater than floor(log2(N/(L-1)+1)) where N
%   is the length of the input and L is the wavelet filter length. If there
%   are sufficient nonboundary coefficients at the final level, MODWTVAR
%   returns the scaling variance in the final element of WVAR. By default,
%   MODWTVAR uses the 'sym4' wavelet to determine the boundary
%   coefficients.
% 
%   WVAR = MODWTVAR(W,WAV) uses the wavelet WAV to determine the number of
%   boundary coefficients by level for unbiased estimates. WAV can be a
%   string corresponding to a valid wavelet or a positive even scalar
%   indicating the length of the wavelet and scaling filters. The wavelet
%   filter length must match the length used in the MODWT of the input. If
%   WAV is specified as empty, the default 'sym4' wavelet is used.
%
%   [WVAR,WVARCI] = MODWTVAR(...) returns 95% confidence intervals for the
%   variance estimates by scale. WVARCI is an M-by-2 matrix. The first
%   column of WVARCI contains the lower 95% confidence bound. The second
%   column of WVARCI contains the upper 95% confidence bound. By default,
%   MODWTVAR calculates the interval estimate using the chi-square
%   probability density with the equivalent degrees of freedom estimated
%   using the 'Chi2Eta3' confidence method.
%
%   [...] = MODWTVAR(W,WAV,ConfLevel) uses ConfLevel for the coverage
%   probability of the confidence interval. ConfLevel is a real scalar
%   strictly greater than 0 and less than 1, (0,1). If ConfLevel is
%   unspecified, or specified as empty, the coverage probability defaults
%   to 0.95. 
% 
%   [...] = MODWTVAR(...,'EstimatorType',EstimatorType) uses EstimatorType
%   to compute variance estimates and confidence bounds. EstimatorType may
%   be one of 'unbiased' or 'biased'. If unspecified, EstimatorType
%   defaults to 'unbiased'. The unbiased estimate identifies and removes
%   boundary coefficients prior to computing the variance estimates and
%   confidence bounds. The 'biased' estimate uses all coefficients to
%   compute the variance estimates and confidence bounds. Unbiased
%   estimates are preferred. You must specify WAV and ConfLevel or specify
%   those inputs as empty, [], for the defaults before using the name-value
%   pair EstimatorType: modwtvar(W,[],[],'EstimatorType','biased').
%
%   [...] = MODWTVAR(...,'ConfidenceMethod',ConfidenceMethod) uses
%   ConfidenceMethod to compute the confidence intervals. ConfidenceMethod
%   may be one of 'Chi2Eta3', 'Chi2Eta1', or 'Gaussian'. The default is
%   'Chi2Eta3'. 'Gaussian' may result in a lower bound that is negative.
%   You must specify WAV and ConfLevel or specify those inputs as empty,
%   [], for the defaults before using the name-value pair ConfidenceMethod.
%   For example, modwtvar(W,[],[],'ConfidenceMethod','Gaussian').
%
%   WVAR = MODWTVAR(...,'Boundary',Boundary) uses the specified boundary to
%   compute the variance estimates and confidence bounds. Boundary may be
%   one of 'periodic' or 'reflection'. If unspecified, Boundary defaults to
%   'periodic'. If the MODWT was acquired using 'reflection' boundary
%   handling, you must specify the Boundary as 'reflection' in MODWTVAR to
%   obtain a correct unbiased estimate. If you are using biased estimators,
%   all the coefficients are used in forming the variance estimates and
%   confidence intervals regardless of the boundary handling. You must
%   specify WAV and ConfLevel or specify those inputs as empty, [], for the
%   defaults before using the name-value pair Boundary. For example,
%   modwtvar(W,[],[],'Boundary','reflection').
%
%   [WVAR,WVARCI,NJ] = MODWTVAR(...) returns the number of coefficients
%   used in forming the variance and confidence intervals by level. For
%   unbiased estimates, NJ represents the number of nonboundary
%   coefficients and decreases by level. For biased estimates, NJ is a
%   vector of constants equal to the number of columns in the input matrix.
%
%   WVAR = MODWTVAR(...,'table') outputs a MATLAB table with the following
%   variables:
%       NJ          The number of MODWT coefficients by level. For unbiased
%                   estimates, NJ represents the number of nonboundary
%                   coefficients. For biased estimates, NJ is the number of
%                   coefficients in the MODWT.
%       Lower       The lower confidence bound for the variance estimate.
%       Variance    The variance estimate by level. 
%       Upper       The upper confidence bound for the variance estimate.
%
%   You can specify the 'table' option anywhere after the input MODWT, W as
%   long as you do not split up a name-value pair. If you specify 'table', 
%   MODWTVAR only outputs one argument.
%
%   The row names of the table WVAR designate the type and level of each
%   estimate. For example, D1 designates that the row corresponds to a
%   wavelet or detail estimate at level 1 and S6 designates that the row
%   corresponds to the scaling estimate at level 6. The scaling variance is
%   only computed for the final level of the MODWT. For unbiased estimates,
%   MODWTVAR computes the scaling variance only when there are nonboundary
%   scaling coefficients.
%
%   MODWTVAR(...) with no output arguments plots the wavelet variances by
%   scale with lower and upper confidence bounds. Because the scaling
%   variance can be much larger than the wavelet variances, the scaling
%   variance is excluded from the plot.
%   
%   %Example 1: 
%   %   Obtain and plot estimates of the wavelet variance by scale 
%   %   for the Kobe earthquake data. 
%
%   load kobe;
%   wkobe = modwt(kobe);
%   modwtvar(wkobe)
%
%   %Example 2:
%   %   Obtain estimates of the wavelet variance by scale for the Southern
%   %   Oscillation Index (SOI) data.
%   
%   load soi;
%   wsoi = modwt(soi);
%   soivar = modwtvar(wsoi,'table')
%
%   % Plot the SOI variance by scale
%   modwtvar(wsoi)
%
%   See also MODWT, MODWTCORR, MODWTXCORR, MODWTMRA, IMODWT

% Minimum number of inputs is 1 and maximum is 10
narginchk(1,10)

% Ensure that the input has at least two rows
if (isrow(w) || iscolumn(w))
    error(message('Wavelet:modwt:InvalidCFSSize'));
end

% Input must be double-precision and real-valued with no NaNs or Infs
validateattributes(w,{'double'},{'real','nonnan','finite'});


% Declare defaults in the params struct array
params.boundary = 'periodic';
params.ConfMethod = 'chi2eta3';
params.ConfLevel = 0.95;
params.EstimatorType = 'unbiased';
params.L = 8;  % Length of default 'sym4' wavelet filter
params.tableflag = false;
scalingvar = false;

% Parse user-supplied inputs

params = parseinputs(params,varargin{:});

% Filter length
filtlen = params.L;

% Get the level -- the final row of w are the scaling coefficients
level = size(w,1)-1;

% Extract scaling coefficients
VJ = w(end,:);

% Extract wavelet coefficients
w = w(1:end-1,:);

% make sure that we do not compute the variance where they are no
% nonboundary coefficients

if (strcmpi(params.boundary,'reflection') && strcmpi(params.EstimatorType,'unbiased'))
    if mod(size(w,2),2)
        error(message('Wavelet:modwt:EvenLengthInput'));
    end
    N = size(w,2)/2;    
else
    N = size(w,2);
end


% For an unbiased estimate
if strcmpi(params.EstimatorType,'unbiased')
 Jmax = floor(log2((N-1)/(filtlen-1)+1));
 if (Jmax<1)
     error(message('Wavelet:modwt:ZeroNonBoundaryCFS'));
 end
 Jmax = min(Jmax,level);
 w = w(1:Jmax,1:N);
 VJ = VJ(1:N);
 
 %Determine if we use the scaling coefficients
    if (Jmax-level==0)
         scalingvar = true;
    end
    
% Remove boundary coefficients for unbiased estimate
[cfs,MJ] = removemodwtboundarycoeffs(w,VJ,N,Jmax,filtlen,scalingvar);

else
    scalingvar = true;
    Jmax = level;
    % For biased estimates use the entire coefficient matrix 
    % Includes scaling variance
    cfs = [w ; VJ];
    MJ = size(cfs,2)*ones(1,Jmax+1);
end



%Allocate arrays for wvartmp and AJ
wvartmp = NaN(1,size(cfs,1));
%wvartmp = zeros(1,size(cfs,1));
AJ = zeros(1,size(cfs,1));

% Calculate the estimate of the wavelet variance
for jj = 1:size(cfs,1)
    cfsNoNaN = cfs(jj,~isnan(cfs(jj,:)));
    wacs = modwtACS(cfsNoNaN,MJ(jj));
    %wvar(jj) = sum(abs(cfsNoNaN).^2)/MJ(jj);
    wvartmp(jj) = wacs(1);
    AJ(jj) = wacs(1)^2/2+sum(abs(wacs(2:end)).^2);
        
end

% Obtain critical value for Chi-square or Gaussian PDFs.
critvalue = (1+params.ConfLevel)/2;

J = 1:Jmax;

% If scalingvar is true we append the final level to represent
% the final-level scaling coefficients

      if scalingvar
        J = [J Jmax];      
      end

switch lower(params.ConfMethod)
    case 'chi2eta3'      
      % EDOF calculation
      etatmp = MJ./2.^J;
      eta = max(etatmp,1);
      % chi-square lower and upper critical values
      lowercritvalues = 2*gammaincinv(critvalue,eta/2);
      uppercritvalues = 2*gammaincinv(1-critvalue,eta/2);
      lowerci = (eta.*wvartmp)./lowercritvalues;
      upperci = (eta.*wvartmp)./uppercritvalues;
      
    case 'chi2eta1'
        eta = modwtEDOF(wvartmp,MJ,AJ);
        lowercritvalues = 2*gammaincinv(critvalue,eta/2);
        uppercritvalues = 2*gammaincinv(1-critvalue,eta/2);
        lowerci = (eta.*wvartmp)./lowercritvalues;
        upperci = (eta.*wvartmp)./uppercritvalues;
        
    case 'gaussian'
        critvalue = -sqrt(2)*erfcinv(2*critvalue);
        lowerci = wvartmp-critvalue*sqrt(2*AJ./MJ);
        upperci = wvartmp+critvalue*sqrt(2*AJ./MJ);
        
end


% Concatenate lower and upper confidence bounds with variance
% estimates
wvartmp = [lowerci' wvartmp' upperci'];

if nargout >1 && params.tableflag
    error(message('Wavelet:modwt:InvalidOutput'));
end

if nargout>=1 && ~params.tableflag
    wvar = wvartmp(:,2);
    wvarCI = [lowerci' upperci'];
    NJ = MJ';
end

if nargout ==1 && params.tableflag
% Create row names for table
rownames = cell(numel(J),1);
    for ii = 1:numel(J)
        rownames{ii} = sprintf('D%d',J(ii));
    end

    if scalingvar
        rownames{end} = sprintf('S%d',level);
    end


wvar = [MJ' wvartmp];
wvar = array2table(wvar,'VariableNames',{'NJ','Lower','Variance','Upper'},...
    'RowNames',rownames);
end

if nargout == 0
    plotmodwtvar(wvartmp,scalingvar);
end



%--------------------------------------------------------------------%
function wacs = modwtACS(cfs,MJ)
N = size(cfs,2);
cfs = bsxfun(@minus,cfs,mean(cfs));
fftpad = 2^nextpow2(2*N);
wacsDFT = fft(cfs,fftpad,2).*conj(fft(cfs,fftpad,2));
wacs = ifftshift(ifft(wacsDFT,[],2),2);
wacs = 1/MJ*(wacs(fftpad/2+1:fftpad/2+MJ));
%-------------------------------------------------------------------%

%-------------------------------------------------------------------%
function eta1 = modwtEDOF(wvar,MJ,AJ)
eta1 = (MJ.*wvar.^2)./AJ;

%-------------------------------------------------------------------%
function params = parseinputs(params,varargin)

tftable = strcmpi('table',varargin);
if any(tftable)
    params.tableflag = true;
    varargin(tftable>0) = [];
end

% If varargin is empty, use defaults
if isempty(varargin)
    return;
end

Len = length(varargin);

% The wavelet must be the first input argument in varargin after removing
% the 'table' flag

wavlen = varargin{1};

% Handle cases where the wavelet is a string or a scalar
% empty

if ischar(wavlen)
    [~,~,Lo,~] = wfilters(wavlen);
    params.L = length(Lo);
elseif isscalar(wavlen)
    params.L = wavlen;
elseif isempty(wavlen)
    params.L = 8;
else
    error(message('Wavelet:modwt:InvalidWavelet'));
end

% The wavelet length must be a positive integer
validateattributes(params.L,{'numeric'},{'real','positive','even'});


% If there is more than one variable input, the second input must be the
% confidence level
if (Len>1)
    params.ConfLevel = varargin{2};
    if isempty(params.ConfLevel)
        params.ConfLevel = 0.95;
    end
end

%Check that the confidence level is valid
validateattributes(params.ConfLevel,{'numeric'},{'scalar','>',0,'<',1});

if Len>2
    varargin = varargin(3:end);
else
    return;
    
end

% Parse any PV pairs
if mod(length(varargin),2)
    error(message('Wavelet:modwt:PVPairs'));
end

varargin = lower(varargin);
Npv = length(varargin);
Npv = Npv/2;

varname = cell(Npv,1);
varvalue = cell(Npv,1);

for ii = 1:Npv
    varname{ii} = varargin{2*ii-1};
    varvalue{ii} = varargin{2*ii};
end

% Look for valid names in the Name-Value pairs
tfconfmethod = strncmp(varname,'confidencemethod',1);
tfesttype = strncmp(varname,'estimatortype',1);
tfboundary = strncmp(varname,'boundary',1);

if any(tfconfmethod)
    params.ConfMethod = ...
        validatestring(char(varvalue(tfconfmethod>0)),{'chi2eta1','chi2eta3','gaussian'});
end

if any(tfesttype)
    params.EstimatorType = ...
        validatestring(char(varvalue(tfesttype>0)),{'biased','unbiased'});
end

if any(tfboundary)
    params.boundary = ...
        validatestring(char(varvalue(tfboundary>0)),{'periodic','reflection'});
end

%---------------------------------------------------------------------
function plotmodwtvar(wvartmp,scalingvar)
% Plots the estimates of the wavelet variance by scale. Because the scaling
% variance is often much larger than the wavelet variances, we do not plot
% the scaling variance here.
if scalingvar
    wvar = wvartmp(1:end-1,:);
else
    wvar = wvartmp;
end


levels = 1:size(wvar,1);
wavescale = 2.^levels;

varest = wvar(:,2);
lower = varest-wvar(:,1);
upper = wvar(:,3)-varest;
      
errorbar(log2(wavescale),varest,lower,upper,'bx','markersize',12,...
    'markerfacecolor',[0 0 1]);
grid on;
Ax = gca;
Ax.XLim = [-0.25 levels(end)+0.5];
Ax.XTick = log2(wavescale);
xlabel('Log(scale) -- base 2');
ylabel('Variance');
title('Wavelet Variance by Scale'); 








   


    





    













