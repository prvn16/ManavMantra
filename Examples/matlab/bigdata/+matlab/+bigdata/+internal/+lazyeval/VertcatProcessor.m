%VertcatProcessor
% Data Processor that vertically concatenates the inputs.
%

%   Copyright 2017 The MathWorks, Inc.

classdef VertcatProcessor < matlab.bigdata.internal.executor.DataProcessor
    properties (SetAccess = private)
        % A scalar logical that specifies if this data processor is
        % finished. A finished data processor has no more output or
        % side-effects.
        IsFinished;
        
        % A vector of logicals that describe which inputs are required
        % before this can perform any further processing. Each logical
        % corresponds with the input of the same index.
        IsMoreInputRequired;
        
        % The function handle for error handling.
        FunctionHandle;
        
        % The input buffer.
        InputBuffer;
    end
    
    methods (Static)
        % Create a data processor factory that can be used by the execution
        % environment to construct instances of this class.
        function factory = createFactory(functionHandle, numVariables)
            factory = @createVertcatProcessor;
            function dataProcessor = createVertcatProcessor(~)
                import matlab.bigdata.internal.lazyeval.VertcatProcessor;
                dataProcessor = VertcatProcessor(copy(functionHandle), numVariables);
            end
        end
    end
    
    methods
        function data = process(obj, isLastOfInputs, varargin)
            if obj.IsFinished
                data = cell(0, 1);
                return;
            end
            
            obj.InputBuffer.add(isLastOfInputs, varargin{:});
            
            obj.IsFinished = all(isLastOfInputs);
            
            if ~all(obj.InputBuffer.IsBufferInitialized)
                assert(~obj.IsFinished, ...
                    ['Invalid ' mfilename ': InputBuffer not initialized']);
                
                data = cell(0,1);
                return;
            end
            
            % Vertically concatenate the inputs. Because the data has been
            % repartitioned by matlab.bigdata.internal.lazyeval.vertcatrepartition,
            % at most one of the inputs will be non-empty per partition.
            % The InputBuffer ensures that the remaining inputs will be
            % empty with the correct type.
            data = iPreprocessData(obj.InputBuffer.getAll());
            
            try
                data = {vertcat(data{:})};
            catch err
                obj.FunctionHandle.throwAsFunction(err);
            end
            
            % Output an empty cell array if all inputs are empty
            if isempty(data)
                data = cell(0,1);
            end
        end
    end
    
    % Private constructor for factory method.
    methods (Access = private)
        function obj = VertcatProcessor(functionHandle, numVariables)
            import matlab.bigdata.internal.lazyeval.InputBuffer
            
            obj.IsFinished = false;
            obj.IsMoreInputRequired = true(1,numVariables);
            obj.FunctionHandle = functionHandle;
            
            isInputSinglePartition = false(1, numVariables);
            obj.InputBuffer = InputBuffer(numVariables, isInputSinglePartition);
        end
    end
end

function data = iPreprocessData(data)
% Prepare input data for vertcat operation.  This function applies a
% workaround for the following behavior of vertcat using an empty string
% array with a categorical array:
% 
% >> [string.empty(0,1); categorical(2)]
% Error using categorical/cat (line 43)
% Unable to concatenate a string array and a categorical array.
% 
% Error in categorical/vertcat (line 22)
% a = cat(1,varargin{:});

containsCat = any(cellfun(@iscategorical, data));

if ~containsCat
    % No categorical inputs
    return;
end

% Work through data inputs and replace any empty string arrays with []
for ii=1:numel(data)
    if isstring(data{ii}) && isempty(data{ii})
        data{ii} = [];
    end
end

end
