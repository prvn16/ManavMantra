classdef MeasurementResult < matlab.mixin.CustomDisplay
    % MeasurementResult - Result of measuring a test suite
    %
    %   The matlab.unittest.measurement.MeasurementResult class holds
    %   information describing the result from running a measurement experiment
    %   on a test suite. It contains information about the measurement values
    %   collected and their corresponding functional test results. This
    %   information is presented as a table.
    %
    %   The MeasurementResult array obtained from running an experiment is
    %   of the same size as the suite which was run.
    %
    %   MeasurementResult properties:
    %       Name          - The name of the TestSuite for this result
    %       Valid         - Logical value showing if the measurement is valid
    %       Samples       - Table describing the collected samples
    %       TestActivity  - Table describing collected measurements including
    %                        all Test Activity
    %
    %   The Samples table presents the following information about the
    %   experimental data:
    %
    %       Name          - The name of the TestSuite element appended with
    %                       measurement label, if specified
    %       MeasuredValue - Measurement value collected
    %       Timestamp     - Time when a measurement was collected
    %       Host          - Machine name where measurement was collected
    %       Platform      - Platform architecture where measurement was collected
    %       Version       - MATLAB Version where measurement was collected
    %       RunIdentifier - Categorical value to uniquely identify the run
    %
    %   The TestActivity table presents the following in addition to the
    %   above:
    %
    %       Passed        - Logical value showing if the test passed
    %       Failed        - Logical value showing if the test failed
    %       Incomplete    - Logical value showing if test did not run to completion
    %       Objective     - Categorical value marking as "sample" or otherwise
    %       TestResult    - TestResult object for the test
    %
    %   MeasurementResult methods:
    %       samplefun     - Apply a function across the Samples of a MeasurementResult array
    %       sampleSummary - Create a table of summary statistics from a MeasurementResult array
    %
    %   See also: matlab.unittest.TestResult
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        % Name - The name of the TestSuite for this result
        %
        %   The Name property is a string that holds the name of the test
        %   corresponding to this result.
        Name = '';
    end
    
    properties (Constant, Access = private)
        DefaultMeasuredVariableName = 'MeasuredValue';
        DefaultTimestamp = createDefaultTimestamp;
        DefaultObjective = categorical({'sample'});
        DefaultTestResult = matlab.unittest.TestResult;
        DefaultRunIdentifier = categorical({''});
        DefaultIteration = 1;
    end
    
    properties (Hidden, SetAccess = immutable)
        MeasuredVariableName = matlab.unittest.measurement.MeasurementResult.DefaultMeasuredVariableName;
        RunIdentifier = matlab.unittest.measurement.MeasurementResult.DefaultRunIdentifier;
        NewRowPrototype = createNewTestActivityRow;
    end
    
    properties (SetAccess=private, Dependent)
        
        % Valid - Logical value showing if the measurement is valid
        Valid;
        
        % Samples - Table describing collected sample measurements. A test
        % suite element containing multiple labels is split into distinct
        % samples.
        %
        % The Samples table presents the following information about the
        %   experimental data:
        %
        %       Name
        %           The name of the TestSuite element represented as a string.
        %           If a measurement label is specified, Name is appended
        %           with the measurement label delimited by angle brackets.
        %       MeasuredValue
        %           Measurement value collected. Note that this column may
        %           be renamed by the framework to indicate a more specific
        %           label, such as "MeasuredTime".
        %       Timestamp
        %           Time when a measurement is collected
        %       Host
        %           Machine name where measurement was collected
        %       Platform
        %           Platform architecture where measurement was collected
        %       Version
        %           MATLAB Version where measurement was collected
        %       RunIdentifier
        %           Value to uniquely identify the run.
        %
        % See also TestActivity.
        Samples;
        
        % TestActivity - Table describing all test activity
        %
        %   The TestActivity table presents a superset of the Samples
        %   table, providing the following additional columns:
        %
        %       Passed
        %           Logical value showing if the test passed
        %       Failed
        %           Logical value showing if the test failed
        %       Incomplete
        %           Logical value showing if test did not run to completion
        %       Objective
        %           Categorical value marking as "sample" or otherwise
        %       TestResult
        %           Functional test result from running the test
        %
        % See also Samples.
        TestActivity
    end
    
    properties(Hidden)
        CalibrationResult = matlab.unittest.measurement.MeasurementResult.empty;
        InternalTestActivity = createEmptyTestActivity;
        
        CalibrationValue = 0;
    end
    
    properties(Hidden, Dependent)
        LabelList;
        NumLabels;
    end
    
    properties(Hidden)
        LastMeasurements;
        
        % LastMeasuredValues - Last measured values
        %
        %   Stored in containers map instead of an array because there is no
        %   guarantee we have matching labels in every iteration.
        LastMeasuredValues;
    end

    methods (Hidden)
        
        function result = MeasurementResult(names, measuredVariableName, runIdentifier)
            import matlab.unittest.measurement.MeasurementResult;
            
            if nargin < 1
                result.LastMeasurements = containers.Map();
                result.LastMeasuredValues = containers.Map();
                return % Allow preallocation
            end
                    
            names = cellstr(names);
            numResults = numel(names);
            
            if numResults < 1
                result = MeasurementResult.empty;
            else
                for i = 1:numResults
                    result(i) = MeasurementResult;
                end
                [result.Name] = names{:};
                
                if nargin > 1
                    [result.MeasuredVariableName] = deal(measuredVariableName);
                    if nargin > 2
                        [result.RunIdentifier] = deal(runIdentifier);
                    end
                end
            end
            result = reshape(result, size(names));
            
        end
        
        
        function result = newTestRun(result,iter)
            if nargin < 2
                iter = result.DefaultIteration;
            end
            newrow = result.NewRowPrototype;
            newrow.Iteration = iter;
            result.InternalTestActivity(end+1,:) = newrow; %performance tweak
        end
        
        function [T,I] = splitByLabels(result)
            % Split each MeasurementResult in the result array by different
            % labels and concatenate them horizontally into T.
            
            % The output I stores the original indices of the
            % MeasurementResults before split.
            
            % Example:
            %     R is an 1*2 MeasurementResult array, where R(1) has
            %     two labels 'foo' and 'baz' and R(2) has only '_implicit'.
            %     By calling [T, I] = splitByLabels(MR), T will be an 1*3
            %     MeasurementResult array with T(1) and T(2) each holding
            %     the measurements in R(1) with label 'foo' and 'baz',
            %     respectively, and T(3) being identical to R(2). In this
            %     case, I = [1, 1, 2];
            
            I = [];
            if isempty(result)
                T = result;
                return;
            end
            resultIndex = reshape(1:numel(result),size(result));
            T = arrayfun(@expandresult,result,resultIndex,'UniformOutput',false);
            T = [T{:}];
            
            function out = expandresult(resultElement,index)
                N = resultElement.NumLabels;
                if N > 1
                    activity = resultElement.InternalTestActivity;
                    out = repmat(resultElement, 1, N);
                    I = [I, repmat(index, 1, N)];
                    for i = 1:N
                        rows = strcmp(activity.Label,resultElement.LabelList{i});
                        out(i).InternalTestActivity = activity(rows,:);
                    end
                else
                    I = [I, index];
                    out = resultElement;
                end
            end
        end
        
    end
    
    methods (Hidden, Static)
        function result = loadobj(savedResult)
            import matlab.unittest.measurement.MeasurementResult; 
            
            if isstruct(savedResult)
                result = MeasurementResult(savedResult.Name, ...
                    savedResult.MeasuredVariableName, savedResult.RunIdentifier);
                result.CalibrationResult = savedResult.CalibrationResult;
                result.CalibrationValue = savedResult.CalibrationValue;    
            else
                result = savedResult;
            end
            
            activity = savedResult.InternalTestActivity;
            if ~hasLabelColumn(activity) || isempty(activity.Label)
                % For results generated and saved prior to R2018a or result
                % that has an empty activity table, we use "_missing" as a
                % special placeholder label
                activity.Label = repmat({'_missing'},height(activity),1);
            end
            result.InternalTestActivity = activity;
        end
    end
    
    methods
        
        function valid = get.Valid(result)
            testResult = result.InternalTestActivity.TestResult;
            valid = all([testResult.Passed]);
        end
        
        function samples = get.Samples(result)
            
            activity = result.InternalTestActivity;
            
            % Restrict to just the samples
            samples = activity(activity.Objective == categorical({'sample'}),:);
            
            % Include measurement information
            samples = result.expandMeasurementInfo(samples);
            
            % Sort samples by label name and creation order
            [index,~] = find(string(samples.Label) == result.LabelList.');
            
            % Arrange the table as desired
            samples = samples(index, ...
                {'Name', result.MeasuredVariableName, 'Timestamp', 'Host', 'Platform', 'Version', 'RunIdentifier'});
        end
        
        function activity = get.TestActivity(result)
            activity = result.InternalTestActivity;
            
            % Include measurement information
            activity = result.expandMeasurementInfo(activity);
            
            % Add test information
            testResult = activity.TestResult;
            activity.Passed = [testResult.Passed].';
            activity.Failed = [testResult.Failed].';
            activity.Incomplete = [testResult.Incomplete].';
            
            % Arrange the table as desired
            activity = activity(:, ...
                {'Name', 'Passed', 'Failed', 'Incomplete', result.MeasuredVariableName, 'Objective', 'Timestamp', 'Host', 'Platform', 'Version','TestResult', 'RunIdentifier'});
        end

        function num = get.NumLabels(result)
            num = length(result.LabelList);
        end
        
        function labels = get.LabelList(result)
            labels = unique(result.InternalTestActivity.Label,'stable');
        end
        
        function varargout = samplefun(fun, result, varargin)
            %SAMPLEFUN Apply a function across the Samples of a MeasurementResult array
            %
            %   A = SAMPLEFUN(FUN, R) applies the function FUN to the
            %        measured values of the Samples on each element of the
            %        MeasurementResult array R, ignoring any specified
            %        measurement labels in measurement boundaries.
            %        The output A will have the same size and shape as R.
            %
            %   A = SAMPLEFUN(FUN, R, 'UniformOutput', VALUE) indicates
            %        whether or not the output(s) of FUN can be returned
            %        without encapsulation in a cell array. If true (the
            %        default), FUN must return scalar values that can be
            %        concatenated into an array. If false, SAMPLEFUN
            %        returns a cell array.
            %
            %   [A, B, ...] = SAMPLEFUN(FUN, R, ...) where FUN is a
            %        function handle that returns multiple outputs, returns
            %        arrays A, B, ..., each corresponding to one of the
            %        output arguments of FUN.
            %
            %   Examples:
            %
            %       % Calculate the mean of each element's Samples
            %       Y = SAMPLEFUN(@mean, R)
            %
            %       % Calculate the minimums with their associated indices
            %       [Y, I] = SAMPLEFUN(@min, R)
            
            validateattributes(fun, {'function_handle'}, {'scalar'});
            % guaranteed result ISA MeasurementResult via method-dispatch
            
            parser = inputParser;
            parser.PartialMatching = true;
            parser.addParameter('UniformOutput', true, ...
                @(x) isequal(x,true) || isequal(x,false) );
            parser.parse(varargin{:});
            
            try
                [varargout{1:nargout}] = arrayfun(...
                    @(r)wrapperfun(fun, r), result, ...
                    'UniformOutput', parser.Results.UniformOutput);
            catch e
                % Avoid displaying errors from ARRAYFUN directly, make
                % SAMPLEFUN the thrower for a clearer message.
                throw(e);
            end
            
            function varargout = wrapperfun(fun, resultElement)
                
                activity = resultElement.InternalTestActivity;
                
                samples = activity.Measurement(activity.Objective == categorical({'sample'}));
                values =  resultElement.getTaredMeasurementValues(samples);
                
                [varargout{1:nargout}] = fun(values);
            end
            
        end
        
        function T = sampleSummary(result)
            %SAMPLESUMMARY - create a table of summary statistics from a MeasurementResult array.
            %
            %   T = SAMPLESUMMARY(R) creates a summary table from the
            %         Samples of a MeasurementResult array R that contains
            %         the following columns:
            %          - Name, SampleSize, Mean, StandardDeviation, Min, Median, Max
            %
            % See also matlab.unittest.measurement.MeasurementResult/samplefun.
            
            % split by labels, and columnize upfront so all data is in column format
            result = result.splitByLabels;
            result = result(:);
            
            % Prepare Name column
            MeasurementName = cell(size(result));
            
            for i = 1: length(result)
                if result(i).NumLabels == 0
                    MeasurementName(i) = {result(i).Name};                    
                else
                    MeasurementName(i) = {result(i).appendLabelToName(result(i).LabelList)};
                end
            end
            
            Name = vertcat(MeasurementName{:}); %#ok<PROP>
            
            [SampleSize, Sum, Var, Min, Median, Max] = samplefun(@runstats, result);
            % vectorize outside where possible
            StandardDeviation = sqrt(Var);
            Mean = Sum ./ SampleSize;
            
            T = table(Name, SampleSize, Mean, StandardDeviation, Min, Median, Max); %#ok<PROP> 
            
            function [N, Sum, Var, Min, Median, Max] = runstats(X)
                N = length(X);
                if N == 0
                    [Sum, Var, Min, Median, Max] = deal(NaN);
                else
                    Sum    = sum(X);
                    Var    = var(X);
                    Min    = min(X);
                    Median = median(X);
                    Max    = max(X);
                end
            end
            
        end
        
    end
    
    
    methods (Hidden, Access = protected)
        
        function footerStr = getFooter(result)
            % getFooter - Override of the matlab.mixin.CustomDisplay hook method
            %   Displays a summary of the measurement results.
            
            import matlab.unittest.internal.diagnostics.indent;
            
            totals = getString(message('MATLAB:unittest:measurement:MeasurementResult:Totals'));
            
            validInvalid = ...
                getString(message('MATLAB:unittest:measurement:MeasurementResult:ValidInvalid', ...
                nnz([result.Valid]), ...
                nnz(~[result.Valid])));
            
            indention = '   ';
            footerStr = sprintf('%s\n%s\n', totals, ...
                indent(validInvalid,indention));
        end
        
    end
    
    
    methods(Access=private)
        
        function T = expandMeasurementInfo(result, T)
            
            T.Name = result.appendLabelToName(T.Label);
            
            T.RunIdentifier = repmat(result.RunIdentifier, [height(T), 1]);
            
            measurement = T.Measurement;
            T.Timestamp = [measurement.Timestamp].';
            T.Host = [measurement.Host].';
            T.Platform = [measurement.Platform].';
            T.Version = [measurement.Version].';
            
            % Get tared result
            T.(result.MeasuredVariableName) = result.getTaredMeasurementValues(measurement);
        end
        
        function taredValues = getTaredMeasurementValues(result, measurements)
            % Get the tared values from measurements and return them as an array
            % Using for loop instead of arrayfun because for loop is faster
            tare = result.CalibrationValue;
            N = length(measurements);
            taredValues = cell(N,1);
            for i = 1:N
                taredValues{i} = measurements(i).getTaredValue(tare);
            end
            taredValues = vertcat(taredValues{:});
        end
        
        function measName = appendLabelToName(result,labels)
            % Append name with array of labels and return a measName array which
            % is the same length as labels.
            name = result.Name;
            measName = categorical(arrayfun(@(x)appending(name,x),labels));
            function t = appending(name,label)
                t = {name};
                if ~startsWith(label,'_')
                    t = strcat(name,' <',label,'>');
                end
            end
        end
        
    end
    
end


function ts = createDefaultTimestamp
ts = NaT;
ts.Format = 'default';
end

function t = createEmptyTestActivity
t = createNewTestActivityRow;
t(1,:) = [];
end

function row = createNewTestActivityRow
import matlab.unittest.measurement.MeasurementResult;
import matlab.unittest.measurement.internal.DefaultMeasurement;

row = table;
row.Measurement = DefaultMeasurement;
row.Objective = MeasurementResult.DefaultObjective;
row.TestResult = MeasurementResult.DefaultTestResult;
row.Label = {'_implicit'};
row.Iteration = MeasurementResult.DefaultIteration;
end

function tf = hasLabelColumn(T)
tf = ismember('Label',T.Properties.VariableNames);
end