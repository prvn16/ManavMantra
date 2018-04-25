function that = subsref(this,s)

%   Copyright 2014 The MathWorks, Inc.

try

    switch s(1).type
    case '()'
        that = subsrefParens(this,s);
    case '.'
        that = subsrefDot(this,s);
    case '{}'
        error(message('MATLAB:calendarDuration:CellReferenceNotAllowed'));
    end

catch ME
    throwAsCaller(ME);
end
