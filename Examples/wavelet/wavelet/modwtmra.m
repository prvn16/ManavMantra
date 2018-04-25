function mra = modwtmra(w,varargin)
%MODWTMRA Multiresolution analysis using the MODWT
%   MRA = MODWTMRA(W) returns the multiresolution analysis (MRA) of the
%   matrix W. W is a LEV+1-by-N matrix containing the MODWT of an N-point
%   input signal down to level LEV. By default, MODWMRA assumes that you
%   used the 'sym4' wavelet with periodic boundary handling to obtain
%   the MODWT. MRA is a LEV+1-by-N matrix where LEV is the level of the
%   MODWT and N is the length of the analyzed signal. The k-th row of MRA
%   contains the details for the k-th level. The LEV+1-th row of MRA
%   contains the LEV-th level smooth.
%
%   MRA = MODWTMRA(W,WNAME) constructs the MRA using the wavelet WNAME.
%   WNAME must be the same wavelet used in the analysis of the signal with
%   MODWT.
%
%   MRA = MODWTMRA(W,Lo,Hi) constructs the MRA using the scaling filter Lo
%   and wavelet filter Hi. Lo and Hi must be the same filters used in the
%   analysis of the signal with MODWT. You cannot specify both WNAME and
%   Lo and Hi.
%
%   MRA = MODWTMRA(...,'reflection') uses the 'reflection' boundary
%   condition in the construction of the MRA. If you specify 'reflection',
%   MODWTMRA assumes that the length of the original signal length is half
%   the number of columns in the input coefficient matrix. You must enter
%   the entire string 'reflection'. If you added a wavelet named
%   'reflection' using the wavelet manager, you must rename that wavelet
%   prior to using this option. 'reflection' may be placed in any position
%   in the input argument list after W. By default, MODWTMRA uses periodic
%   extension at the boundary.
%
%   % Example:
%   %   Obtain the MODWT of an ECG waveform using the 'sym4'
%   %   wavelet down to level four. Obtain and plot the MRA. The top plot
%   %   is the original ECG waveform.
%
%   load wecg;
%   lev = 4;
%   wt = modwt(wecg,'db2',lev);
%   mra = modwtmra(wt,'db2');
%   subplot(6,1,1);
%   plot(wecg);
%   for kk = 2:6
%       subplot(6,1,kk);
%       plot(mra(kk-1,:));
%   end
%
% See also modwt, imodwt

narginchk(1,4);

% The input to modwtmra must be a matrix
if (isrow(w) || iscolumn(w))
    error(message('Wavelet:modwt:MRASize'));
end

% Input must be finite, real-valued, and double precision
validateattributes(w,{'double'},{'real','nonnan','finite'});

params = parseinputs(varargin{:});
% get the size of the output coefficients
cfslength = size(w,2);
J0 = size(w,1)-1;

nullinput = zeros(1,cfslength);
N = cfslength;

boundary = params.boundary;
if (~isempty(boundary) && ~strcmpi(boundary,'reflection'))
    error(message('Wavelet:modwt:Invalid_Boundary'));
end

% Reduce output length by 1/2 if boundary is reflection
if strcmpi(boundary,'reflection')
    N = N/2;
end

% If wavelet specified as a string, ensure that wavelet is orthogonal
if (isfield(params,'wname') && ~isfield(params,'Lo'))
    [~,~,Lo,Hi] = wfilters(params.wname);
    wtype = wavemngr('type',params.wname);
    if (wtype ~= 1)
        error(message('Wavelet:modwt:Orth_Filt'));
    end
end


if (isfield(params,'Lo') && ~isfield(params,'wname'))
    filtercheck = wavelet.internal.CheckFilter(params.Lo,params.Hi);
    if ~filtercheck
        error(message('Wavelet:modwt:Orth_Filt'));
    end
    Lo = params.Lo;
    Hi = params.Hi;
end


% Scale filters for MODWT
Lo = Lo./sqrt(2);
Hi = Hi./sqrt(2);

if (cfslength<numel(Lo))
    w = [w repmat(w,1,ceil(numel(Lo)-cfslength))];
    cfslength = size(w,2);
    nullinput = zeros(1,cfslength);
end

G = fft(Lo,cfslength);
H = fft(Hi,cfslength);

% Allocate array for MRA
mra = zeros(J0+1,N);

for J = J0:-1:1
    wcfs = w(J,:);
    details = imodwtDetails(wcfs,nullinput,J,G,H,cfslength);
    details = details(1:N);
    mra(J,:) = details;
end
scalingcoefs = w(J0+1,:);
smooth = imodwtSmooth(scalingcoefs,nullinput,G,H,cfslength,J0);
mra(J0+1,:) = smooth(1:N);


%-----------------------------------------------------------------------
function details = imodwtDetails(coefs,nullinput,lev,Lo,Hi,N)
v = nullinput;
w = coefs;
for jj = lev:-1:1
    vout = imodwtrec(v,w,Lo,Hi,jj);
    w = nullinput;
    v = vout;
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

%-----------------------------------------------------------------
function Vout = imodwtrec(Vin,Win,G,H,J)
N = length(Vin);
Vhat = fft(Vin);
What = fft(Win);
upfactor = 2^(J-1);
Gup = conj(G(1+mod(upfactor*(0:N-1),N)));
Hup = conj(H(1+mod(upfactor*(0:N-1),N)));
Vout = ifft(Gup.*Vhat+Hup.*What);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function params = parseinputs(varargin)
% Parse varargin and check for valid inputs

params.boundary = [];
params.wname = 'sym4';

% See if user has specified 'reflection'
tfbound = strcmpi(varargin,'reflection');

if any(tfbound)
    params.boundary = varargin{tfbound>0};
    varargin(tfbound>0) = [];
end

if isempty(varargin)
    return;
end

% If any string has been specified it must be the wavelet
tfchar = cellfun(@ischar,varargin);

if any(tfchar)
    params.wname = varargin{tfchar>0};
end


tffilters = cellfun(@isnumeric,varargin);

if (nnz(tffilters)== 1 || nnz(tffilters) >2)
    error(message('Wavelet:modwt:Invalid_NumericMRA'));
end


if (nnz(tffilters)==2)
    idxFilt = find(tffilters,2,'first');
    params.Lo = varargin{idxFilt(1)};
    params.Hi = varargin{idxFilt(2)};
    if (length(params.Lo) < 2 || length(params.Hi) < 2)
        error(message('Wavelet:modwt:Invalid_Filt_Length'));
    end
    params = rmfield(params,'wname');
    
end

% If the user specifies a filter, use that instead of default wavelet
if (isfield(params,'Lo') && any(tfchar))
    error(message('Wavelet:FunctionInput:InvalidWavFilter'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%









