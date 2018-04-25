classdef (Sealed = true) VariableSubset
%VariableSubset defines a part of a MATLAB array.
%   VariableSubset(NAME, SUBSETS) is a class that describes a part of a
%   MATLAB array.  NAME is a string corresponding to the name of the
%   array and must be a legal MATLAB variable name.  SUBSETS is an object
%   that defines an index into part of the array NAME.
%
%   For example, the following produces a 6-by-5 VariableSubset, varSub.
%     subsets = internal.matlab.language.Subset('()',{[5 10], [1 5 26]})
%     varSub = internal.matlab.language.VariableSubset('aVarName',subsets)
%
%   See also Subset, SAVE, LOAD

% Copyright 2009-2014 The MathWorks, Inc.

properties (SetAccess = private)
    Name;
    Subsets;
end % properties

methods
    function obj = set.Name(obj, name)
        if ~ischar(name) 
            throwAsCaller(CatalogException(message('MATLAB:VariableSubset:nameNotChar')));
        end
        if ~isvarname(name)
            throwAsCaller(CatalogException(message('MATLAB:VariableSubset:notAVariableName',name)));
        end
        obj.Name = name;
    end

    function obj = set.Subsets(obj, subsets)
        subsetClassName = 'matlab.internal.language.Subset';
        if ~isa(subsets,subsetClassName)
            throwAsCaller(CatalogException(message('MATLAB:VariableSubset:subsetNotSubset',subsetClassName)));
        end
        obj.Subsets = subsets;
    end
    
    function obj = VariableSubset(name, subsets)
        obj.Name = name;
        obj.Subsets = subsets;
    end
end % methods

end % classdef

% ------------------------------------------------
function me = CatalogException(message)
% Helper function for MException

me = MException(message.Identifier, '%s', message.getString);

end
