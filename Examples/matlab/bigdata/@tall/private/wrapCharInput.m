function x = wrapCharInput(x)
% Make sure we convert char arrays into strings so that they are treated as
% a single element for elementfun.

% Copyright 2016 The MathWorks, Inc.

if ischar(x)
    % Check for column or matrix char arrays before wrapping
    if ~isempty(x) && ~isrow(x)
        throwAsCaller(MException(message('MATLAB:string:PositionMustBeTextOrNumeric')));
    end
    x = string(x);
end
end
