%DataProcessor
% The interface for all data processor classes.
%
% Each Data Processor processes chunks of input from zero or more input
% sources to generate chunks of output.
%
% One Data Processor will be instantiated for each execution partition
% associated with an ExecutionTask. It is the job of the data processor to
% receive all input for this partition/ExecutionTask combination and to
% generate the required output.
%

%   Copyright 2015 The MathWorks, Inc.

classdef (Abstract) DataProcessor < handle & matlab.mixin.Copyable
    properties (Abstract, SetAccess = private)
        % A scalar logical that specifies if this data processor is
        % finished. A finished data processor has no more output or
        % side-effects.
        IsFinished;
        
        % A vector of logicals that describe which inputs are required
        % before this can perform any further processing. Each logical
        % corresponds with the input of the same index.
        IsMoreInputRequired;
    end
    
    methods (Abstract)
        %PROCESS Process the next chunk of data.
        %
        % Syntax:
        %  [data, partitionIndices] = process(obj, isLastOfInput, varargin)
        %
        % Inputs:
        %  - obj is the instance itself.
        %  - isLastOfInputs is a logical scalar indicating whether there
        %  potentially exists any more input after this call to process.
        %  The process method is guaranteed to always be called at least
        %  once with isLastOfInputs set to true.
        %  - varargin is the actual input itself. Each of varargin will be
        %  a chunk from the respective input source.
        %
        % Outputs:
        %  - data is an chunk of output from this data processor.
        %  - partitionIndices is a column vector of partition indices into
        %  the output partitioning where each slice of data should be sent.
        %  This is required to have the same size in tall dimension as the
        %  output data. This is only required if the associated
        %  ExecutionTask has Any-To-Any output communication type.
        %
        [data, partitionIndices] = process(obj, isLastOfInputs, varargin);
    end
end
