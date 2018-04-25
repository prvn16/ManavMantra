function [s0,omegac,maxfreq,minperiod] = wavhighfreq(cutoff,wavname,ga,be,varargin)
%   This function is for internal use only. It may change or be removed in
%   a future release. Determine high frequency cutoff (small scale) for
%   wavelets. This determines s0, the finest scale, in the CWT.
%   [omegac,maxfreq,minperiod] = ...
%   wavelet.internal.wavhighfreq(1/2,'bump',seconds(0.001));
%   If the sampling period is entered, then the minperiod is given in those
%   units, while the maxfreq is normalized (Nyquist = 1/2). If the sampling
%   frequency is entered (in Hz), then the maxfreq is in Hz while the
%   minperiod is in samples.

T = seconds(1);
Fs = 1;
% Create frequency vector for computations

if ~isempty(varargin) && isduration(varargin{1})
    T = varargin{1};
elseif ~isempty(varargin) && isscalar(varargin{1}) && isnumeric(varargin{1})
    Fs = varargin{1};
    T = seconds(1/Fs);

end
% Grid size of 1e4 points for determining smallest scales
omega = linspace(0,12*pi,1e4);
% Cutoff is entered as percentage
cutoff = cutoff/100;
validateattributes(cutoff,{'double'},{'>=',0,'<=',1});
% Translate cutoff to value on the wavelet magnitude response

if strcmpi(wavname,'morse') && ~isempty(ga) && ~isempty(be)
    % 50 percent energy drop off cutoff for Morse wavelets
    % Cutoff is 1/2.

    cf = wavelet.internal.morsepeakfreq(ga,be);
    anorm = morsenormconstant(ga,be);
    psihat = anorm*omega.^be.*exp(-omega.^ga);
    alpha = max(psihat)*cutoff;
    %idx = find(alpha-psihat<0,1,'first');
    idx = find(psihat>= alpha,1,'last');
    %psihat = @(om)om^ga-be*log(om)+log(alpha)-log(anorm);
    %psihat = @(om)om-(log(anorm)+be*log(om)-log(alpha))^(1/ga);
    %psihat = @(om)anorm*om.^be*exp(-om.^ga)-alpha;
    %omegac = fzero(psihat,[cf 12*pi]);
    omegac = omega(idx);



elseif strcmpi(wavname,'bump')
    % 90 percent energy drop off for bump
    % Cutoff is 0.1 by default.
    if cutoff < 1e-10
        cutoff = 1e-10;
    end
    cf = 5; sigma = 0.6;
    %w = (omega-cf)./sigma;
    %expnt = -1./(1-abs(w).^2);
    %psihat = 2*exp(1)*exp(expnt).*(abs(w)<1-eps);
    %alpha = max(psihat)*cutoff;
    alpha = 2*cutoff;
    %idx = find(psihat>= alpha,1,'last');
    %omegac = omega(idx);   
    psihat = @(om)1/(1-om^2)+log(alpha)-log(2)-1;
    epsilon = fzero(psihat,[0+eps(0) 1-eps(1)]);
    omegac = sigma*epsilon+cf;
    
    
    
elseif strcmpi(wavname,'amor')
    % 90 percent energy drop off for Morlet
    % Cutoff is 0.1 by default
    cf = 6;
    psihat = 2*exp(-(omega-cf).^2/2).*(omega>0);
    alpha = max(psihat)*cutoff; 
    idx = find(psihat>= alpha,1,'last');
    omegac = omega(idx);
    %alpha = 2*cutoff;
    %psihat = @(om)(om-cf)^2+log(alpha);
    %omegac = fzero(psihat,[cf 12*pi]);
    

end

if isempty(omegac)
    omegac = pi;
    
end
% Minimum scale
s0 = omegac/pi;
minperiod = (2*pi*s0)/cf*T;
maxfreq = cf/(2*pi*s0)*Fs;
if minperiod < 2*T
    minperiod = 2*T;
end

if maxfreq > Fs/2
    maxfreq = Fs/2;
end

    


function anorm = morsenormconstant(ga,be)
% anorm = morsenormconstant(ga,be) returns the normalizing constant so that
% the 0-th order Morse wavelet at the peak frequency is equal to 2.
% \gamma and \beta must be real-valued and positive
validateattributes(ga,{'numeric'},{'real','scalar','>=',1});
validateattributes(ga,{'numeric'},{'real','scalar','>',(ga-1)/2});

anorm = 2*exp(be/ga*(1+(log(ga)-log(be))));
