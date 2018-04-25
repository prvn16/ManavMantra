function y = saveobj(x)
%SAVEOBJ Save filter for FI objects whose "DataType" property is "double"

%   Copyright 2003-2012 The MathWorks, Inc.

% If x is a fi-double save it as a struct
y = [];
if (isdouble(x))
    y = struct(x);
    % Remove unnecessary fields like FractionLength & Slope
    y = rmfield(y,...
                {'FractionLength','Slope','ProductFractionLength',...
                 'ProductSlope','SumFractionLength','SumSlope'});
    % Add the double data as a field
    y.Data = double(x);
end
