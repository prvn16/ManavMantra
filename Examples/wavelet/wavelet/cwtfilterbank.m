classdef cwtfilterbank  < dynamicprops & matlab.mixin.CustomDisplay
%CWTFILTERBANK Continuous wavelet transform filter bank
%   FB = CWTFILTERBANK creates a continuous wavelet transform (CWT) filter
%   bank. The default filter bank is designed for a signal with 1024
%   samples. The default filter bank uses the analytic Morse (3,60)
%   wavelet. The wavelets are normalized so that the peak magnitudes for
%   all passbands are approximately equal to 2. The filter bank uses the
%   default scales: approximately 10 wavelet bandpass filters per octave
%   (10 voices per octave). The highest-frequency passband is designed so
%   that the magnitude falls to 1/2 the peak value at the Nyquist frequency.
%
%   FB = CWTFILTERBANK(Name,Value) creates a CWT filter bank, FB, with the
%   specified property Name set to the specified Value. You can specify
%   additional name-value pair arguments in any order as
%   (Name1,Value1,...,NameN,ValueN).
%
%   CWTFILTERBANK methods:
%
%   wt              - Continuous wavelet transform 
%   freqz           - Wavelet frequency responses
%   wavelets        - Time-domain wavelets
%   scales          - Wavelet scales
%   waveletsupport  - Wavelet time support
%   qfactor         - Wavelet Q-factor 
%   powerbw         - 3-dB bandwidths of wavelet bandpass filters
%   BPfrequencies   - Wavelet bandpass frequencies
%   BPperiods       - Wavelet bandpass periods
%
%   CWTFILTERBANK properties:
%
%   SignalLength        - Signal length 
%   Wavelet             - Analysis wavelet
%   VoicesPerOctave     - Voices per octave 
%   SamplingFrequency   - Sampling frequency  
%   FrequencyLimits    -  Frequency limits 
%   SamplingPeriod      - Sampling period 
%   PeriodLimits        - Period limits
%   TimeBandwidth       - Time-bandwidth product 
%   WaveletParameters   - Morse wavelet parameters 
%   Boundary            - Reflect or treat data as periodic
%
%   % Example:
%   %   Construct a default filter bank and display the frequency
%   %   responses.
%
%   fb = cwtfilterbank;
%   freqz(fb)
%
% See also CWT, CWTFREQBOUNDS, DWTFILTERBANK, ICWT
       
    
    properties (SetAccess = private)
        %VoicesPerOctave Approximate number of wavelet filters per octave.
        %   VoicesPerOctave is an even integer between 4 and 48.
        %   VoicesPerOctave defaults to 10.
        VoicesPerOctave
        %Wavelet Analysis wavelet used in filter bank.
        %   Valid options are 'Morse', 'amor', or 'bump'. The wavelet
        %   defaults to 'Morse'.
        Wavelet
        %SamplingFrequency Sampling frequency in hertz. SamplingFrequency
        %   is a positive scalar. If unspecified, frequencies are in 
        %   cycles/sample and the Nyquist is 1/2. SamplingFrequency 
        %   defaults to 1 which is equivalent to frequencies in 
        %   cycles/sample.
        SamplingFrequency
        %SamplingPeriod Sampling as a scalar duration. You cannot
        %   specify both the SamplingFrequency and SamplingPeriod properties.
        SamplingPeriod
        %PeriodLimits Period limits of the wavelet filter bank specified
        %   as a two-element duration array with positive strictly
        %   increasing entries. The first element of PeriodLimits specifies
        %   the largest peak passband frequency and must be greater than or
        %   equal to twice the SamplingPeriod. The base 2 logarithm of the
        %   ratio of minimum period to maximum period must be less than or
        %   equal to -1/NV where NV is the number of voices per octave. The
        %   maximum period cannot exceed the signal length divided by the
        %   product of two time standard deviations of the wavelet and the
        %   wavelet peak frequency. If you specify PeriodLimits outside the
        %   permissible range, CWTFILTERBANK truncates the limits to the
        %   minimum and maximum valid values. Use <a href="matlab:help
        %   cwtfreqbounds">cwtfreqbounds</a> to determine period limits for
        %   different parameterizations of the wavelet transform.
        PeriodLimits
        %SignalLength Signal length in samples. 
        %   Signal length is a positive integer greater than or equal to 4.
        SignalLength
        %FrequencyLimits  Frequency limits of the wavelet filter bank
        %   specified as a two-element vector with positive strictly
        %   increasing entries. The first element of FrequencyLimits
        %   specifies the lowest peak passband frequency and must be
        %   greater than or equal to the product of the wavelet peak
        %   frequency in hertz and two time standard deviations divided by
        %   the length of the signal. The base 2 logarithm of the ratio of
        %   maximum frequency to minimum frequency must be greater than or
        %   equal to 1/NV where NV is the number of voices per octave. The
        %   high frequency limit must be less than or equal to the Nyquist.
        %   If you specify FrequencyLimits outside the permissible range,
        %   CWTFILTERBANK truncates the limits to the minimum and maximum valid 
        %   values. Use <a href="matlab:help cwtfreqbounds">cwtfreqbounds</a> to
        %   determine frequency limits for different parameterizations of
        %   the wavelet transform.
        FrequencyLimits
        %TimeBandwidth 	Time-bandwidth product for Morse wavelets. 
        %   This property is only valid when the Wavelet property is 'Morse'.
        %   This property specifies the time-bandwidth product of the
        %   Morse wavelet with the symmetry parameter (gamma) fixed at 3.
        %   The time-bandwidth product (TB) is a positive number strictly 
        %   greater than 3 and less than or equal to 120. The larger the 
        %   time-bandwidth parameter, the more spread out the wavelet is in 
        %   time and narrower the wavelet is in frequency. The standard 
        %   deviation of the Morse wavelet in time is approximately 
        %   sqrt(TB/2). The standard deviation in frequency is 
        %   approximately 1/2*sqrt(2/TB). The TimeBandwidth and 
        %   WaveletParameters properties cannot both be specified.
        TimeBandwidth
        %WaveletParameters Morse wavelet parameters. WaveletParameters is                         
        %   a two-element vector. The first element is the symmetry
        %   parameter (gamma), which must be greater than or equal to 1. 
        %   The second element is the time-bandwidth parameter, which must
        %   be strictly greater than gamma. The ratio of the time-bandwidth 
        %   parameter to gamma cannot exceed 40. When gamma is equal to 3,
        %   the Morse wavelet is perfectly symmetric in the frequency domain.
        %   The skewness is equal to 0. Values of gamma greater than 3 
        %   result in positive skewness, while values of gamma less than 3
        %   result in negative skewness. WaveletParameters is only valid if 
        %   the Wavelet property is 'Morse'. The WaveletParameters and 
        %   TimeBandwidth properties cannot both be specified.
        %
        WaveletParameters
        %Boundary Determines how the signal is handled at the boundary.
        %   Boundary is one of 'reflection' (default) or 'periodic'.
        Boundary
    end
    
    properties(Hidden,Access = private)
        Frequencies
        Beta
        Omega
        Gamma
        npad;
        PsiHalfPowerBandwidth
        PsiHalfPowerFrequencies
        SignalPad
        normfreqflag = true;
        CutOff
        PlotString
        WaveletCF
    end
    
    
    
    methods (Access = public)
        function self = cwtfilterbank(varargin)
            if nargin == 0
                self.VoicesPerOctave = 10;
                self.Wavelet = 'Morse';
                self.Beta = 20;
                self.Gamma = 3;
                self.TimeBandwidth = self.Gamma*self.Beta;
                self.SignalLength = 1024;
                self.SamplingFrequency = 1;
                self.FrequencyLimits = [];
                self.SignalPad = floor(self.SignalLength/2);
                self.Boundary = 'reflection';
                self.CutOff = 50;
                self.WaveletCF = ...
                    wavelet.internal.morsepeakfreq(self.Gamma,self.Beta);
            elseif nargin > 0
                self = setProperties(self,varargin{:});
            end
            
            % Construct the frequency grid for the wavelet DFT
            self = FrequencyGrid(self);
            
            if ~isempty(self.FrequencyLimits)
                % freqtoscales() method adds the dynamic property
                [~] = freqtoscales(self);
            elseif ~isempty(self.PeriodLimits)
                [~] = periodtoscales(self);
            else
                % Use two time standard deviations of the wavelet for
                % the longest scale
                
                scales = wavelet.internal.getCWTScales(...
                    self.Wavelet,self.SignalLength,self.Gamma,self.Beta,...
                    self.VoicesPerOctave, 2, self.CutOff);
                mobj = self.addprop('Scales');
                self.Scales = scales;
                mobj.SetMethod = @setProp;
                mobj.Hidden = true;
            end

            % Compute filter bank
            self.filterbank();

        end       
        
        
        function [rs,cs] = scales(self)
            %SCALES Wavelet scales
            %   RS = SCALES(FB) returns the raw scales (unitless) scales
            %   used in creating the wavelet bandpass filters. Scales are 
            %   ordered from finest scale to coarsest scale. 
            %
            %   [RS,CS] = SCALES(FB) returns the wavelet scales converted
            %   to units of the sampling frequency or sampling period.
            %
            %   % Example Return the raw scales and converted scales
            %   %   for the filter bank using the default Morse wavelet
            %   %   and a sampling period of 0.001 seconds.
            %   
            %   fb = cwtfilterbank('SamplingPeriod',seconds(0.001));
            %   [rs,cs] = scales(fb);
            %   P = BPperiods(fb);
            %   max(P) / seconds(0.001)
            %   max(cs)
            %
            % See also CWTFILTERBANK/BPFREQUENCIES CWTFILTERBANK/BPPERIODS

            rs = self.Scales / self.SamplingFrequency;
            cs = (2*pi*self.Scales)./self.WaveletCF;
        end
        
        function bpcf = BPfrequencies(self)
            %BPFREQUENCIES Wavelet bandpass frequencies
            %   F = BPfrequencies(FB) returns the wavelet bandpass filter
            %   frequencies for the CWT filter bank, FB. By default, F
            %   has units cycles/sample. If you specify a sampling
            %   frequency, F has units of hertz. If you specify a 
            %   SamplingPeriod, F has units cycles/unit time where the time
            %   unit is the same as the time unit in the duration 
            %   SamplingPeriod.
            %
            %   % Example Determine the wavelet bandpass frequencies for a
            %   %   Morse wavelet filter bank with a sampling frequency of 1
            %   %   Hz.
            %   fb = cwtfilterbank('SamplingFrequency',1);
            %   F = BPfrequencies(fb);
            %
            % See also CWTFILTERBANK/BPPERIODS CWTFILTERBANK/FREQZ
            
            bpcf = self.WaveletCenterFrequencies;
        end
        
        function bpper = BPperiods(self)
            %BPPERIODS Wavelet bandpass periods
            %   P = BPperiods(FB) returns the wavelet bandpass filter
            %   periods for the CWT filter bank, FB. If you specify a 
            %   SamplingPeriod, P is a duration array with the same units
            %   and format as the SamplingPeriod. If you specify a 
            %   SamplingFrequency, P is in seconds.
            %
            %   % Example Determine the wavelet bandpass periods for a Morse
            %   %   wavelet filter bank with a sampling period of 1 second.
            %   fb = cwtfilterbank('SamplingPeriod',seconds(1));
            %   P = BPperiods(fb);
            %
            % See also CWTFILTERBANK/BPFREQUENCIES

            bpcf = self.WaveletCenterFrequencies;
            bpper = 1./bpcf;
            if ~isempty(self.SamplingPeriod)
                [~,~,durarionfunc] = getDurationandUnits(self.SamplingPeriod);
                bpper = durarionfunc(bpper);
                bpper.Format = self.SamplingPeriod.Format;
            end
        end
        
        function [psi,t] = wavelets(self)
            %WAVELETS Time-domain wavelets
            %   PSI = WAVELETS(FB) returns the time-domain wavelets for the
            %   filter bank, FB. 
            %
            %   [PSI,T] = WAVELETS(FB) returns the sampling instants for 
            %   the wavelets.
            %
            %   % Example Obtain the time-domain wavelets for a CWT
            %   % filter bank. Plot the largest scale wavelet.
            %   [minf,maxf] = cwtfreqbounds(1024,'StandardDeviations',4,...
            %   'CutOff',0);
            %   fb = cwtfilterbank('FrequencyLimits',[minf,maxf]);
            %   [psi,t] = wavelets(fb);
            %   plot(t,[real(psi(end,:)).' imag(psi(end,:)).']); grid on;
            
            
            psi = ifftshift(ifft(self.PsiDFT,[],2),2);
            if self.SignalPad
                psi = psi(:,self.SignalPad+1:self.SignalPad+self.SignalLength);
            end
            
            if isempty(self.SamplingPeriod)
                T = self.SignalLength/self.SamplingFrequency;
                t = -T/2:1/self.SamplingFrequency:T/2-1/self.SamplingFrequency;
            else
                T = self.SignalLength*self.SamplingPeriod;
                t = -T/2:self.SamplingPeriod:T/2-self.SamplingPeriod;
            end
            
            
        end
        
        function sptable  = waveletsupport(self,thresh)
        %WAVELETSUPPORT Wavelet time support
        %   SPSI = WAVELETSUPPORT(FB) returns the wavelet time supports
        %   defined as the time interval in which all of the wavelet
        %   energy occurs (> 99.99% of the energy for the default
        %   threshold) SPSI is a Ns-by-5 MATLAB table with the following
        %   variables: CF (wavelet center frequency), IsAnalytic,
        %   TimeSupport, Begin, End.
        %
        %   IsAnalytic is a string which designates the wavelet as
        %   "Analytic" or "Nonanalytic". Wavelets that do not decay to 5%
        %   of their peak value at the Nyquist frequency are not considered
        %   analytic. The time support information for those wavelets is
        %   returned as NaN.
        %
        %   TimeSupport is the wavelet time support returned in samples,
        %   seconds, or MATLAB durations. The units of TimeSupport depend
        %   on whether you specify a SamplingFrequency or SamplingPeriod.
        %   If you specify a SamplingFrequency, the units are in seconds.
        %   If you specify a SamplingPeriod, the units are the same as the
        %   SamplingPeriod. If no SamplingFrequency or SamplingPeriod is
        %   specified, the units are in samples.
        %
        %   Begin is the beginning of the wavelet support defined as the
        %   first instant the wavelet integrated energy exceeds the default
        %   threshold, 1e-4. Begin has the same units as TimeSupport.
        %
        %   End is the end of the wavelet support defined as the last
        %   instant the wavelet integrated energy is less than 1-1e-4. End
        %   has the same units as TimeSupport. 
        %
        %   SPSI = WAVELETSUPPORT(FB,THRESH) specifies the threshold for
        %   the intergrated energy. THRESH is a positive real number
        %   between 0 and 0.05. If unspecified, THRESH defaults to 1e-4.
        %   The time support of the wavelet is defined as the first instant
        %   the integrated energy exceeds THRESH and the last instant the
        %   integrated energy is less than 1-THRESH.
        %
        %   % Example Obtain the time supports for the default Morse 
        %   %   wavelet filter bank. Note the first two wavelet filter 
        %   %   frequency responses have values at the Nyquist frequency of 
        %   %   greater than 5% of the nominal peak value of 2. Therefore, 
        %   %   they are designated as "Nonanalytic" in the table.
        %   
        %   fb = cwtfilterbank;
        %   spsi = waveletsupport(fb);
        
            % Method takes 1 or 2 inputs
            narginchk(1,2)
            
            if nargin == 1
                thresh = 1e-4;
            elseif nargin == 2
                validateattributes(thresh,{'numeric'},{'real','positive',...
                    '<=',0.05});
             
            end
            psi = wavelets(self);
            if isempty(self.SamplingPeriod)
                T = size(psi,2)*1/self.SamplingFrequency;
                %t = 0:1/self.SamplingFrequency:T-1/self.SamplingFrequency;
                t = -T/2:1/self.SamplingFrequency:T/2-1/self.SamplingFrequency;
            else
                T = size(psi,2)*self.SamplingPeriod;
                %t = 0:self.SamplingPeriod:T-self.SamplingPeriod;
                t = -T/2:self.SamplingPeriod:T/2-self.SamplingPeriod;
            end
            
            % Compute wavelet support
            zpsi = wavelet.internal.normalize(1:self.SignalLength,...
                psi,2,'vector');
            zpsi= cumsum(abs(zpsi).^2,2);
            wavsp = zeros(size(zpsi,1),1);
            if isempty(self.SamplingPeriod)
                idxlow = zeros(numel(self.WaveletCenterFrequencies),1);
                idxhigh = zeros(numel(self.WaveletCenterFrequencies),1);
            else
                idxlow = repelem(self.SamplingPeriod,...
                    numel(self.WaveletCenterFrequencies));
                idxhigh = repelem(self.SamplingPeriod,...
                    numel(self.WaveletCenterFrequencies));
            end
            for kk = 1:size(zpsi,1)
                idxbegin = find(zpsi(kk,:) > thresh,1,'first');
                if isempty(idxbegin)
                    idxbegin = 1;
                end
                idxlow(kk) = t(idxbegin);
                idxend = find(zpsi(kk,:) > 1-thresh,1,'first');
                if isempty(idxend)
                    idxend = size(zpsi,2);
                end
                idxhigh(kk) = t(idxend);
                wavsp(kk) = (idxend-idxbegin);
            end
            if ~isempty(self.SamplingPeriod)
                wavsp = wavsp.*self.SamplingPeriod;
            else
                wavsp = wavsp.*1/self.SamplingFrequency;
            end
            tlow = idxlow(:);
            thigh = idxhigh(:);
            valuesAtNyquist = self.PsiDFT(:,self.NyquistBin);
            idxNonAnalytic = valuesAtNyquist > 0.1;
            analyticstring = strings(size(self.PsiDFT,1),1);
            analyticstring(:) = "Analytic";
            analyticstring(idxNonAnalytic) = "Nonanalytic";
            wavsp(idxNonAnalytic) = NaN;
            tlow(idxNonAnalytic) = NaN;
            thigh(idxNonAnalytic) = NaN;
            sptable = table(self.WaveletCenterFrequencies,analyticstring,...
                wavsp,tlow,thigh,'VariableNames', ...
                {'CF','IsAnalytic','TimeSupport','Begin','End'});
            
        end
        
        function varargout = wt(self,x)
            %WT Continuous wavelet transform
            %   CFS = WT(FB,X) returns the continuous wavelet transform
            %   (CWT) coefficients of the signal X, using the CWT filter
            %   bank, FB. X is a double-precision real- or complex-valued
            %   vector. X must have at least four samples. If X is
            %   real-valued, CFS is a 2-D matrix where each row corresponds
            %   to one scale. The column size of CFS is equal to the length
            %   of X. If X is complex-valued, CFS is a 3-D matrix, where
            %   the first page is the CWT for the positive scales (analytic
            %   part or counterclockwise component) and the second page is
            %   the CWT for the negative scales (anti-analytic part or
            %   clockwise component).
            %   
            %   [CFS,F] = WT(FB,X) returns the frequencies, F,
            %   corresponding to the scales (rows) of CFS if the
            %   'SamplingPeriod' property is not specified in the
            %   CWTFILTBANK, FB. If you do not specify a sampling
            %   frequency, F is in cycles/sample.
            %   
            %   [CFS,F,COI] = WT(FB,X) returns the cone of influence, COI,
            %   for the CWT. COI is in the same units as F. If the input X
            %   is complex, COI applies to both pages of CFS.
            %   [CFS,P] = WT(FB,X) returns the periods, P, corresponding to
            %   the scales (rows) of CFS if you specify a sampling period
            %   in the CWTFILTERBANK, FB. P has the same units and format
            %   as the duration scalar sampling period.
            %
            %   [CFS,P,COI] = WT(FB,X) returns the cone of influence in
            %   periods for the CWT. COI is an array of durations with the 
            %   same Format property as the sampling period. If the input X 
            %   is complex, COI applies to to both pages of CFS.
            %   
            %   [...,SCALCFS] = WT(FB,X) returns the scaling
            %   coefficients, SCALCFS, for the wavelet transform if the
            %   analyzing wavelet is 'Morse' or 'amor'. Scaling
            %   coefficients are not supported for the bump wavelet.
            %
            %   % Example Obtain the continuous wavelet transform of the 
            %   %   Kobe earthquake data.
            %   load kobe;
            %   fb = cwtfilterbank('SignalLength',numel(kobe));
            %   [cfs,f] = wt(fb,kobe);

            nargoutchk(0,4);
            % Allow both real and complex input. 
            N = self.SignalLength;
            validateattributes(x,{'double'},{'vector','finite','nonempty'...
                'numel',N},'CWTFILTERBANK','X');
            if numel(x)<4
                error(message('Wavelet:synchrosqueezed:NumInputSamples'));
            end
            % Check whether input is real or complex
            isRealX = isreal(x);
            x = x(:).';
            if ~isRealX
                x = x./2;
            end
            Norig = self.SignalLength;
            if self.SignalPad

                x = [conj(fliplr(x(1:self.SignalPad))) x conj(x(end:-1:end-self.SignalPad+1))];
            end
            xposdft = fft(x);
            % Obtain the CWT in the Fourier domain
            cfsposdft = xposdft.*self.PsiDFT;
            % Invert to obtain wavelet coefficients
            cfspos = ifft(cfsposdft,[],2);
            
            
            cfs = cfspos;
            if ~isRealX
                xnegdft = fft(conj(x));
                cfsnegdft = xnegdft.*self.PsiDFT;
                cfsneg = conj(ifft(cfsnegdft,[],2));

                cfs = cat(3,cfs,cfsneg);
            end

            if self.SignalPad
                cfs = cfs(:,self.SignalPad+1:self.SignalPad+Norig,:);
            end
            
            f = self.WaveletCenterFrequencies;
            
            [FourierFactor, sigmaPsi] = wavelet.internal.wavCFandSD(...
                self.Wavelet, self.Gamma, self.Beta);
            coiScalar = FourierFactor/sigmaPsi;


            if ~isempty(self.SamplingPeriod)
                [dt,~,dtfunch] = getDurationandUnits(self.SamplingPeriod);
            else
                dt = 1/self.SamplingFrequency;
            end
            samples = cwtfilterbank.createCoiIndices(Norig);
            coitmp = coiScalar*dt*samples;
            if isempty(self.SamplingPeriod)
                coi = 1./coitmp;
                coi(coi>self.SamplingFrequency/2) = max(self.WaveletCenterFrequencies);
            else
                % Initialize the coi to have the same units as DT
                % For plotting in CWT, we may use different units
                % dtfunch is a function handle returned by
                % getDurationandUnits
                coi = dtfunch(coitmp);
                %coi = createDurationObject(coitmp,func);
                f = dtfunch(1./f);
                % Duration array
                f.Format = self.SamplingPeriod.Format;
                % Format of COI must match for of Periods
                coi.Format = f.Format;
                coi(coi<2*self.SamplingPeriod) = min(f);
            end

            varargout{1} = cfs;
            varargout{2} = f;
            varargout{3} = coi;
            if nargout == 4
                [~] = scalingfunction(self);
                phidft = self.PhiDFT;
                % Construct anti-analytic version
                if ~rem(numel(phidft),2)
                    % N even
                    phidft(self.NyquistBin+1:end) = ...
                        fliplr(phidft(2:self.NyquistBin-1));
                elseif rem(numel(phidft),2)
                    % N odd
                    phidft(self.NyquistBin+1:end) = ...
                        fliplr(phidft(2:self.NyquistBin));
                end
                scalcfs = ifft(fft(x).*phidft);
                if self.SignalPad
                    scalcfs = scalcfs(self.SignalPad+1:self.SignalPad+Norig);
                end
                if ~isRealX
                    varargout{4} = 2*scalcfs;
                else
                    varargout{4} = scalcfs;
                end
            end

        end                    
        
        
        function bw = powerbw(self)
            %POWERBW Power bandwidth
            %   BW = POWERBW(FB) returns 3-dB (half-power) bandwidths for
            %   the wavelet filters in the filter bank, FB. BW is a MATLAB
            %   table that is Ns-by-2 where Ns is the number of wavelet
            %   bandpass frequencies (equal to the number of scales). The
            %   first variable of BW is the bandpass frequencies and the
            %   second variable is a Ns-by-2 matrix where the first column
            %   is the lower frequency edge of the 3-dB bandwidth and the
            %   second column is the upper frequency edge.
            %
            %   % Example Obtain the 3-dB bandwidths for the wavelet
            %   %   bandpass filters.
            %   [minf,maxf] = cwtfreqbounds(1024,'StandardDeviations',8,...
            %   'CutOff',100);
            %   fb = cwtfilterbank('FrequencyLimits',[minf maxf]);
            %   bw = powerbw(fb);
            
            N = numel(self.Frequencies);
            SxxPsi = self.PsiDFT(:,1:ceil(N/2)+1);
            [bwpsi,fhpsi,flpsi] = halfpowerbandwidth(self,SxxPsi');
            self.PsiHalfPowerBandwidth = bwpsi;
            self.PsiHalfPowerFrequencies = [fhpsi' flpsi'];
            bw = powertable(self);
            
        end

        function pwrtable = powertable(self)
            freq = self.WaveletCenterFrequencies;
            bw = self.PsiHalfPowerBandwidth(:);
            flo = self.PsiHalfPowerFrequencies(:,1);
            fhi = self.PsiHalfPowerFrequencies(:,2);
            pwrtable = table(freq,bw,flo,fhi,...
                'VariableNames',{'Frequencies','HalfPowerBandwidth',...
                'LowFrequencyBorder','HighFrequencyBorder'});
            
        end
        
        function qf = qfactor(self)
            %QFACTOR Wavelet quality factor
            %   QF = QFACTOR(FB) returns the quality factor for the wavelet
            %   bandpass filters in FB. The quality factor is the ratio of
            %   the 3-dB bandwidth to the center frequency. The center
            %   frequency is defined to be the geometric mean of the lower
            %   and upper 3-dB frequencies. The larger the quality factor,
            %   the more frequency localized the wavelet. For reference, a
            %   half-band filter has a quality factor of sqrt(2).
            %
            %   % Example Return the quality factor for the default Morse
            %   %   wavelet.
            %   fb = cwtfilterbank;
            %   qfac = qfactor(fb);
            
            om = linspace((2*pi)/1e4,4*pi,1e4);
            
            if strcmpi(self.Wavelet, 'morse')
                psihat = wavelet.internal.morsebpfilters(...
                    om, 1, self.Gamma, self.Beta);
            else
                psihat = wavelet.internal.wavbpfilters(self.Wavelet, om, 1);
            end
                    
            psihat = psihat(:);
            om = om(:);
            Pxx = wavelet.internal.psdfrommag(psihat,1,false);
            R = -10*log10(2);
            [bw,flo,fhigh] = wavelet.internal.computePowerBW(Pxx,om,[],R);
            qf = cwtfilterbank.geomean([flo fhigh])/bw;
        end
        
        function varargout = freqz(self)
            %FREQZ Wavelet frequency responses
            %   [PSIDFT,F] = FREQZ(FB) returns the frequency responses for
            %   the wavelet filters, PSIDFT, and the frequency vector, F,
            %   in cycles/sample or Hz. If you specify a sampling period,
            %   the frequencies are in cycles/unit time where the time unit
            %   is the unit of the duration sampling period. The frequency
            %   responses for PSIDFT are one-sided frequency responses. For
            %   the analytic wavelets supported by CWTFILTERBANK, the
            %   wavelet frequency responses are real-valued and are
            %   equivalent to the magnitude frequency response.
            %
            %   FREQZ(FB) plots the magnitude frequency responses for the 
            %   wavelet filter bank, FB. 
            %
            %   % Example Plot frequency responses for the default Morse
            %   %   wavelet filter bank.
            %   fb = cwtfilterbank;
            %   freqz(fb)
            nargoutchk(0,2);
            tmp = self.PsiDFT;
            idxNyquist = self.NyquistBin;
            if nargout > 0
                H = tmp(:,1:idxNyquist);
                W = self.Frequencies(1:idxNyquist);
                varargout{1} = H;
                varargout{2} = W;
                return;
            end
            tmp(:,idxNyquist+1:end) = NaN;
            % Frequency responses of wavelets should be nonnegative and
            % real-valued
            
            if nargout == 0
                if self.normfreqflag
                    frequnitstrs = wgetfrequnitstrs;
                    freqlbl = frequnitstrs{1};
                    freq = self.Frequencies;
                    
                elseif isempty(self.PlotString)
                    [freq,~,uf] = engunits(self.Frequencies,'unicode');
                    freqlbl = wgetfreqlbl([uf 'Hz']);

                else
                    freqlbl = ['cycles/' self.PlotString];
                    freq = self.Frequencies;
                    
                end
                plot(freq,abs(tmp.'));
                xlabel(freqlbl);
                ylabel(getString(message('Wavelet:cwt:Magnitude')));
                grid on;
                title(getString(message('Wavelet:cwt:cwtfb')));
            end
        end
    end
    
    methods (Static,Hidden)
        function gm = geomean(x)
            N = size(x,2);
            gm = exp(sum(log(x),2)./N);
        end
        
        function indices = createCoiIndices(N)
           if rem(N,2)  % is odd
               indices = 1:ceil(N/2);
               indices = [indices, fliplr(indices(1:end-1))];
           elseif ~rem(N,2)  % is even
               indices = 1:N/2;
               indices = [indices, fliplr(indices)];
           end
        end
    end
    
    
    methods (Access = private, Hidden)
        function self = setProperties(self,varargin)
            p = inputParser;
            checkbw = @(x) isscalar(x) && (x>3 && x<=120);
            checkwavparams = @(x) isnumeric(x) && numel(x)==2 && ...
                x(1) >= 1 && x(2)>x(1) && x(2)/x(1) <= 40;
            
            voicescheck = @(x)validateattributes(x,{'numeric'},...
                {'positive','scalar','even','>=',4,'<=',48},...
                'cwtfilterbank','VoicesPerOctave');
            sampperiodcheck = @(x)isduration(x) && isscalar(x) && x>0 ...
                && isfinite(x);
            validboundary = {'reflection','periodic'};
            addParameter(p,'Wavelet','Morse');
            addParameter(p,'TimeBandwidth',[],checkbw);
            addParameter(p,'WaveletParameters',[],checkwavparams);
            addParameter(p,'SignalLength',1024);
            addParameter(p,'SamplingFrequency',[]);
            addParameter(p,'VoicesPerOctave',10,voicescheck);
            addParameter(p,'FrequencyLimits',[]);
            addParameter(p,'Boundary','reflection');
            addParameter(p,'SamplingPeriod',[],sampperiodcheck);
            addParameter(p,'PeriodLimits',[]);
            parse(p,varargin{:});
            self.Wavelet = p.Results.Wavelet;
            self.Wavelet = validatestring(self.Wavelet,{'morse','amor',...
                'bump'}, 'CWTFILTERBANK', 'Wavelet');
            if strcmpi(self.Wavelet,'Morse')
                self.CutOff = 50;
            else
                self.CutOff = 10;
            end

            self.SignalLength = p.Results.SignalLength;
            if self.SignalLength < 4
                error(message('Wavelet:synchrosqueezed:NumInputSamples'));
            end
            
            self.WaveletParameters = p.Results.WaveletParameters;
            self.SamplingFrequency = p.Results.SamplingFrequency;
            self.SamplingPeriod = p.Results.SamplingPeriod;
            
            if ~isempty(self.SamplingFrequency) && ~isempty(self.SamplingPeriod)
                error(message('Wavelet:cwt:sampfreqperiod'));
            elseif ~isempty(self.SamplingFrequency)
                validateattributes(self.SamplingFrequency,{'numeric'},...
                    {'scalar','positive','finite'},'CWTFILTERBANK','SamplingFrequency');
                self.normfreqflag = false;
            elseif ~isempty(self.SamplingPeriod)
                validateattributes(self.SamplingPeriod,{'duration'},...
                    {'scalar','nonempty'},'CWTFILTERBANK','SamplingPeriod');
                [Ts,~,~,pstring] = getDurationandUnits(self.SamplingPeriod);
                self.PlotString = pstring;
                self.SamplingFrequency = 1/Ts;
                self.normfreqflag = false;
            else
                self.SamplingFrequency = 1;
            end
            
           
            self.VoicesPerOctave = p.Results.VoicesPerOctave;
            
            self.TimeBandwidth = p.Results.TimeBandwidth;
            self.WaveletParameters = p.Results.WaveletParameters;
            if ~strcmpi(self.Wavelet,'morse') && (~isempty(self.TimeBandwidth) || ...
                    ~isempty(self.WaveletParameters)) 
                error(message('Wavelet:cwt:InvalidParamsWavelet'));
            end
            self.FrequencyLimits = p.Results.FrequencyLimits;
            self.PeriodLimits = p.Results.PeriodLimits;
            if ~isempty(self.PeriodLimits)
                validateattributes(self.PeriodLimits,{'duration'},{'numel',2},...
                    'CWTFILTERBANK','PeriodLimits');
            end
            if ~isempty(self.SamplingPeriod) && ~isempty(self.FrequencyLimits)
                error(message('Wavelet:cwt:freqrangewithts'));
            elseif isempty(self.SamplingPeriod) && ~isempty(self.PeriodLimits)
                error(message('Wavelet:cwt:periodswithoutTS'));
            end
            
            self.Boundary = p.Results.Boundary;
                       
            validatestring(self.Boundary,validboundary);
            if strcmpi(self.Boundary,'reflection') 
                if self.SignalLength <= 1e5
                    self.SignalPad =  floor(self.SignalLength/2);
                else
                    self.SignalPad = ceil(log2(self.SignalLength));
                end
            else
                self.SignalPad = 0;
            end
            
            
            if strcmpi(self.Wavelet,'Morse') && ...
                    isempty(self.TimeBandwidth) && isempty(self.WaveletParameters)
                % Default gamma and beta values
                self.Gamma = 3;
                self.Beta = 20;
                self.TimeBandwidth = self.Gamma*self.Beta;

            elseif strcmpi(self.Wavelet,'Morse') && ...
                    ~isempty(self.TimeBandwidth) && ...
                    isempty(self.WaveletParameters)

                self.Gamma = 3;
                self.Beta = self.TimeBandwidth/self.Gamma;

            elseif strcmpi(self.Wavelet,'Morse') && ...
                    isempty(self.TimeBandwidth) && ...
                    ~isempty(self.WaveletParameters)
                self.Gamma = self.WaveletParameters(1);
                self.Beta = self.WaveletParameters(2)/self.Gamma;

            elseif ~isempty(self.TimeBandwidth) && ~isempty(self.WaveletParameters)
                error(message('Wavelet:cwt:paramsTB'));
            end
            
            [~,~,self.WaveletCF] = wavelet.internal.wavCFandSD(...
                self.Wavelet, self.Gamma, self.Beta);

            if ~isempty(self.FrequencyLimits)
                validateFrequencyRange(self);
            end
            
            if ~isempty(self.PeriodLimits)
                validatePeriodRange(self);
            end
        end
        
        function [psidft,f] = filterbank(self)
            % Wavelet Filter Bank
            %   PSIDFT = FILTERBANK(FB) returns the CWT wavelet filter bank
            %   frequency responses in PSIDFT. PSIDFT is an Ns-by-N matrix
            %   where Ns is the number of scales (frequencies) and N is the
            %   number of time points.
            %
            %   [PSIDFT,F] = FILTERBANK(FB) returns the frequency grid in
            %   hertz or cycles/sample for plotting the filter bank. Use
            %   BPfrequencies to obtain the passband peak frequencies for
            %   the filter bank.
            %
            
            if strcmpi(self.Wavelet,'Morse')
                [psidft,f] = wavelet.internal.morsebpfilters(...
                    self.Omega,self.Scales,self.Gamma,self.Beta);
            else
                [psidft,f] = wavelet.internal.wavbpfilters(...
                    self.Wavelet,self.Omega,self.Scales);
            end

            f = f.*self.SamplingFrequency;
            f = f(:);            
            mpsidft = self.addprop('PsiDFT');
            mcf = self.addprop('WaveletCenterFrequencies');
            self.PsiDFT = psidft;
            self.WaveletCenterFrequencies = f;
            mpsidft.SetMethod = @setProp;
            mpsidft.Hidden = true;
            mcf.SetMethod = @setProp;
            mcf.Hidden = true;
            setNyquistBin(self);

        end
        
        function self = FrequencyGrid(self)
            % This method constructs the frequency grid to compute the
            % Fourier transforms of the analyzing wavelets
            
            N = self.SignalLength+2*self.SignalPad;
            omega = (1:fix(N/2));
            omega = omega.*(2*pi)/N;
            omega = [0, omega, -omega(fix((N-1)/2):-1:1)];
            self.Omega = omega;
            self.Frequencies = self.SamplingFrequency*self.Omega./(2*pi);
        end
        
        function validateFrequencyRange(self)
            freqrange = self.FrequencyLimits;
            validateattributes(freqrange,{'numeric'},{'finite',...
                'increasing','numel',2},'CWTFILTERBANK',...
                'FrequencyLimits');
            fs = self.SamplingFrequency;
            [minfreq,~, ~] = minmaxfreq(self);
            % If the minimum frequency is less than the minimum allowable
            % frequency, set equal to the minimum.
            if freqrange(1) < minfreq
                self.FrequencyLimits(1) = minfreq;
                % Change freqrange if needed
                freqrange(1) = self.FrequencyLimits(1);
            end

            if freqrange(2) > fs/2
                % If the maximum frequency is greater than the Nyquist, set
                % equal to the Nyquist.
                self.FrequencyLimits(2) = fs/2;
                % Change freqrange if needed
                freqrange(2) = self.FrequencyLimits(2);
            end
            % Sufficient spacing in frequencies to respect VoicesPerOctave
            freqsep = log2(freqrange(2))-log2(freqrange(1)) >= ...
                1/self.VoicesPerOctave;
           if ~freqsep
               error(message('Wavelet:cwt:freqsep',...
                   num2str(1/self.VoicesPerOctave)));
           end
           
        end
        
        function validatePeriodRange(self)
            periodrange = self.PeriodLimits;
            % validateattributes does not work on durations
            p1 = wavelet.internal.convertDuration(self.PeriodLimits(1));
            p2 = wavelet.internal.convertDuration(self.PeriodLimits(2));
            validateattributes([p1 p2],{'numeric'},{'finite',...
                'increasing'},'CWTFILTERBANK','PeriodRange');
            T = self.SamplingPeriod;
            if ~strcmpi(periodrange.Format,T.Format)
                error(message('Wavelet:cwt:InvalidPeriodFormat'));
            end
            [~,maxp] = minmaxfreq(self);

            % Is the requested maximum period less than or equal to the 
            % valid maximum period
            upperBound = self.PeriodLimits(2) <= maxp;
            if ~upperBound
                self.PeriodLimits(2) = maxp;
                p2 = wavelet.internal.convertDuration(self.PeriodLimits(2));
            end
            % Is the requested minimum period greater than or equal to the
            % valid minimum period
            lowerBound = self.PeriodLimits(1) >= 2*self.SamplingPeriod;
            if ~lowerBound
                self.PeriodLimits(1) = 2*self.SamplingPeriod;
                p1 = wavelet.internal.convertDuration(self.PeriodLimits(1));
            end
            % Verify separation
            periodsep = log2(p1)-log2(p2) <= -1/self.VoicesPerOctave;
            if ~periodsep
                error(message('Wavelet:cwt:periodsep',...
                    num2str(-1/self.VoicesPerOctave)));
            end
            
        end
        
        function scales = freqtoscales(self)
            % Obtain the frequency range
            frange = self.FrequencyLimits;
            % Convert frequencies in Hz to radians/sample
            wrange = frange.*1/self.SamplingFrequency*2*pi;
            nv = self.VoicesPerOctave;
            a0 = 2^(1/nv);
            [~,~,omega_psi] = wavelet.internal.wavCFandSD(...
                self.Wavelet, self.Gamma, self.Beta);

            % If the frequencies are valid
            s0 = omega_psi/wrange(2);
            smax = omega_psi/wrange(1);
            numoctaves = log2(smax/s0);
            
            scales = s0*a0.^(0:(nv*numoctaves));
            
            %scales = a0.^linspace(nv*log2(s0),nv*log2(smax),...
            %    round(nv*numoctaves));
            mscales = self.findprop('Scales');
            if isempty(mscales)
                mscales = self.addprop('Scales');
                self.Scales = scales;
                mscales.SetMethod = @setProp;
                mscales.Hidden = true;
            elseif ~isempty(mscales)
                self.Scales = scales;
            end
        end
        
        function scales = periodtoscales(self)
            [Ts,~,convertFunc] = getDurationandUnits(self.SamplingPeriod);
            % Obtain the period limits in units of sampling period
            prange = convertFunc(self.PeriodLimits);
            prange = prange*(1/Ts);
            nv = self.VoicesPerOctave;
            a0 = 2^(1/nv);
            [~,~,omega_psi] = wavelet.internal.wavCFandSD(...
                self.Wavelet, self.Gamma, self.Beta);
            % s = \frac{\omega_{\psi}}{\omega}
            scalerange = (omega_psi*prange)/(2*pi);
            s0 = min(scalerange);
            smax = max(scalerange);
            numoctaves = log2(smax/s0);
            scales = s0*a0.^(0:nv*numoctaves);
            mscales = self.findprop('Scales');
            if isempty(mscales)
                mscales = self.addprop('Scales');
                self.Scales = scales;
                mscales.SetMethod = @setProp;
                mscales.Hidden = true;
            elseif ~isempty(mscales)
                self.Scales = scales;
            end
        end

        function [minfreq,maxperiod,maxfreq,minperiod] = minmaxfreq(self)
            wav = self.Wavelet;
            ga = self.Gamma;
            be = self.Beta;
            N = self.SignalLength;
            nv = self.VoicesPerOctave;
            numsd = 2;
            cutoff = self.CutOff;

            timebase = self.SamplingFrequency;
            if ~isempty(self.SamplingPeriod)
                timebase = self.SamplingPeriod;
            end
            
            [minfreq,maxperiod,~,~,maxfreq,minperiod] = ...
                wavelet.internal.cwtfreqlimits(...
                    wav,N,cutoff,ga,be,timebase,numsd,nv);
        end

        function [bw,fhi,flo] = halfpowerbandwidth(self,Sxx)
            % Determine 1/2 power bandwidth for transfer functions
            onesided = true;  % we are only using real-valued wavelets here
            % Sxx is magnitude data
            % power bandwidth calculation is designed to work on PSD
            % estimates. Convert power spectra to PSD.
            Pxx = wavelet.internal.psdfrommag(Sxx,...
                self.SamplingFrequency,onesided);
            % 3 dB point -- 1/2 power bandwidth
            R = -10*log10(2);
            N = numel(self.Frequencies);
            F = self.Frequencies(1:ceil(N/2)+1);
            [bw,fhi,flo] = wavelet.internal.computePowerBW(Pxx,F,[],R);
            
        end
        
        function [phidft] = scalingfunction(self)
            mphidft = self.findprop('PhiDFT');
            if ~isempty(mphidft)
                phidft = self.PhiDFT;
                return;
            end
            if strcmpi(self.Wavelet,'Morse')
                phidft = wavelet.internal.morsescalingfunction(self.Gamma,...
                    self.Beta,self.Omega,max(self.Scales));
                
            elseif strcmpi(self.Wavelet,'amor')
                phidft = wavelet.internal.morletscalingfunction(self.Omega,...
                    max(self.Scales));
            else
                error(message('Wavelet:cwt:bumpscaling',self.Wavelet));
            end
            
            self.addprop('PhiDFT');
            self.PhiDFT = phidft;
            mphidft = self.findprop('PhiDFT');
            mphidft.SetMethod = @setProp;
            
        end
        
        function setProp(~,~)
            %setProp Set method for all dynamic properties
            % Properties are read-only. Error out and instruct user to
            % construct filter bank
            error(message('Wavelet:cwt:dynamicprops'));
        end
    end
    
    methods(Hidden)
        function TF = isNormalizedFrequency(self)
            TF = self.normfreqflag;
        end
        
        function [ga,be] = getGammaBeta(self)
            if strcmpi(self.Wavelet,'morse')
                ga = self.Gamma;
                be = self.Beta;
            else
                ga = [];
                be = [];
            end
        end
        
        function setNyquistBin(self)
            % Nyquist Bin is dynamic property
            N = size(self.PsiDFT,2);
            if rem(N,2) % N odd
                idxbin = ceil(N/2);
            elseif ~rem(N,2)
                idxbin = N/2+1;
            end
            mnyqbin = self.addprop('NyquistBin');
            self.NyquistBin = idxbin;
            mnyqbin.SetMethod = @setProp;
            % This property is hidden
            mnyqbin.Hidden = true;
            
        end
    end
    
end


