classdef FixedTimeExperiment < matlab.perftest.TimeExperiment
    % FixedTimeExperiment - A TimeExperiment that collects a fixed number of measurements
    %
    %   The FixedTimeExperiment is used to run an experiment on a
    %   test suite to collect a fixed number of measurements.
    %
    %   To create a FixedTimeExperiment, use the withFixedSampleSize static
    %   method provided by the TimeExperiment class.
    %
    %   FixedTimeExperiment properties:
    %       NumWarmups - Number of warmup measurements
    %       SampleSize - Number of sample measurements to collect after warmup
    %
    %   Example:
    %
    %       import matlab.perftest.TimeExperiment
    %
    %       % Create a TestSuite array
    %       suite = testsuite;
    %
    %       % Create a TimeExperiment to collect fixed number of samples
    %       experiment = TimeExperiment.withFixedSampleSize(8);
    %       results = run(experiment, suite);
    %
    %       % Create a TimeExperiment to collect fixed number of samples
    %       % after warming up the code
    %       experiment = TimeExperiment.withFixedSampleSize(8, 'NumWarmups', 2);
    %       results = run(experiment, suite);
    %
    %   See also: matlab.perftest.TimeExperiment, matlab.unittest.measurement.MeasurementResult
    
    % Copyright 2015-2016 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        % NumWarmups - Number of warmup measurements
        %
        %   NumWarmups defines the number of times to exercise the code in
        %   order to warm it up. Measurements collected during these warmup
        %   runs are categorized as 'warmup' measurements.
        %
        %   See also: matlab.perftest.TimeExperiment, matlab.unittest.measurement.MeasurementResult
        NumWarmups;
        
        % SampleSize - Number of sample measurements to collect after warmup
        %
        %   SampleSize defines the number of sample measurements to collect after warmup.
        %   Measurements collected during these runs are categorized as
        %   'sample' measurements.
        %
        %   See also: matlab.perftest.TimeExperiment, matlab.unittest.measurement.MeasurementResult
        SampleSize;
    end
    
    methods (Access = ?matlab.perftest.TimeExperiment)
        function experiment = FixedTimeExperiment(varargin)
            p = matlab.unittest.internal.strictInputParser;
            p.KeepUnmatched = true;
            
            p.addRequired ('SampleSize', @validateSampleSize);
            p.addParameter('NumWarmups', 0, @validateNumWarmups);
            
            p.parse(varargin{:});
            
            experiment@matlab.perftest.TimeExperiment(p.Unmatched);
            
            experiment.SampleSize = p.Results.SampleSize;
            experiment.NumWarmups = p.Results.NumWarmups;
        end
    end
    
    methods(Hidden, Access=protected)
        function doRun(experiment, ~, runner, suite, runIdentifier)
            numMeasurements = experiment.NumWarmups + experiment.SampleSize;
            runner.runRepeatedly(suite, numMeasurements, 'RunIdentifier', runIdentifier);
        end
    end
end


function validateSampleSize(numSamples)
validateattributes(numSamples, {'numeric'}, {'positive', 'scalar', 'integer'});
end


function validateNumWarmups(numSamples)
validateattributes(numSamples, {'numeric'}, {'nonnegative', 'scalar', 'integer'});
end