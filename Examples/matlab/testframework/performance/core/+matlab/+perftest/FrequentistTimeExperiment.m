classdef FrequentistTimeExperiment < matlab.perftest.TimeExperiment
    % FrequentistTimeExperiment A TimeExperiment that collects a variable number of measurements
    %
    %   The FrequentistTimeExperiment is used to run an experiment on a
    %   test suite to collect a variable number of measurements by
    %   targeting a Relative Margin of Error at a specified Confidence Level.
    %
    %   To create a FrequentistTimeExperiment, use the limitingSamplingError
    %   static method provided by the TimeExperiment class.
    %
    %   FrequentistTimeExperiment properties:
    %       NumWarmups            - Number of warmup measurements (default 4)
    %       MinSamples            - Minimum number of samples to collect after warmup (default 4)
    %       MaxSamples            - Maximum number of samples to collect after warmup (default 32)
    %       RelativeMarginOfError - Target Margin of Error for the sample (default 0.05)
    %       ConfidenceLevel       - Confidence Level for the samples to be
    %                                within the Margin of Error (default 0.95)
    %
    %   Example:
    %
    %       import matlab.perftest.TimeExperiment
    %
    %       % Create a TestSuite array
    %       suite = testsuite;
    %
    %       % Create a default TimeExperiment to collect a variable number of samples
    %       experiment = TimeExperiment.limitingSamplingError;
    %       results = run(experiment, suite);
    %
    %       % Create a custom TimeExperiment to collect a variable number of samples
    %       experiment = TimeExperiment.limitingSamplingError(...
    %          'NumWarmups', 2, 'MinSamples', 4, 'MaxSamples', 10, ...
    %          'RelativeMarginOfError', 0.20, 'ConfidenceLevel', 0.90);
    %       results = run(experiment, suite);
    %
    %   See also: matlab.perftest.TimeExperiment, matlab.unittest.measurement.MeasurementResult
    
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        % NUMWARMUPS - Number of warmup measurements
        %
        %   NumWarmups defines the number of times to exercise the code in
        %   order to warm it up.
        %
        %   See also: matlab.perftest.TimeExperiment, matlab.unittest.measurement.MeasurementResult
        NumWarmups;
        
        % MINSAMPLES - Minimum number of sample measurements to collect after warmup.
        %   The experiment defers any statistical inferences until
        %   MINSAMPLES have been collected.
        %
        %   See also: MAXSAMPLES, NUMWARMUPS.
        MinSamples;
        
        % MAXSAMPLES - Maximum number of sample measurements to collect after warmup.
        %   The experiment will continue to collect up to MAXSAMPLES if the
        %   statistical targets are not met.
        %
        %   See also: MINSAMPLES, NUMWARMUPS.
        MaxSamples;
        
        % RELATIVEMARGINOFERROR - Target relative margin of error of the sample mean.
        %   The Relative Margin of Error for a sample X is calculated as follows:
        %
        %            relMoE = T * std(X) / mean(X) / sqrt(length(X))
        %
        %   where T is the T-score from Student's T Distribution using the
        %   specified ConfidenceLevel and length(X)-1 degrees of freedom.
        %
        %   See also: CONFIDENCELEVEL.
        RelativeMarginOfError;
        
        % CONFIDENCELEVEL - Confidence Level for the samples to be within the Relative Margin of Error
        %
        %   See also: RELATIVEMARGINOFERROR.
        ConfidenceLevel;
    end
    
    properties (SetAccess = immutable, GetAccess = private)
        TScore;
    end
    
    properties (Hidden, SetAccess = immutable, GetAccess = protected)
        Accumulator;
    end
    
    methods (Access = ?matlab.perftest.TimeExperiment)
        function experiment = FrequentistTimeExperiment(varargin)
            import matlab.perftest.internal.AccumulatorMap;
            
            p = matlab.unittest.internal.strictInputParser;
            p.KeepUnmatched   = true;
            
            p.addParameter('NumWarmups',               4, @validateNumWarmups);
            p.addParameter('MinSamples',               4, @validateSampleSize);
            p.addParameter('MaxSamples',              32, @validateSampleSize);
            p.addParameter('RelativeMarginOfError', 0.05, @validateMarginOfError);
            p.addParameter('ConfidenceLevel',       0.95, @validateConfidenceLevel);
            
            p.parse(varargin{:});
            
            experiment@matlab.perftest.TimeExperiment(p.Unmatched);
            
            experiment.NumWarmups            = p.Results.NumWarmups;
            experiment.MinSamples            = p.Results.MinSamples;
            experiment.MaxSamples            = p.Results.MaxSamples;
            experiment.RelativeMarginOfError = p.Results.RelativeMarginOfError;
            experiment.ConfidenceLevel       = p.Results.ConfidenceLevel;
            
            if experiment.MinSamples > experiment.MaxSamples
                error(message('MATLAB:unittest:performance:FrequentistTimeExperiment:InvalidSampleRange',...
                    experiment.MaxSamples,experiment.MinSamples))
            end
            
            experiment.Accumulator = AccumulatorMap();
            
            % store vector of t-scores
            experiment.TScore = lookupTScore(...
                experiment.ConfidenceLevel,1:experiment.MaxSamples-1);
        end
    end
    
    methods(Hidden, Access=protected)
        function doRun(experiment, operator, runner, suite, runIdentifier)
            experiment.Accumulator.reset();
            
            % listen to measurements to accumulate
            listener = event.listener(operator,'MeasurementCompleted',...
                @(o,e)experiment.handleMeasurementEvent(e)); %#ok<NASGU> destroyed at scope boundary
            
            % run repeatedly
            maxMeasurements = experiment.NumWarmups + experiment.MaxSamples;
            earlyTermFcn = @experiment.earlyTerminationFcn;
            
            runner.runRepeatedly(suite, maxMeasurements, ...
                'EarlyTerminationFcn', earlyTermFcn, 'RunIdentifier', runIdentifier);
        end
    end
    
    methods (Access = protected)
        function stop = earlyTerminationFcn(experiment, result, currentIndex)
            % Checking if the result Started first is not always safe - it
            % could have asserted/errored in TestMethodSetup. Have to check
            % failure states first (which is subtly different than
            % ~Passed), then use the Started flag.
            import matlab.unittest.measurement.internal.HasLastValueSufficientlyOutsideCalibrationOffset;
            import matlab.unittest.measurement.internal.HasAllValuesSufficientlyOutsideCalibrationOffset;
            
            numSamples = experiment.MeasurementPlugin.RepeatIndex - experiment.NumWarmups;
            
            if numSamples > experiment.MinSamples
                constraint = HasLastValueSufficientlyOutsideCalibrationOffset;                
            elseif numSamples < experiment.MinSamples
                % not enough samples - keep running
                stop = false;
                return;
            else
                % an early exit chance if any minSample is too fast
                constraint = HasAllValuesSufficientlyOutsideCalibrationOffset;
            end
            
            if ~constraint.satisfiedBy(experiment.MeasurementPlugin.Result(currentIndex))
                stop = true;
                return;
            end
            
            if result.Failed || result.Incomplete
                stop = true;
                return;
            end
            
            if ~result.Started
                stop = false;
                return;
            end
            
            % check statistics
            stop = experiment.isTargetCriteriaMet();
            
            % warn if too noisy and exceeding the max
            if ~stop && numSamples >= experiment.MaxSamples
                w = warning('query','backtrace');
                cleanup = onCleanup(@()warning(w));
                warning('backtrace','off') % concise warnings
                warning(message('MATLAB:unittest:performance:FrequentistTimeExperiment:NonConvergentSample',result.Name))
            end
        end
        
        function stop = isTargetCriteriaMet(experiment)
            acc = experiment.Accumulator;
            targetMoE = experiment.RelativeMarginOfError;
            stop = acc.checkMoE(experiment.TScore, targetMoE);
        end
        
        function handleMeasurementEvent(experiment,evt)
            idx = experiment.MeasurementPlugin.RepeatIndex;
            
            if idx == 1
                % first of a new suite element
                experiment.Accumulator.reset();
            end
            
            if idx <= experiment.NumWarmups
                % no accumulation occurs yet
                return;
            end
            
            experiment.Accumulator.accumulate(evt.Value.LastMeasuredValues);
        end
    end
end


function validateNumWarmups(input)
validateattributes(input, {'numeric'}, {'scalar','integer','nonnegative'});
end


function validateSampleSize(input)
validateattributes(input, {'numeric'}, {'scalar','integer'});
if input < 2
    error(message('MATLAB:unittest:performance:FrequentistTimeExperiment:InvalidSampleSize'));
end
end


function validateMarginOfError(input)
validateattributes(input, {'numeric'}, {'scalar','nonnegative','finite'});
end


function validateConfidenceLevel(input)
validateattributes(input, {'numeric'}, {'scalar','nonnegative','finite'});
if input > 1
    error(message('MATLAB:unittest:performance:FrequentistTimeExperiment:OutOfRangeConfidenceLevel'));
end
end


function x = lookupTScore(p,df)
% Calculate values from Student's t-distribution for ConfidenceLevel P and
% degrees of freedom DF
q = p-0.5;
z = betaincinv(2*abs(q),df/2,0.5,'upper');
x = sign(q).*sqrt(df.*(1-z)./z);
end
