classdef ( Sealed = true ) Subset
%Subset defines a part of a MATLAB array.
%   Subset(TYPE, INDEX) is an class that describes an indexing operation
%   into part of a MATLAB array.
%
%   TYPE is a string corresponding to the type of indexing operation to
%   perform.  The options are '()' for standard array indexing, '{}' for
%   cell array dereferencing, and '.' for structure field indexing. 
%
%   For '()' and '{}', INDEX is a cell array with range bounds for every
%   dimension in an array.  The bounds are either a pair, [dimStart
%   dimEnd], or a triple, [dimStart step dimEnd], of numbers.
%
%   For '.', INDEX is a cell array with fieldnames. Fieldnames must be
%   valid MATLAB structure fieldnames.
%
%   For example, the following produces a 6-by-5 aSubset.
%     aSubset = matlab.internal.language.Subset('()',{[5 10], [1 5 26]})
%
%   See also VariableSubset, SAVE, LOAD

% Copyright 2009 The MathWorks, Inc.

properties (SetAccess = private)
    Type;
    Index;
end % properties

methods
    function obj = set.Type(obj,aType)
        if  ischar(aType) && ~isempty(regexp(aType, '^(\.|\(\)|{})$', 'ONCE'))
            obj.Type = aType;
        else
            throwAsCaller(CatalogException(message('MATLAB:Subset:ImproperType')));
        end
    end
    
    function obj = set.Index(obj, index)
        if ~iscell(index)
            throwAsCaller(CatalogException(message('MATLAB:Subset:indexNotCell')));
        end
      
        if ~strcmp(obj.Type,'.')
            % Check that index is a row vector.
            if ~(size(index,2) >= 2 && size(index,1)==1 && ndims(index) == 2)
                throwAsCaller(CatalogException(message('MATLAB:Subset:ImproperIndexCell')));
            end
        
            % Validate that the pairs and triples in the Index satisfy all the
            % conditions.
            for i = 1:length(index)
                % Validate that indices in the bounds are numeric, integer,
                % nonnegative, and a row vector
                boundsInvalid = validateBounds(index{i}, i, class(obj));
                if ~isempty(boundsInvalid)
                    throwAsCaller(boundsInvalid);
                end

                % Validate that bounds are a pair or triple
                if length(index{i}) < 2 || length(index{i}) > 3
                    throwAsCaller(CatalogException(message('MATLAB:Subset:ImproperIndexBounds')));
                end

                % Validate that the bounds' max > min.
                if (index{i}(1) > index{i}(end))
                    throwAsCaller(CatalogException(message('MATLAB:Subset:MinMax')));
                end
            end
        else
            for i = 1:length(index)
                % Check that index is a row vector.
                if ~(size(index,2) >= 1 && size(index,1)==1 && ndims(index) == 2)
                    throwAsCaller(CatalogException(message('MATLAB:Subset:ImproperIndexCellForStructs')));
                end
                if ~isvarname(index{i})
                    throwAsCaller(CatalogException(message('MATLAB:Subset:indexNotFieldname',i)));
                end
            end
        end
        
        obj.Index = index;
    end
    
    function obj = Subset(aType, index)
        obj.Type = aType;
        obj.Index =  index;
    end
end % methods

end % classdef

% Helper functions
function boundsInvalid = validateBounds(index, i, funName)
    boundsInvalid = MException.empty;
    try
        validateattributes(index, {'numeric'},{'integer', 'positive', 'row'}, funName)
    catch validateException
        boundsInvalid = CatalogException(message('MATLAB:Subset:IndexBoundsInvalid', i));
        boundsInvalid = addCause(boundsInvalid, validateException);
    end
end

% ------------------------------------------------
function me = CatalogException(message)
% Helper function for MException

me = MException(message.Identifier, '%s', message.getString);

end