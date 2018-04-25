function propVal = eml_getfimathprop_helper(F,propName)
% Helper function that returns the property value of the fimath F
% for its property PROPNAME    

% Copyright 2006-2012 The MathWorks, Inc.

narginchk(2,2);

if ~isfimath(F)
    error(message('fixed:fimath:inputNotFimath'));
end

propVal = get(F,propName);

%------------------------------------------------------------------
