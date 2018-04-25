function [wcoh,wcs,P,coi] = wcoherence(x,y,varargin)
%Wavelet coherence
% WCOH = WCOHERENCE(X,Y) returns the magnitude-squared wavelet coherence
% between the equal-length 1-D real-valued signals X and Y using the
% analytic Morlet wavelet. X and Y must have at least 4 samples. The
% wavelet coherence is computed over logarithmic scales using 12 voices per
% octave. The number of octaves is equal to floor(log2(numel(X)))-1.
%
% [WCOH,WCS] = WCOHERENCE(X,Y) returns the wavelet cross spectrum of X and
% Y in WCS.
%
% [WCOH,WCS,PERIOD] = WCOHERENCE(X,Y,Ts) uses the positive <a href="matlab:help duration">duration</a>, Ts,
% to compute the scale-to-period conversion, PERIOD. PERIOD is
% an array of durations with the same Format property as Ts.
%
% [WCOH,WCS,F] = WCOHERENCE(X,Y,Fs) uses the positive sampling frequency,
% Fs, in hertz to compute the scale-to-frequency conversion, F. If you
% output F without specifying a sampling frequency, WCOHERENCE uses
% normalized frequency in cycles/sample. The Nyquist frequency is 1/2.
% You cannot specify both a sampling frequency and a duration.
%
% [WCOH,WCS,F,COI] = WCOHERENCE(...) returns the cone of influence in
% cycles/sample for the wavelet coherence. If you specify a sampling
% frequency, Fs, in hertz, the cone of influence is returned in hertz.
%
% [WCOH,WCS,PERIOD,COI] = WCOHERENCE(...,Ts) returns the cone of influence
% in periods for the wavelet coherence. Ts is a positive <a href="matlab:help duration">duration</a>. COI is
% an array of durations with same Format property as Ts.
%
% [...] = WCOHERENCE(...,'VoicesPerOctave',NV) specifies the number of
% voices per octave to use in the wavelet coherence. NV is an integer in
% the range [10,32].
%
% [...] = WCOHERENCE(...,'NumScalesToSmooth', NS) specifies the number of
% scales to smooth as a positive integer less than one half the number of
% scales. If unspecified, NS defaults to the number of voices per octave. A
% moving average filter is used to smooth across scale.
%
% [...] = WCOHERENCE(...,'NumOctaves',NOCT) specifies the number of
% octaves to use in the wavelet coherence. NOCT is a positive integer
% between 1 and floor(log2(numel(X)))-1. If unspecified, NOCT defaults to
% floor(log2(numel(X)))-1.
%
% WCOHERENCE(...) with no output arguments plots the wavelet coherence in
% the current figure window along with the cone of influence. For areas
% where the coherence exceeds 0.5, arrows are also plotted to show the
% phase lag between X and Y. The phase is plotted as the lag between Y and
% X. The arrows are spaced in time and scale. 
%
% WCOHERENCE(...,'PhaseDisplayThreshold',PT) displays phase vectors for
% regions of coherence greater than or equal to PT. PT is a real-valued
% scalar between 0 and 1. This name-value pair is ignored if you call
% WCOHERENCE with output arguments.
%
%   % Example 1:
%   %   Plot the wavelet coherence for two signals. Both signals consist
%   %   of two sine waves (10 and 50 Hz) in white noise. The sine waves
%   %   have different time supports. The sampling interval frequency is
%   %   1000 Hz.
%   t = 0:0.001:2;
%   x = cos(2*pi*10*t).*(t>=0.5 & t<1.1)+ ...
%       cos(2*pi*50*t).*(t>= 0.2 & t< 1.4)+0.25*randn(size(t));
%   y = sin(2*pi*10*t).*(t>=0.6 & t<1.2)+...
%       sin(2*pi*50*t).*(t>= 0.4 & t<1.6)+ 0.35*randn(size(t));
%   wcoherence(x,y,1000)
%
%   % Example 2:
%   %   Plot the wavelet coherence between the El Nino time series and the
%   %   All Indian Average Rainfall Index. The data are sampled monthly.
%   %   Set the phase display threshold to 0.7. Specify the sampling
%   %   interval as 1/12 of a year to display the periods in years.
%   load ninoairdata;
%   wcoherence(nino,air,years(1/12),'phasedisplaythreshold',0.7);
%
%   See also cwtft, duration


narginchk(2,12);
nargoutchk(0,4);

%Check input vector size
nx = numel(x);
ny = numel(y);
if (~isequal(nx,ny) || numel(x) < 4)
    error(message('Wavelet:FunctionInput:EqualLengthInput'));
end
validateattributes(x,{'numeric'},{'real','finite'},'wcoherence','X');
validateattributes(y,{'numeric'},{'real','finite'},'wcoherence','Y');

% Form signals as row vectors
x = x(:)';
y = y(:)';


params = parseinputs(numel(x),varargin{:});

% Get number of voices per octave
nv = params.nv;

% If sampling frequency is specified, dt = 1/fs
if (isempty(params.fs) && isempty(params.Ts))
    % The default sampling interval is 1 for normalized frequency
    dt = params.dt;
    
elseif (~isempty(params.fs) && isempty(params.Ts))
    % Accept the sampling frequency in hertz
    fs = params.fs;
    dt = 1/fs;
elseif (isempty(params.fs) && ~isempty(params.Ts))
    % Get the dt and Units from the duration object
    [dt,Units] = getDurationandUnits(params.Ts);
    
    
end

mc = params.mincoherence;
ns = params.numscalestosmooth;

%Create scale vector for the CWT
s0 = 2*dt;
a0 = 2^(1/nv);
noct = params.numoct;
scales = s0*a0.^(0:noct*nv);
scales = scales(:);

wname = 'morl';
invscales = 1./scales;
invscales = repmat(invscales,1,nx);
cwtx = cwtft({x,dt},'wavelet',wname,'scales',scales,'PadMode','symw');
cwty = cwtft({y,dt},'wavelet',wname,'scales',scales,'PadMode','symw');
cwtx.cfs = cwtx.cfs(:,1:nx);
cwty.cfs = cwty.cfs(:,1:ny);
cfs1 = smoothCFS(invscales.*abs(cwtx.cfs).^2,scales,dt,ns);
cfs2 = smoothCFS(invscales.*abs(cwty.cfs).^2,scales,dt,ns);
crossCFS = cwtx.cfs.*conj(cwty.cfs);
crossCFS = smoothCFS(invscales.*crossCFS,scales,dt,ns);
crosspec = crossCFS./(sqrt(cfs1).*sqrt(cfs2));
wtc = abs(crossCFS).^2./(cfs1.*cfs2);
N = size(cfs1,2);


% Obtain center frequency of Morlet wavelet in cycles/sample
% Invert this quantity to determine the fundamental period of the
% wavelet
FourierFactor = (2*pi)/6;
% 1/sqrt(2) is the standard devation in time of the analytic Morlet wavelet
% in time
sigmawav = 1/sqrt(2);
coiScalar = FourierFactor/sigmawav;
coitmp = coiScalar*dt*[1E-5,1:((N+1)/2-1),fliplr((1:(N/2-1))),1E-5];
t = 0:dt:N*dt-dt;


if ((nargout == 0) && params.sampinterval)
    
    plotcoherenceperiod(wtc,crosspec,cwtx.frequencies,t,coitmp,...
        nv,mc,Units);
    
    
elseif (nargout==0 && (~isempty(params.fs) || params.normalizedfreq))
    plotcoherencefreq(wtc,crosspec,cwtx.frequencies,t,...
        nv,mc,params.normalizedfreq);
    
end

if nargout > 0
    wcoh = wtc;
    wcs = crosspec;
    P = 1./cwtx.frequencies;
    coi = coitmp';
    if ~isempty(params.Ts)
        % Create period duration object output with correct format
        P = createDurationObject(P,Units);
        P.Format = params.Ts.Format;
        % Create COI duration object output with correct format
        coi = createDurationObject(coi,Units);
        coi.Format = params.Ts.Format;
    end
end



if (nargout>0 && (~isempty(params.fs) || params.normalizedfreq))
    coi = 1./coi;
    P = 1./P;
end


function cfs = smoothCFS(cfs,scales,dt,ns)
N = size(cfs,2);
npad = 2.^nextpow2(N);
omega = 1:fix(npad/2);
omega = omega.*((2*pi)/npad);
omega = [0., omega, -omega(fix((npad-1)/2):-1:1)];

% Normalize scales by DT because we are not including DT in the
% angular frequencies here. The smoothing is done by multiplication in
% the Fourier domain
normscales = scales./dt;
for kk = 1:size(cfs,1)
    F = exp(-0.25*(normscales(kk)^2)*omega.^2);
    smooth = ifft(F.*fft(cfs(kk,:),npad));
    cfs(kk,:)=smooth(1:N);
end
% Convolve the coefficients with a moving average smoothing filter across
% scales
H = 1/ns*ones(ns,1);
cfs = conv2(cfs,H,'same');

%------------------------------------------------------------------------
function params = parseinputs(N,varargin)
% Set up defaults
params.fs = [];
params.dt = 1;
params.Ts = [];
params.sampinterval = false;
params.engunitflag = true;
params.normalizedfreq = true;
params.nv = 12;
params.numscalestosmooth = 12;
maxnumoctaves = floor(log2(N))-1;
params.numoct = maxnumoctaves;
params.wav = 'morl';

% Error out if there are any calendar duration objects
tfcalendarDuration = cellfun(@iscalendarduration,varargin);
if any(tfcalendarDuration)
    error(message('Wavelet:FunctionInput:CalendarDurationSupport'));
end

tfsampinterval = cellfun(@isduration,varargin);

if (any(tfsampinterval) && nnz(tfsampinterval) == 1)
    params.sampinterval = true;
    params.Ts = varargin{tfsampinterval>0};
    if (numel(params.Ts) ~= 1 ) || params.Ts <= 0 || isempty(params.Ts)
        error(message('Wavelet:FunctionInput:PositiveScalarDuration'));
    end
    
    params.engunitflag = false;
    params.normalizedfreq = false;
    varargin(tfsampinterval) = [];
end

params.mincoherence = 0.5;
tfvoices = find(strncmpi(varargin,'voicesperoctave',1));
if any(tfvoices)
    
    params.nv = varargin{tfvoices+1};
    validateattributes(params.nv,{'numeric'},{'positive','integer',...
        'scalar','>=',10,'<=',32},'wcoherence','VoicesPerOctave');
    varargin(tfvoices:tfvoices+1) = [];
end

tfnumoctaves = find(strncmpi(varargin,'numoctaves',4));

if any(tfnumoctaves)
    params.numoct = varargin{tfnumoctaves+1};
    validateattributes(params.numoct,{'numeric'},{'positive','integer',...
        '<=',maxnumoctaves},'wcoherence','NumOctaves');
    varargin(tfnumoctaves:tfnumoctaves+1) = [];
end

%The number of scales to smooth defaults to the number of voices per
%octave
params.numscalestosmooth = params.nv;

tfmincoherence = find(strncmpi(varargin,'phasedisplaythreshold',1));

if any(tfmincoherence)
    params.mincoherence = varargin{tfmincoherence+1};
    validateattributes(params.mincoherence,{'numeric'},{'scalar','>=',0,...
        '<=',1},'wcoherence','PhaseDisplayThreshold');
    varargin(tfmincoherence:tfmincoherence+1) = [];
end

maxsmooth = floor((params.nv*params.numoct+1)/2);
tfnumscalestosmooth = find(strncmpi(varargin,'numscalestosmooth',4));

if any(tfnumscalestosmooth)
    params.numscalestosmooth = varargin{tfnumscalestosmooth+1};
    validateattributes(params.numscalestosmooth,{'numeric'},{'positive',...
        'integer','scalar','<=',maxsmooth},'wcoherence','NumScalesToSmooth');
    varargin(tfnumscalestosmooth:tfnumscalestosmooth+1) = [];
end

% Only scalar left must be sampling frequency
tfsampfreq = cellfun(@(x) (isscalar(x) && isnumeric(x)),varargin);

if (any(tfsampfreq) && (nnz(tfsampfreq) == 1) && ~params.sampinterval)
    params.fs = varargin{tfsampfreq};
    validateattributes(params.fs,{'numeric'},{'positive'},'wcoherence','Fs');
    params.normalizedfreq = false;
    params.engunits = true;
elseif any(tfsampfreq) && params.sampinterval
    error(message('Wavelet:FunctionInput:SamplingIntervalOrDuration'));
elseif nnz(tfsampfreq)>1
    error(message('Wavelet:FunctionInput:Invalid_ScalNum'));
end



%------------------------------------------------------------------------
function plotcoherenceperiod(wcoh,wcs,frequencies,t,coitmp,nv,mc,Units)

period = (1./frequencies);
switch Units
    case 'years'
        Yticks = 2.^(round(log2(min(period))):round(log2(max(period))));
        logYticks = log2(Yticks(:));
        YtickLabels = num2str(sprintf('%g\n',Yticks));
    case 'days'
        Yticks = 2.^(round(log2(min(period))):round(log2(max(period))));
        logYticks = log2(Yticks(:));
        YtickLabels = num2str(sprintf('%g\n',Yticks));
    case 'hrs'
        Yticks = 2.^(round(log2(min(period))):round(log2(max(period))));
        logYticks = log2(Yticks(:));
        YtickLabels = num2str(sprintf('%g\n',Yticks));
    case 'mins'
        Yticks = 2.^(round(log2(min(period)),1):round(log2(max(period)),1));
        logYticks = log2(Yticks(:));
        YtickLabels = num2str(sprintf('%g\n',Yticks));
    case 'secs'
        Yticks = 2.^(round(log2(min(period)),2):round(log2(max(period)),2));
        logYticks = log2(Yticks(:));
        YtickLabels = num2str(sprintf('%g\n',Yticks));
end
%
AX = newplot;
f = ancestor(AX,'figure');
setappdata(AX,'evstruct',[]);
cla(AX,'reset');
imagesc(t,log2(period),wcoh);


AX.CLim = [0 1];
AX.YLim = log2([min(period), max(period)]);
AX.YTick = logYticks;
AX.YDir = 'normal';
set(AX,'YLim',log2([min(period),max(period)]), ...
    'layer','top', ...
    'YTick',logYticks, ...
    'YTickLabel',YtickLabels, ...
    'layer','top')
ylabel([getString(message('Wavelet:wcoherence:Period')) ' (' Units ') ']);
xlabel([getString(message('Wavelet:wcoherence:Time'))  ' (' Units ')']);
title(getString(message('Wavelet:wcoherence:CoherenceTitle')));
hold(AX,'on');
hcol = colorbar;
hcol.Label.String = 'Magnitude-Squared Coherence';


plot(AX,t,log2(coitmp),'w--','linewidth',2);
theta = angle(wcs);
theta(wcoh< mc)= NaN;
if all(isnan(theta))
    return;
end

% Create mesh grid for phase plot
tspace = ceil(size(theta,2)/40);
pspace = round(2^log2(size(theta,1)/nv/2));
tax = t(1:tspace:size(theta,2));
pax = period(1:pspace:size(theta,1));
plotPhaseVectors(AX,theta,tax,pax,tspace,pspace);
hzoom = zoom(f);
cbzoom = @(~,evd)zoomArrows(evd,theta,tax,pax,tspace,pspace);
cbfig = @(hobject,evd)ResizeFig(hobject,evd,theta,tax,pax,tspace,pspace);
evstruct.sclistener = event.listener(f,'SizeChanged',cbfig);
evstruct.ylimlistener = event.proplistener(AX,AX.findprop('YLim'),...
    'PostSet',cbfig);
evstruct.xlimlistener = event.proplistener(AX,AX.findprop('XLim'),...
    'PostSet',cbfig);
setappdata(AX,'evstruct',evstruct);
set(hzoom,'ActionPostCallback',cbzoom);
% Set NextPlot property to 'replace'
f.NextPlot = 'replace';




function plotcoherencefreq(wcoh,wcs,freq,t,nv,mc,normfreqflag)



if normfreqflag
    frequnitstrs = wgetfrequnitstrs;
    freqlbl = frequnitstrs{1};
    coifactorfreq = 1;
    
elseif ~normfreqflag
    [freq,coifactorfreq,uf] = engunits(freq,'unicode');
    freqlbl = wgetfreqlbl([uf 'Hz']);
    
end

Yticks = 2.^(round(log2(min(freq))):round(log2(max(freq))));


if normfreqflag
    ut = 'Samples';
    dt = 1;
    coifactortime = 1;
else
    
    [t,coifactortime,ut] = engunits(t,'unicode','time');
    dt = mean(diff(t));
    
end


N = size(wcoh,2);

% We have to recompute the cone of influence for whatever scaling
% is done in time and frequency by engunits
peakfreq = 6/(2*pi)*coifactorfreq;
FourierFactor = 1/peakfreq;
% The scale factor for the time axis scales the standard deviation in 
% time of the wavelet.
sigmaT = (1/sqrt(2))*coifactortime;
coiScalar = FourierFactor/sigmaT;
coi = coiScalar*dt*[1E-5,1:((N+1)/2-1),fliplr((1:(N/2-1))),1E-5];

AX = newplot;
setappdata(AX,'evstruct',[]);

f = ancestor(AX,'figure');
cla(AX,'reset');
imagesc(t,log2(freq),wcoh);


AX.CLim = [0 1];
AX.YLim = log2([min(freq), max(freq)]);
AX.YTick = log2(Yticks);
AX.YDir = 'normal';
set(AX,'YLim',log2([min(freq),max(freq)]), ...
    'layer','top', ...
    'YTick',log2(Yticks(:)), ...
    'YTickLabel',num2str(sprintf('%g\n',Yticks)), ...
    'layer','top')
ylabel(freqlbl)
xlbl = [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
xlabel(xlbl);
title(getString(message('Wavelet:wcoherence:CoherenceTitle')));
hold(AX,'on');
hcol = colorbar;
hcol.Label.String = 'Magnitude-Squared Coherence';
plot(AX,t,log2(1./coi),'w--','linewidth',2);
theta = angle(wcs);
theta(wcoh< mc)= NaN;
if all(isnan(theta))
    return;
end

% Create mesh grid for phase plot
tspace = ceil(size(theta,2)/40);
pspace = round(2^log2(size(theta,1)/nv/2));
tax = t(1:tspace:size(theta,2));
pax = freq(1:pspace:size(theta,1));
plotPhaseVectors(AX,theta,tax,pax,tspace,pspace);
hzoom = zoom(f);
cbzoom = @(~,evd)zoomArrows(evd,theta,tax,pax,tspace,pspace);
cbfig = @(hobject,evd)ResizeFig(hobject,evd,theta,tax,pax,tspace,pspace);
evstruct.sclistener = event.listener(f,'SizeChanged',cbfig);
evstruct.ylimlistener = event.proplistener(AX,AX.findprop('YLim'),'PostSet',cbfig);
evstruct.xlimlistener = event.proplistener(AX,AX.findprop('XLim'),'PostSet',cbfig);
setappdata(AX,'evstruct',evstruct);
set(hzoom,'ActionPostCallback',cbzoom);
% Set NexPlot to replace
f.NextPlot = 'replace';



function plotPhaseVectors(axhandle,theta,tax,pax,tspace,pspace)
if ~isempty(findobj(axhandle,'type','patch'))
    delete(findobj(axhandle, 'type', 'patch'));
end


[tgrid,pgrid]=meshgrid(tax,log2(pax));
theta = theta(1:pspace:size(theta,1),1:tspace:size(theta,2));

idx = find(~any(isnan([tgrid(:) pgrid(:) theta(:)]),2));

tgrid = tgrid(idx);
pgrid = pgrid(idx);
theta = theta(idx);

% Determine extent of phase arrows in plot
[dx,dy] = determinearrowextent(axhandle);
%

% Create the arrow patch object for plotting the phase
arrowpatch = [-1 0 0 1 0 0 -1; 0.1 0.1 0.5 0 -0.5 -0.1 -0.1]';


for ii=numel(tgrid):-1:1
    % Multiply each arrow by the rotation matrix for the given theta
    rotarrow = arrowpatch*[cos(theta(ii)) sin(theta(ii));-sin(theta(ii)) cos(theta(ii))];
    patch(tgrid(ii)+rotarrow(:,1)*dx,pgrid(ii)+rotarrow(:,2)*dy,[0 0 0],...
        'edgecolor','none' ,'Parent',axhandle);
end


function [dx,dy] = determinearrowextent(axhandle)
% Get the data aspect ratio of the y and x axis
dataaspectratio = get(axhandle,'DataAspectRatio');
axesposition = get(axhandle,'position');
widthheight = axesposition(3:4);
ar = widthheight./dataaspectratio(1:2);


ar(2)=ar(1)/ar(2);
ar(1)=1;

xlim = axhandle.XLim;
dxlim = xlim(2)-xlim(1);


dx=ar(1).*0.02*dxlim;
dy=ar(2).*0.02*dxlim;

function ResizeFig(source,evd,theta,tax,pax,tspace,pspace)
if strcmpi(class(evd),'event.PropertyEvent')
    AX = evd.AffectedObject;
elseif strcmpi(class(source),'matlab.ui.Figure')
    AX = gca;
end

plotPhaseVectors(AX,theta,tax,pax,tspace,pspace);


function zoomArrows(evd,theta,tax,pax,tspace,pspace)
% resizes arrows in event of zoom

AX = evd.Axes;
plotPhaseVectors(AX,theta,tax,pax,tspace,pspace);




