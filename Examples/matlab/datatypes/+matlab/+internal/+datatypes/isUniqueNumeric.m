function tf = isUniqueNumeric(x)
% ISUNIQUENUMERIC check if a numeric array contains only unique elements
%    TF = ISUNIQUENUMERIC(X) returns true if a numeric array X contains 
%    only unique elements and false otherwise. ISUNIQUENUMERIC does not
%    check for correct type, error conditions, nor return index of unique
%    elements.
   
%   Copyright 2014 The MathWorks, Inc.

   tf = all(diff(sort(x(:))));
end