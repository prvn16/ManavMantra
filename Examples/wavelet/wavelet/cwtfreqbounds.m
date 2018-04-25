function varargout = cwtfreqbounds(N, varargin)
%CWTFREQBOUNDS CWT Minimum and Maximum Frequency or Period
%   [MINFREQ,MAXFREQ] = CWTFREQBOUNDS(N) returns the minimum and maximum
%   wavelet bandpass frequencies in cycles/sample for a signal of length N.
%   The minimum and maximum frequencies are determined for the default
%   Morse (3,60) wavelet. The minimum frequency is determined so that two
%   time standard deviations of the default wavelet span the N-point
%   signal at the coarsest scale. The maximum frequency is such that the
%   highest frequency wavelet bandpass filter drops to 1/2 of its peak
%   magnitude at the Nyquist. 
%
%   [MINFREQ,MAXFREQ] = CWTFREQBOUNDS(N,Fs) returns the bandpass
%   frequencies in hertz for the sampling frequency Fs. Fs is a positive
%   scalar.
%
%   [MINFREQ,MAXFREQ] = CWTFREQBOUNDS(...,'Wavelet',WNAME) determines the
%   bandpass frequencies for the wavelet WNAME. Valid options for WNAME are
%   'Morse', 'amor', or 'bump'. For Morse wavelets, you can also
%   parameterize the wavelet using the 'TimeBandwidth' or
%   'WaveletParameters' name-value pairs.
%
%   [MINFREQ,MAXFREQ] = CWTFREQBOUNDS(...,'CUTOFF',CO) specifies the
%   percentage of the peak magnitude at the Nyquist. CO is a value between
%   0 and 100. A CUTOFF value of 0 indicates that the wavelet frequency
%   response decays to 0 at the Nyquist. A CUTOFF value of 100 indicates
%   that the value of the wavelet bandpass filters peaks at the Nyquist. If
%   unspecified, CO defaults to 50 for the Morse wavelets and 10 for the
%   'amor' and 'bump' wavelets.
%
%   [MINFREQ,MAXFREQ] = CWTFREQBOUNDS(...,'StandardDeviations',NUMSD) uses
%   NUMSD time standard deviations to determine the minimum frequency
%   (longest scale). NUMSD is a positive integer greater than or equal to
%   2. For the Morse, analytic Morlet, and bump wavelets, four standard
%   deviations generally ensures that the wavelet decays to zero at the 
%   ends of the signal support. Incrementing 'StandardDeviations' by 
%   multiples of 4, for example 4*M, ensures that M whole wavelets fit 
%   within the signal length. If unspecified, 'StandardDeviations' defaults
%   to 2. If the number of standard deviations is set so that
%   log2(MINFREQ/MAXFREQ) > -1/NV where NV is the number of voices per
%   octave, MINFREQ is adjusted to MAXFREQ*2^(-1/NV).
%
%   [MINFREQ,MAXFREQ] = CWTFREQBOUNDS(...,'TimeBandwidth',TB) returns the
%   bandpass frequencies for the Morse wavelet characterized by the
%   time-bandwidth parameter, TB. TB is a positive number strictly greater
%   than 3 and less than or equal to 120. The larger the time-bandwidth
%   parameter, the more spread out the wavelet is in time and narrower the
%   wavelet bandpass filter is in frequency. The standard deviation of the
%   Morse wavelet in time is approximately sqrt(TB/2). The standard
%   deviation in frequency is approximately 1/2*sqrt(2/TB). You cannot
%   specify both the 'TimeBandwidth' and 'WaveletParameters' name-value
%   pairs.
%
%   [MINFREQ,MAXFREQ] = CWTFREQBOUNDS(...,'WaveletParameters',PARAM) uses
%   the parameters PARAM to specify the Morse wavelet. PARAM is a
%   two-element vector. The first element is the symmetry parameter
%   (gamma), which must be greater than or equal to 1. The second element
%   is the time-bandwidth parameter, which must be strictly greater than
%   gamma. The ratio of the time-bandwidth parameter to gamma cannot exceed
%   40. When gamma is equal to 3, the Morse wavelet is perfectly symmetric
%   in the frequency domain and the skewness is equal to 0. Values of gamma
%   greater than 3 result in positive skewness, while values of gamma less
%   than 3 result in negative skewness. You cannot specify both the
%   'TimeBandwidth' and 'WaveletParameters' name-value pairs.
%
%   [MAXPERIOD,MINPERIOD] = CWTFREQBOUNDS(...,Ts) returns the wavelet
%   bandpass periods for the sampling period Ts. Ts is a positive scalar 
%   <a href="matlab:help duration">duration</a>. 
%   MAXPERIOD and MINPERIOD are scalar durations with the same format as Ts.
%   If the number of standard deviations is set so that 
%   log2(MAXPERIOD/MINPERIOD) < 1/NV, MAXPERIOD is adjusted to MINPERIOD*2^(1/NV).
%
%   [...] = CWTFREQBOUNDS(...,'VoicesPerOctave',NV) uses NV voices per
%   octave in determining the necessary separation between the maximum and
%   minimum scales. The maximum and minimum scales are equivalent to the
%   minimum and maximum frequencies or maximum and minimum periods
%   respectively. NV is an even integer between 4 and 48. The default value
%   of NV is 10.
%
%   %Example: Obtain the minimum and maximum frequencies for the default
%   %   Morse wavelet for a signal of length 10,000 and a sampling
%   %   frequency of 1 kHz. Use a cutoff of 100 percent so that the highest
%   %   frequency wavelet bandpass filter peaks at the Nyquist. Construct
%   %   the filter bank using the values returned by CWTFREQBOUNDS and plot
%   %   the frequency responses.
%   [minfreq,maxfreq] = cwtfreqbounds(1e4,1000,'cutoff',100);
%   fb = cwtfilterbank('SignalLength',1e4,'SamplingFrequency',1000,...
%   'FrequencyLimits',[minfreq maxfreq]);
%   freqz(fb)

%
% See also CWT, CWTFILTERBANK, ICWT


% Check number of input and output arguments
narginchk(1,12);
nargoutchk(0,2);

validateattributes(N,{'numeric'},{'integer','scalar','positive','>=',4}, ...
    'cwtfreqbounds', 'N');

params = parseinputs(varargin{:});

[minfreq,maxperiod,~,~,maxfreq,minperiod] = ...
    wavelet.internal.cwtfreqlimits(...
        params.wavelet, N, params.cutoff, params.ga, params.be, ...
        params.SampleTimeOrFrequency, params.numsd, params.nv);

if isduration(params.SampleTimeOrFrequency)
    
    varargout{1} = maxperiod;
    varargout{2} = minperiod;
else
    
    varargout{1} = minfreq;
    varargout{2} = maxfreq;
end



%--------------------------------------------------------------------------
function params = parseinputs(varargin)

params.SampleTimeOrFrequency = 1;
params.ga = 3;
params.be = 20;
params.cutoff = [];
params.nv = 10;
params.numsd = 2;
params.wavelet = 'morse';

p = inputParser;
% Check for a sampling frequency or sampling period

isTs = ~isempty(varargin) && isduration(varargin{1});
isFs = ~isempty(varargin) && isnumeric(varargin{1});

if isFs
    params.SampleTimeOrFrequency = varargin{1};
    validateattributes(params.SampleTimeOrFrequency,{'numeric'},...
        {'positive','scalar','nonempty','finite'},'cwtfreqbounds','Fs');
    varargin(1) = [];
elseif isTs
    params.SampleTimeOrFrequency = varargin{1};
    validateattributes(params.SampleTimeOrFrequency,...
        {'duration'},{'scalar','nonempty'},...
        'cwtfreqbounds','Ts');
    varargin(1) = [];
end

addParameter(p,'Wavelet','morse');
addParameter(p,'TimeBandwidth',[]);
addParameter(p,'WaveletParameters',[]);
addParameter(p,'CutOff',[]);
addParameter(p,'StandardDeviations',2);
addParameter(p,'VoicesPerOctave',10);

parse(p,varargin{:});

validwavelets = {'morse','amor','bump'};
params.wavelet = validatestring(p.Results.Wavelet,validwavelets, ...
    'cwtfreqbounds', 'Wavelet');


params.nv = p.Results.VoicesPerOctave;
validateattributes(params.nv,{'double'},{'even','>=',4,'<=',48},...
    'cwtfreqbounds','voicesperoctave');

params.numsd = p.Results.StandardDeviations;
validateattributes(params.numsd,{'numeric'},{'>=',2}, ...
    'cwtfreqbounds', 'StandardDeviations');

if (~isempty(p.Results.WaveletParameters) || ~isempty(p.Results.TimeBandwidth))...
        && ~strcmpi(params.wavelet,'morse')
    error(message('Wavelet:cwt:InvalidParamsWavelet'));
end

if ~isempty(p.Results.TimeBandwidth) && ...
        isempty(p.Results.WaveletParameters)

    validateattributes(p.Results.TimeBandwidth,{'numeric'},{'scalar',...
     '>',params.ga},'cwtfreqbounds','TimeBandwidth');
    params.be = p.Results.TimeBandwidth/params.ga;

elseif (isempty(p.Results.TimeBandwidth) && ...
        ~isempty(p.Results.WaveletParameters))
    params.ga = p.Results.WaveletParameters(1);
    validateattributes(params.ga,{'numeric'},{'scalar',...
        'positive','>=',1},'cwtfreqbounds','gamma');    
    validateattributes(p.Results.WaveletParameters(2),{'numeric'},...
        {'scalar','>',params.ga},'cwtfreqbounds','TimeBandwidth');
    % beta must be greater than 1
    params.be = p.Results.WaveletParameters(2)/params.ga;
    if params.be>40
        error(message('Wavelet:cwt:TBupperbound'));
    end
elseif ~isempty(p.Results.TimeBandwidth) && ...
        ~isempty(p.Results.WaveletParameters)
    error(message('Wavelet:cwt:paramsTB'));
elseif ~isempty(p.Results.TimeBandwidth) || ...
        ~isempty(p.Results.WaveletParameters) && ...
        ~strcmpi(params.wavelet,'Morse')
    error(message('Wavelet:cwt:InvalidParamsWavelet'));
end

params.cutoff = p.Results.CutOff;
if isempty(params.cutoff) 
    if strcmpi(params.wavelet,'morse')
        params.cutoff = 50;
    else
        params.cutoff = 10;
    end
end

validateattributes(params.cutoff,{'numeric'},{'scalar','>=',0,'<=',100});







