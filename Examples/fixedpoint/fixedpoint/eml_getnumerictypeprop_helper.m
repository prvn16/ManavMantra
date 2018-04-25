function propVal = eml_getnumerictypeprop_helper(T,propName)
% Helper function that returns the property value of the numerictype T
% for its property PROPNAME    

% Copyright 2006-2012 The MathWorks, Inc.

narginchk(2,2);
if ~isnumerictype(T)
    error(message('fixed:numerictype:inputMustBeNumerictype'));
end
propVal = T.(propName);

%------------------------------------------------------------------
