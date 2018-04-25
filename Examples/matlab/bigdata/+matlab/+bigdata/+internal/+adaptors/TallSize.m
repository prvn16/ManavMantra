%TallSize object that represents a size in the tall dimension

% Copyright 2016-2017 The MathWorks, Inc.

classdef TallSize < handle

    properties (Dependent)
        % Scalar double indicating size, or NaN if not known
        Size
    end
    
    properties (Access = private)
        SizeImpl = NaN
    end
    
    properties (SetAccess = private, ...
                GetAccess = ?matlab.bigdata.internal.adaptors.AbstractAdaptor)
        % IsDefinitelyNonUnity true only if this tall size is guaranteed to be
        % non-unity.
        IsDefinitelyNonUnity = false
        
        % IsDefinitelyNonZero true only if this tall size is guaranteed to be non-zero
        IsDefinitelyNonZero = false
    end
    
    properties (SetAccess = immutable)
        % Id of this tall size to make it easier to check whether size information is
        % being propagated.
        Id
    end
    methods (Access = private)
        function obj = TallSize(val, isDefinitelyNonUnity, isDefinitelyNonZero)
            obj.Id = iNextId();
            obj.SizeImpl = val;
            obj.IsDefinitelyNonUnity = isDefinitelyNonUnity;
            obj.IsDefinitelyNonZero = isDefinitelyNonZero;
        end
    end
    methods (Static)
        function obj = buildDefault()
            obj = matlab.bigdata.internal.adaptors.TallSize(NaN, false, false);
        end
        function obj = buildKnownSize(val)
            assert(isnumeric(val) && isscalar(val), ...
                'Assertion failed: Tall size must be a scalar numeric.');
            obj = matlab.bigdata.internal.adaptors.TallSize(val, val ~= 1, val ~= 0);
        end
        function obj = buildGtOne()
        % Build a Tall Size for an array that is definitely >1 in the tall dimension.
            obj = matlab.bigdata.internal.adaptors.TallSize(NaN, true, true);
        end
    end
    methods (Access = ?matlab.bigdata.internal.adaptors.AbstractAdaptor)
        function setSizeIsGtOne(obj)
            obj.IsDefinitelyNonZero = true;
            obj.IsDefinitelyNonUnity = true;
        end
    end
    
    methods
        function set.Size(obj, newVal)
        % Update the size - must be scalar double
            assert(isscalar(newVal) && isa(newVal, 'double'), ...
                'Assertion failed: Tall size must be a scalar double.');

            % Size must either be changing field away from NaN, or match the old value.
            assert(isnan(obj.SizeImpl) || obj.SizeImpl == newVal, ...
                'Assertion failed: Tall size %i does not match known value %i', newVal, obj.SizeImpl);
            
            if obj.IsDefinitelyNonUnity
                assert(newVal ~= 1, ...
                    'Assertion failed: Tall size %i does not match known IsDefinitelyNonUnity.', newVal);
            end
            if obj.IsDefinitelyNonZero
                assert(newVal ~= 0, ...
                    'Assertion failed: Tall size %i does not match known IsDefinitelyNonZero.', newVal);
            end
            obj.SizeImpl             = newVal;
            obj.IsDefinitelyNonUnity = newVal ~= 1;
            obj.IsDefinitelyNonZero  = newVal ~= 0;
        end
        function val = get.Size(obj)
            val = obj.SizeImpl;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function id = iNextId()
    persistent ID
    if isempty(ID)
        ID = 1;
    end
    id = ID;
    ID = 1 + ID;
end
