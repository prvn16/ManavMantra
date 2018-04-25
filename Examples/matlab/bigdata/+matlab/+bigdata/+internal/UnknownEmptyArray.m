%UnknownEmptyArray
% An empty array where either the small size or the type is not known.
%
% This exists to give specific chunks of output the permission to change
% size and/or type during a vertical concatenation with other chunks of the
% same array. Tall array algorithms are allowed to return this instead of
% an empty chunk if the size and/or type cannot be known.
%
% Note, this will never be passed as input to any operation. It will either
% merge with other chunks of the same array, or it will be converted to a
% default representation such as [] or zeros(0,sz1,sz2,..).

% Copyright 2017 The MathWorks, Inc.

classdef UnknownEmptyArray < matlab.bigdata.internal.TaggedArray
    properties (GetAccess = private, SetAccess = immutable)
        % A sample of the empty data. If size is not known, this will have
        % size [0,0]. If type is not known, this will be of type double.
        Sample;
        
        % Logical scalar that is true if we know the small sizes of this array.
        HasSize;
        
        % Logical scalar that is true if we know the small sizes of this array.
        HasType = true;
    end
    
    methods (Static)
        function obj = build(sz, type)
            % Build a UnknownEmptyArray from the given size and type. Both
            % size and type are optional and can be empty.
            hasSize = (nargin >= 1 && ~isempty(sz));
            if ~hasSize
                sz = [0,0];
            end
            
            hasType = (nargin >= 2 && ~isempty(type));
            if ~hasType
                type = 'double';
            end
            
            assert(sz(1) == 0, ...
                'Assertion failed: Attempted to construct an UnknownEmptyArray with non-zero first dimension size.');
            sample = iBuildSample(sz, type);
            obj = matlab.bigdata.internal.UnknownEmptyArray(sample, hasSize, hasType);
        end
        
        function tf = isUnknown(obj)
            tf = isa(obj, 'matlab.bigdata.internal.UnknownEmptyArray');
        end
    end
    
    methods
        function out = getSample(obj)
            % Get the underlying sample from an UnknownEmptyArray.
            out = obj.Sample;
        end
        
        function tf = hasSize(obj)
            % Check if we know the size information. This is exposed as a
            % method because the custom implementation of subsref doesn't
            % allow for direct property access.
            tf = obj.HasSize;
        end
        
        function tf = hasType(obj)
            % Check if we know the type information. This is exposed as a
            % method because the custom implementation of subsref doesn't
            % allow for direct property access.
            tf = obj.HasType;
        end
        
        function sz = size(obj, varargin)
            % Override of size. This is required by size asserting
            % operations.
            sz = size(obj.Sample, varargin{:});
        end
        
        function obj = reshape(obj, varargin)
            % Override of reshape. This is required for
            % matlab.bigdata.internal.util.indexSlices.
            obj = obj.applyUsingSample(@reshape, varargin{:});
        end
        
        function out = vertcat(varargin)
            % Override of vertcat. This will merge unknown empty arrays
            % with known sizes and types where possible.
            
            isUnknown = cellfun(@matlab.bigdata.internal.UnknownEmptyArray.isUnknown, varargin);
            hasSize = true(nargin, 1);
            hasType = true(nargin, 1);
            [varargin(isUnknown), hasSize(isUnknown), hasType(isUnknown)] ...
                = cellfun(@unwrap, varargin(isUnknown));
            
            out = matlab.bigdata.internal.util.vertcatCellContents(varargin);
            
            % Logical is weaker to double. We need to ensure unknown types
            % do not override logical.
            if any(hasType) && all(cellfun(@islogical, varargin(hasType)))
                out = logical(out);
            end
            
            hasSize = any(hasSize);
            hasType = any(hasType);
            if ~hasSize || ~hasType
                out = matlab.bigdata.internal.UnknownEmptyArray(out, hasSize, hasType);
            end
        end
        
        function obj = subsref(obj, S)
            % Override of subsref. This is required for re-chunking and
            % buffering operations.
            assert(numel(S) == 1, ...
                'Assertion failed: Attempted to use unsupported multi-level indexing on an UnknownEmptyArray.');
            assert(S(1).type == "()", ...
                'Assertion failed: Attempted to use unsupported %s indexing on an UnknownEmptyArray.', ...
                S(1).type);
            
            obj = obj.applyUsingSample(@subsref, S(1));
        end
    end
    
    % Overrides of TaggedArray interface.
    methods
        function value = getUnderlying(obj)
            % Get the array underlying this UnknownEmptyArray.
            value = getSample(obj);
        end
    end
    
    methods (Access = private)
        function obj = UnknownEmptyArray(sample, hasSize, hasType)
            % Private constructor for the static build function.
            obj.Sample = sample;
            obj.HasSize = hasSize;
            obj.HasType = hasType;
        end
        
        function obj = applyUsingSample(obj, fcn, varargin)
            % Apply the given function handle to the underlying sample and
            % return the result as an UnknownEmptyArray.
            sample = obj.Sample;
            sample = feval(fcn, sample, varargin{:});
            obj = matlab.bigdata.internal.UnknownEmptyArray(sample, obj.HasSize, obj.HasType);
        end
        
        function [sample, hasSize, hasType] = unwrap(obj)
            % Retrieve the underlying properties of an UnknownEmptyArray.
            sample = {obj.Sample};
            hasSize = obj.HasSize;
            hasType = obj.HasType;
        end
    end
end

function sample = iBuildSample(sz, type)
% Build a sample from the given type.
adaptor = matlab.bigdata.internal.adaptors.getAdaptorForType(type);
sample = adaptor.buildSample(type, sz);
end

