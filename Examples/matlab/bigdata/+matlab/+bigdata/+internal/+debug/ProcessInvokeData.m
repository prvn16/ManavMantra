%ProcessInvokeData
% The inputs/outputs of a DataProcessor/process call for the purposes of
% the ProcessBegin / ProcessReturn / ProcessError set of events.

%   Copyright 2017 The MathWorks, Inc.

classdef (Sealed) ProcessInvokeData < handle
    properties
        % The index of this invocation relative to the start of this
        % processor. This is effectively the number of invocations of
        % Processor/process since the construction of the processor.
        InvokeIndex;
        
        % A logical vector of same size as Inputs. For each input, the
        % corresponding IsLastChunk will be true if and only if that input
        % is finished.
        IsLastChunk;
        
        % The inputs to a DataProcessor/process invocation.
        Inputs;
        
        % The output or empty. This holds the output of the
        % DataProcessor/process invocation.
        Output;
        
        % The destination partition indices associated with each row of
        % output to be used as part of an AnyToAny communication. This is
        % empty for other types of communication.
        OutputPartitionIndices;
        
        % A MException object or empty. This holds the error object if an
        % error was issued by the DataProcessor/process invocation.
        Error;
    end
end
