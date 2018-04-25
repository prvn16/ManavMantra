%AbstractArrayMetadata Base class for tall array metadata
%   This base class manages calling a series of aggregation functions to collect
%   array metadata. Subclasses simply pass through extra aggregation and
%   reduction functions.

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Abstract) AbstractArrayMetadata < handle
    
    properties (SetAccess = immutable, GetAccess = private)
        % Struct array with fields: Name, AggregateFcn, ReduceFcn. 
        CollectionFunctions
        
        % Reference to the TallSize handle. The array size will be collected, and this
        % TallSize instance then updated.
        TallSize
    end
    
    properties (Access = private)
        % Result struct array. Each field is a metadata result, corresponding to the
        % names in CollectionFunctions.
        Result
        
        % Is the result struct ready?
        GotResult = false
    end
    
    methods
        function obj = AbstractArrayMetadata(tallSz, names, aggregateFcns, reduceFcns)
            assert(iscell(names) && iscolumn(names) && iscell(aggregateFcns) && iscell(reduceFcns), ...
                'Assertion failed: AbstractArrayMetadata inputs of incorrect type.');
            assert(isequal(size(names), size(aggregateFcns)) && isequal(size(names), size(reduceFcns)), ...
                'Assertion failed: AbstractArrayMetadata inputs of mismatching size.');
            
            obj.TallSize  = tallSz;
            names         = [names; 'Class'; 'Size'];
            aggregateFcns = [aggregateFcns; {@class; @size}];
            reduceFcns    = [reduceFcns; {@(x) x(1,:); @iSizeReduce}];
            obj.CollectionFunctions = struct('Name', names, ...
                                             'AggregateFcn', aggregateFcns, ...
                                             'ReduceFcn', reduceFcns);
        end
        
        function [aggFcn, redFcn] = getAggregateAndReduceFcns(obj)
        % Create a partitioned array that will collect the metadata
            assert(~obj.GotResult, ...
                'Assertion failed; Attempted to get functions for metadata already collected.');
            aggFcn = @(data) iPerChunk(obj.CollectionFunctions, data);
            redFcn = @(dataCell) iReduce(obj.CollectionFunctions, dataCell);
        end

        function applyResult(obj, result)
        % This method will be called with the result of collecting the
        % metadata. This might be called more than once if the same
        % partitioned array ended up being considered more than once for
        % metadata collection during 'gather'.
            if ~obj.GotResult
                obj.GotResult = true;
                for idx = 1:numel(obj.CollectionFunctions)
                    value = result{idx};
                    if iscell(value) && isscalar(value)
                        % If the computation failed, we will not get here.
                        obj.Result.(obj.CollectionFunctions(idx).Name) = value{1};
                    end
                end
                % We can also update the TallSize handle.
                obj.TallSize.Size = obj.Result.Size(1);
            end
        end
        
        function tf = hasGotResults(obj)
            tf = obj.GotResult;
        end
        
        function [gotValue, value] = getValue(obj, name)
        % Query this metadata instance to see if a value is available, and retrieve it
        % if it is.
            gotValue = false;
            value = [];
            if obj.GotResult && isfield(obj.Result, name)
                gotValue = true;
                value = obj.Result.(name);
            end
        end
        
        function disp(obj)
            if obj.GotResult
                disp(obj.Result);
            else
                disp('No results.');
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Call each aggregation function.
function dataCell = iPerChunk(collectionFunctions, data)
    dataCell = cell(1, numel(collectionFunctions));
    for idx = 1:numel(collectionFunctions)
        try
            % Wrap in extra cell to indicate that we succeeded
            dataCell{idx} = {feval(collectionFunctions(idx).AggregateFcn, data)};
        catch
            % Couldn't compute - leave empty.
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Call each reduction function.
function outCell = iReduce(collectionFunctions, inCell)
    numArgs = size(inCell, 2);
    assert(numArgs == numel(collectionFunctions), ...
        'Assertion failed: Received %i inputs when expected %i inputs.', ...
        numArgs, numel(collectionFunctions));
    outCell = cell(1, numArgs);
    for idx = 1:numArgs
        columnCell = inCell(:, idx);
        if all(cellfun(@iscell, columnCell))
            % Unpack the extra layer of cell-ness used to protect erroring chunks
            try
                tmpCell = cellfun(@(x) x{1}, columnCell, 'UniformOutput', false);
                outCell{idx} = {feval(collectionFunctions(idx).ReduceFcn, vertcat(tmpCell{:}))};
            catch
                % Couldn't compute
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reduce size - sum the first element, retain the remaining elements.
function out = iSizeReduce(in)
    out = [sum(in(:, 1)), in(1, 2:end)];
end
