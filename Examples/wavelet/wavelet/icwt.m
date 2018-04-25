function xrec = icwt(wt,varargin)
%ICWT Inverse continuous 1-D wavelet transform
%   XREC = ICWT(WT) inverts the continuous wavelet transform (CWT)
%   coefficient matrix, WT. By default, ICWT uses the default Morse (3,60)
%   wavelet and default scales in the inversion. WT is a 2-D or 3-D matrix
%   with complex-valued elements. If WT is a 2-D matrix, ICWT assumes that
%   the CWT was obtained from a real-valued signal. If WT is a 3-D matrix,
%   ICWT assumes the CWT was obtained from a complex-valued signal. For a
%   3-D matrix, the first page of WT is the CWT of the positive
%   (counterclockwise) component and the second page of WT is the CWT of
%   the negative (clockwise) component. These represent the analytic and
%   anti-analytic parts of the CWT, respectively.
%
%   XREC = ICWT(...,WNAME) uses the wavelet WNAME in the inversion. WNAME
%   is a valid wavelet name: 'morse', 'amor', or 'bump'. The inverse CWT
%   CWT must use the same wavelet.
%
%   XREC = ICWT(...,F,FREQRANGE) inverts the CWT over the frequency range
%   specified in FREQRANGE. If WT is a 2-D matrix, FREQRANGE must be a
%   two-element vector. If WT is a 3-D matrix, FREQRANGE can be a
%   two-element vector or a 2-by-2 matrix. If WT is a 3-D matrix and
%   FREQRANGE is a vector, inversion is performed over the same frequency
%   range in both the positive (analytic) and negative (anti-analytic)
%   components of WT. If FREQRANGE is a 2-by-2 matrix, the first row
%   contains the frequency range for the positive part of WT (first page)
%   and the second row contains the frequency range for the negative part
%   of WT (second page). For a vector, the elements of FREQRANGE must be
%   strictly increasing and contained in the range of the frequency vector
%   F. For a matrix, each row of FREQRANGE must be strictly increasing and
%   contained in the range of F. F is the scale-to-frequency conversion
%   obtained in CWT. For the inversion of a complex-valued signal, you can
%   specify one row of FREQRANGE as a vector of zeros. If the first row of
%   FREQRANGE is a vector of zeros, only the negative (anti-analytic part)
%   is used in the inversion. For example [0 0; 1/10 1/4] inverts the
%   negative (clockwise) component over the frequency range [1/10 1/4]. The
%   positive (counterclockwise) component is first set to all zeros before
%   performing the inversion. Similarly, [1/10 1/4; 0 0] inverts the CWT by
%   selecting the frequency range [1/10 1/4] from the positive
%   (counterclockwise) component and setting the negative component to all
%   zeros.
%
%   XREC = ICWT(..,PERIOD,PERIODRANGE) inverts the CWT over the two-element
%   range of periods in PERIODRANGE. If WT is a 2-D matrix, PERIODRANGE
%   must be a two-element vector of durations. If WT is a 3-D matrix,
%   PERIODRANGE can be a two-element vector of durations or 2-by-2 matrix
%   of durations. If PERIODRANGE is a vector of durations and WT is a 3-D
%   matrix, inversion is performed over the same frequency range in both
%   the positive (analytic) and negative (anti-analytic) components of WT.
%   If PERIODRANGE is a 2-by-2 matrix of durations, the first row contains
%   the period range for the positive part of WT (first page) and the
%   second row contains the period range for the negative part of WT
%   (second page). For a vector, the elements of PERIODRANGE must be
%   strictly increasing and contained in the range of the period vector
%   PERIOD. The elements of PERIODRANGE and PERIOD must have the same
%   units. For a matrix, each row of PERIODRANGE must be strictly
%   increasing and contained in the range of the period vector P. PERIOD is
%   an array of durations obtained from CWT with a duration input. For the
%   inversion of a complex-valued signal, you can specify one row of
%   PERIODRANGE as a vector of zero durations. If the first row of
%   PERIODRANGE is a vector of zero durations, only the negative
%   (anti-analytic part) is used in the inversion. For example [seconds(0)
%   seconds(0); seconds(1/10) seconds(1/4)] inverts the negative
%   (clockwise) component over the period range [seconds(1/10)
%   seconds(1/4)]. The positive (counterclockwise) component is first set
%   to all zeros before performing the inversion. Similarly, [seconds(1/10)
%   seconds(1/4); seconds(0) seconds(0)] inverts the CWT by selecting the
%   period range [1/10 1/4] from the positive (counterclockwise) component
%   and setting the negative component to all zeros.
%
%   XREC = ICWT(...,'TimeBandwidth',TB) use the positive scalar
%   time-bandwidth parameter, TB, to invert the CWT using the Morse
%   wavelet. The symmetry parameter (gamma) of the Morse wavelet is assumed
%   to equal 3. The inverse CWT must use the same time-bandwidth value used
%   in the CWT.
%
%   XREC = ICWT(...,'WaveletParameters',PARAM) uses the parameters PARAM to
%   specify the Morse wavelet used in the inversion of the CWT. PARAM is a
%   two-element vector. The first element is the symmetry parameter (gamma)
%   and the second parameter is the time-bandwidth parameter. The inverse
%   CWT must use the same wavelet parameters used in the CWT.
%
%   XREC = ICWT(...,'SignalMean',MEAN) adds the scalar or vector MEAN to
%   the output of ICWT. If MEAN is a vector, it must be the same length as
%   the column size of the wavelet coefficient matrix.  If WT is a 2-D
%   matrix, MEAN must be a real-valued scalar or vector. If WT is a 3-D
%   matrix, MEAN must be a complex-valued scalar or vector. Because the
%   continuous wavelet transform does not preserve the signal mean, the
%   inverse CWT is a zero-mean signal by default. Note that adding a
%   non-zero MEAN to a frequency- or period-limited reconstruction adds a
%   zero-frequency component to the reconstruction.
%
%   XREC = ICWT(...,'ScalingCoefficients',SCALCFS) uses the scaling
%   coefficients, SCALCFS, in the inverse CWT. SCALCFS are the scaling
%   coefficients obtained as an optional output of CWT. The scaling
%   coefficient output is only supported for Morse wavelets and the
%   analytic Morlet wavelet. SCALCFS is a complex-valued vector which is
%   the same length as the column size of the wavelet coefficient matrix.
%   You cannot specify both the 'SignalMean' and 'ScalingCoefficients'
%   name-value pairs.
%
%   XREC = ICWT(...,'VoicesPerOctave',NV) specifies the number of voices
%   per octave used in obtaining the CWT. If you input a frequency vector
%   or array of durations, you cannot specify the VoicesPerOctave
%   name-value pair. The number of voices per octave is determined by the
%   frequency or duration vector. If you do not specify the number of
%   voices per octave or a frequency or duration vector, ICWT uses the
%   default of 10. NV is an even integer between 4 and 48 and must agree
%   with the value used in obtaining the CWT.
%
%
%   % Example 1:
%   %   Obtain the CWT of the Kobe earthquake data. Invert the CWT
%   %   and compare the result with the original signal.
%   load kobe;
%   sigmean = mean(kobe);
%   wt = cwt(kobe);
%   xrec = icwt(wt,'SignalMean',sigmean);
%   plot((1:numel(kobe))./60,kobe);
%   xlabel('mins'); ylabel('nm/s^2');
%   hold on;
%   plot((1:numel(kobe))./60,xrec,'r');
%   legend('Inverse CWT','Original Signal');
%
%   % Example 2:
%   %   Reconstruct a frequency-localized approximation to the Kobe
%   %   earthquake data by extracting information from the CWT
%   %   corresponding to frequencies in the range of [0.030, 0.070] Hz.
%
%   load kobe;
%   [wt,f] = cwt(kobe,1);
%   xrec = icwt(wt,f,[0.030 0.070],'SignalMean',mean(kobe));
%   subplot(211)
%   plot(kobe); grid on;
%   title('Original Data');
%   subplot(212)
%   plot(xrec); grid on;
%   title('Bandpass Filtered Reconstruction [0.030 0.070] Hz');
%
%   % Example 3:
%   %   Obtain the CWT of a 100-Hz complex exponential sampled at 1 kHz.
%   %   Invert the CWT and plot the real and imaginary parts.
%
%   Fs = 1000;
%   t = 0:1/Fs:1;
%   z = exp(1i*2*pi*100*t);
%   cfs = cwt(z,Fs,'ExtendSignal',false);
%   xrec = icwt(cfs);
%   subplot(211)
%   plot([real(xrec.') real(z.')])
%   title('Real Part');
%   ylim([-1.5 1.5])
%   subplot(212)
%   plot([imag(xrec.') imag(z.')])
%   title('Imaginary Part');
%   ylim([-1.5 1.5])
%
%   %Example 4:
%   %   Obtain the CWT of the NPG2006 dataset. Invert the CWT and add in a
%   %   time-varying trend. Plot the real and imaginary parts of the
%   %   original data along with the reconstructions for comparison.
%
%   load npg2006
%   wt = cwt(npg2006.cx);
%   trend = smoothdata(npg2006.cx,'movmean',100);
%   xrec = icwt(wt,'SignalMean',trend);
%   subplot(2,1,1)
%   plot([real(xrec)' real(npg2006.cx)])
%   grid on;
%   subplot(2,1,2)
%   plot([imag(xrec)' imag(npg2006.cx)])
%   grid on;
%
% See also CWT



narginchk(1,8);
nargoutchk(0,1);
validateattributes(wt,{'numeric'},{'3d','nonempty','finite'},'ICWT','WT');
if isrow(wt) || iscolumn(wt)
    error(message('Wavelet:cwt:InvalidCWTSize'));
end

% Determine if input came from real or complex signal
if ndims(wt) == 3
    wtPos = wt(:,:,1);
    wtNeg = wt(:,:,2);
    sigtype = 'complex';
else
    sigtype = 'real';
end


Na = size(wt,1);
N = size(wt,2);
params = parseinputs(Na,N,sigtype,varargin{:});

ds = params.ds;


if ~isempty(params.f)
    ds = getScType(1./params.f);
    if ~isvector(params.f)
        error(message('Wavelet:cwt:InvalidFreqPeriodInput'));
    end
    if strcmpi(sigtype,'real')
        idxZero = findFreqIndices(Na,params.f,params.freqrange,'real');
        wt(idxZero,:) = 0;
    elseif strcmpi(sigtype,'complex')
        [idxZeroPos,idxZeroNeg] = findFreqIndices(Na,params.f,params.freqrange,'complex');
        wtPos(idxZeroPos,:) = 0;
        wtNeg(idxZeroNeg,:) = 0;
    end
    
elseif ~isempty(params.periods)
    
    ds = getScType(params.periods);
    if ~isvector(params.periods)
        error(message('Wavelet:cwt:InvalidFreqPeriodInput'));
    end
    if strcmpi(sigtype,'real')
        idxZero = findPeriodIndices(Na,params.periods,params.periodrange,'real');
        wt(idxZero,:) = 0;
    elseif strcmpi(sigtype,'complex')
        [idxZeroPos,idxZeroNeg] = findPeriodIndices(Na,params.periods,params.periodrange,'complex');
        wtPos(idxZeroPos,:) = 0;
        wtNeg(idxZeroNeg,:) = 0;
    end
    
end

morseparams = [params.ga params.be];
% Obtain admissibility constant
cpsi = wavelet.internal.admConstant(params.wavname,morseparams);

% Invert using Morlet's single integral formula. The synthesis wavelet
% is a delta distribution
a0 = 2^ds;
if strcmpi(sigtype,'real')
    Wr = 2*log(a0)*(1/cpsi)*real(wt);
else
    Wr = 2*log(a0)*(1/cpsi)*(wtPos+wtNeg);
end


xrec = sum(Wr,1);
% Add in possibly time-varying mean or scaling coefficients
if ~isempty(params.scalcfs)
    xrec = xrec+params.scalcfs;
elseif ~isempty(params.SignalMean)
    xrec = xrec+params.SignalMean;
end



%---------------------------------------------------------------------
function ds = getScType(scales)
DF2 = diff(log2(scales),2);
if all(abs(DF2) < sqrt(eps))
    ds = mean(diff(log2(scales)));
else
    error(message('Wavelet:cwt:UnsupportedScales'));
end

%-----------------------------------------------------------------------

function params = parseinputs(Na,N,sigtype,varargin)
% Set defaults.
params.wavname = 'morse';
params.ga = 3;
params.be = 20;
params.SignalMean = 0;
params.scalcfs = [];
params.ds = 1/10;
params.freqrange = [];
params.f = [];
params.periodrange = [];
params.periods = [];
params.duration = false;


morseparams = find(strncmpi(varargin,'waveletparameters',1));
timeBandwidth = find(strncmpi(varargin,'timebandwidth',1));
if any(morseparams) && any(timeBandwidth)
    error(message('Wavelet:cwt:paramsTB'));
end

if (any(morseparams) && (nnz(morseparams) == 1))
    morseParameter = varargin{morseparams+1};
    validateattributes(morseParameter,{'numeric'},{'numel',2,...
        'positive','nonempty'},'icwt','MorseParameters');
    varargin(morseparams:morseparams+1) = [];
    params.ga = morseParameter(1);
    tb = morseParameter(2);
    validateattributes(params.ga,{'numeric'},{'scalar',...
        'positive','>=',1},'icwt','gamma');
    validateattributes(tb,{'numeric'},{'scalar',...
        '>',params.ga,'<=',40*params.ga},...
        'icwt','TimeBandWidth');
    params.be = tb/params.ga;
    
end


if (any(timeBandwidth) && (nnz(timeBandwidth) == 1))
    params.timebandwidth = varargin{timeBandwidth+1};
    validateattributes(params.timebandwidth,{'numeric'},{'scalar',...
        'positive','>' 3, '<',120},'icwt','TimeBandwidth');
    params.ga = 3;
    params.be = params.timebandwidth/params.ga;
    if params.be>40
        error(message('Wavelet:cwt:TBupperbound'));
    end
    varargin(timeBandwidth:timeBandwidth+1) = [];
end

tfmean = find(strncmpi(varargin,'SignalMean',2));
tfscalcfs = find(strncmpi(varargin,'ScalingCoefficients',2));

if any(tfmean) && any(tfscalcfs)
    error(message('Wavelet:cwt:scalcfsmean'));
end

if (any(tfmean) && nnz(tfmean) == 1)
    params.SignalMean = varargin{tfmean+1};
    validateattributes(params.SignalMean,{'numeric'},{'vector',...
        'finite','nonempty'},'icwt','SignalMean');
    % Take the signal mean as a row vector. This works for both scalars
    % and vectors.
    if numel(params.SignalMean) ~= 1 && numel(params.SignalMean) ~= N
        error(message('Wavelet:cwt:InvalidSignalMean'));
    end
    %
    if all(params.SignalMean ~= 0)
        imagMean = any(imag(params.SignalMean));
        
        if (imagMean && ~strcmpi(sigtype,'complex')) || (~imagMean && strcmpi(sigtype,'complex'))
            error(message('Wavelet:cwt:InvalidSignalMean'));
        end
    end
    
    params.SignalMean = params.SignalMean(:).';
    varargin(tfmean:tfmean+1) = [];
end

if (any(tfscalcfs) && nnz(tfscalcfs) == 1)
    params.scalcfs = varargin{tfscalcfs+1};
    validateattributes(params.scalcfs,{'numeric'},{'vector',...
        'finite','nonempty'},'icwt','ScalingCoefficients');
    % Take the signal mean as a row vector. This works for both scalars
    % and vectors.
    if numel(params.scalcfs) ~= N
        error(message('Wavelet:cwt:InvalidSignalMean'));
    end
       
    params.scalcfs = params.scalcfs(:).';
    varargin(tfscalcfs:tfscalcfs+1) = [];
end



tfduration = cellfun(@isduration,varargin);
if nnz(tfduration) == 1
    error(message('Wavelet:cwt:PeriodAlone'));
end

if (any(tfduration) && nnz(tfduration) == 2)
    durationidx = find(tfduration);
    params.periods = varargin{durationidx(1)};
    params.periodrange = varargin{durationidx(2)};
    [params.periods,UnitsP] = getDurationandUnits(params.periods);
    [params.periodrange,UnitsPR] = getDurationandUnits(params.periodrange);
    
    if ~strcmp(UnitsPR,UnitsP)
        error(message('Wavelet:cwt:PeriodUnits'));
    end
    
    validateattributes(params.periods,{'numeric'},{'positive',...
        'increasing','numel',Na},'icwt','PERIOD');
    
    % Check that the periodrange is at most 2D, nonempty, real
    % finite. Further validation will be done in subfunctions
    validateattributes(params.periodrange,{'numeric'},...
        {'real','nonempty','finite','2d'},'icwt','PERIODRANGE');
    
    
    
end

tfnumvoices = find(strncmpi(varargin,'voicesperoctave',1));
if any(tfnumvoices) && nnz(tfnumvoices)==1
    nv = varargin{tfnumvoices+1};
    validateattributes(nv,{'numeric'},{'positive','scalar',...
        'even','>=',4,'<=',48},'icwt','VoicesPerOctave');
    varargin(tfnumvoices:tfnumvoices+1) = [];
    params.ds = 1/nv;
    if isempty(varargin)
        return;
    end
end

tfnumeric = cellfun(@isnumeric,varargin);
if nnz(tfnumeric) == 1
    error(message('Wavelet:cwt:FrequencyAlone'));
end
if (any(tfnumeric) && nnz(tfnumeric) == 2) && ~any(tfduration)
    % If there are two numeric inputs, the first must be F and
    % the second must be FREQRANGE -- you cannot specify both
    % frequencies and periods
    
    idxvector = find(tfnumeric);
    params.f = varargin{idxvector(1)};
    params.freqrange = varargin{idxvector(2)};
    validateattributes(params.f,{'numeric'},{'positive','decreasing',...
        'numel',Na},'icwt','F');
    if size(params.f,1) ~= Na
        error(message('Wavelet:cwt:FreqMustMatchScales'));
    end
    
    % Check that the periodrange is at most 2D, nonempty, real
    % finite. Further validation will be done in subfunctions
    
    validateattributes(params.freqrange,{'numeric'},...
        {'2d','nonempty','finite','real'},'icwt','FREQRANGE');
    
elseif (any(tfnumeric) && nnz(tfnumeric) == 2) && any(tfduration)
    error(message('Wavelet:FunctionInput:FrequencyOrPeriod'));
    
end


if any(tfnumvoices) && (~isempty(params.f) || ~isempty(params.periods))
    error(message('Wavelet:cwt:NVandFrequencies'));
end


%Only char variable left must be wavelet
tfwav = cellfun(@ischar,varargin);
if (nnz(tfwav) == 1)
    params.wavname = varargin{tfwav>0};
    params.wavname = ...
        validatestring(params.wavname,{'morse','bump','amor'},'icwt','WAVNAME');
    if ~strcmp(params.wavname,'morse')
        params.ga = [];
        params.be = [];
    end
    
elseif nnz(tfwav)>1
    error(message('Wavelet:FunctionInput:InvalidChar'));
    
end

%------------------------------------------------------------------------
function [idxzeropos,idxzeroneg] = findFreqIndices(Na,freqvector,freqrange,sigtype)

fmin = min(freqvector);
fmax = max(freqvector);

isVecFreq = isvector(freqrange);

if ~isVecFreq && strcmpi(sigtype,'real')
    error(message('Wavelet:cwt:InvalidFreqMatrix'));
end

switch isVecFreq
    
    case true
        
        
        validateattributes(freqrange,{'numeric'},{'increasing','numel',2 ...
            '>=',fmin,'<=',fmax},'icwt','FREQRANGE');
        idxbegin = find(freqvector >= freqrange(2),1,'last');
        idxend = find(freqvector <= freqrange(1),1,'first');
        idxzeropos = setdiff(1:Na,idxbegin:idxend);
        if strcmpi(sigtype,'complex')
            idxzeroneg = idxzeropos;
        end
        
    case false
        
        if all(freqrange(1,:)==0)
            idxzeropos = 1:Na;
            validateattributes(freqrange(2,:),{'numeric'},...
                {'increasing','numel',2,'>=',fmin,'<=',fmax},...
                'icwt','FREQRANGE');
            idxbeginneg = find(freqvector >= freqrange(2,2),1,'last');
            idxendneg = find(freqvector <= freqrange(2,1),1,'first');
            idxzeroneg = setdiff(1:Na,idxbeginneg:idxendneg);
        elseif all(freqrange(2,:) == 0)
            validateattributes(freqrange(1,:),{'numeric'},...
                {'increasing','numel',2,'>=',fmin,'<=',fmax},...
                'icwt','FREQRANGE');
            idxzeroneg = 1:Na;
            idxbeginpos = find(freqvector >= freqrange(1,2),1,'last');
            idxendpos = find(freqvector <= freqrange(1,1),1,'first');
            idxzeropos = setdiff(1:Na,idxbeginpos:idxendpos);
        else
            
            validateattributes(freqrange(1,:),{'numeric'},...
                {'increasing','numel',2,'>=',fmin,'<=',fmax},...
                'icwt','FREQRANGE');
            validateattributes(freqrange(2,:),{'numeric'},...
                {'increasing','numel',2,'>=',fmin,'<=',fmax},...
                'icwt','FREQRANGE');
            
            idxbeginpos = find(freqvector >= freqrange(1,2),1,'last');
            idxendpos = find(freqvector <= freqrange(1,1),1,'first');
            
            idxbeginneg = find(freqvector >= freqrange(2,2),1,'last');
            idxendneg = find(freqvector <= freqrange(2,1),1,'first');
            idxzeropos = setdiff(1:Na,idxbeginpos:idxendpos);
            idxzeroneg = setdiff(1:Na,idxbeginneg:idxendneg);
        end
        
end

%-------------------------------------------------------------------------
function [idxzeropos,idxzeroneg] = findPeriodIndices(Na,periodvector,periodrange,sigtype)

pmin = min(periodvector);
pmax = max(periodvector);

isVecPeriod = isvector(periodrange);

if ~isVecPeriod && strcmpi(sigtype,'real')
    error(message('Wavelet:cwt:InvalidPeriodMatrix'));
end

switch isVecPeriod
    
    case true
        
        validateattributes(periodrange,{'numeric'},{'increasing','numel',2,...
            '>=',pmin,'<=',pmax},'icwt','PERIODRANGE');
        idxbegin = find(periodvector <= periodrange(1),1,'last');
        idxend = find(periodvector >= periodrange(2),1,'first');
        idxzeropos = setdiff(1:Na,idxbegin:idxend);
        if strcmpi(sigtype,'complex')
            idxzeroneg = idxzeropos;
        end
        
    case false
        
        if all(periodrange(1,:)==0)
            idxzeropos = 1:Na;
            
            validateattributes(periodrange(2,:),{'numeric'},...
                {'increasing','numel',2,'>=',pmin,'<=',pmax},'icwt','PERIODRANGE');
            
            idxbeginneg = find(periodvector <= periodrange(2,1),1,'last');
            idxendneg = find(periodvector >= periodrange(2,2),1,'first');
            idxzeroneg = setdiff(1:Na,idxbeginneg:idxendneg);
        elseif all(periodrange(2,:) == 0)
            idxzeroneg = 1:Na;
            validateattributes(periodrange(1,:),{'numeric'},...
                {'increasing','numel',2,'>=',pmin,'<=',pmax},'icwt','PERIODRANGE');
            idxbeginpos = find(periodvector <= periodrange(1,1),1,'last');
            idxendpos = find(periodvector >= periodrange(1,2),1,'first');
            idxzeropos = setdiff(1:Na,idxbeginpos:idxendpos);
        else
            validateattributes(periodrange(1,:),{'numeric'},...
                {'increasing','numel',2,'>=',pmin,'<=',pmax},'icwt','PERIODRANGE');
            validateattributes(periodrange(2,:),{'numeric'},...
                {'increasing','numel',2,'>=',pmin,'<=',pmax},'icwt','PERIODRANGE');
            idxbeginpos = find(periodvector <= periodrange(1,1),1,'last');
            idxendpos = find(periodvector >= periodrange(1,2),1,'first');
            idxzeropos = setdiff(1:Na,idxbeginpos:idxendpos);
            idxbeginneg = find(periodvector <= periodrange(2,1),1,'last');
            idxendneg = find(periodvector >= periodrange(2,2),1,'first');
            idxzeroneg = setdiff(1:Na,idxbeginneg:idxendneg);
        end
        
end






