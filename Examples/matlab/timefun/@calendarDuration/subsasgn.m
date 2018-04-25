function this = subsasgn(this,s,rhs)

%   Copyright 2014 The MathWorks, Inc.

try

    switch s(1).type
    case '()'
        if isnumeric(this) && isequal(this,[]) % creating, RHS must have been a calendarDuration
            this = rhs;
            this.components.months = [];
            this.components.days   = [];
            this.components.millis = [];
        end
        this = this.subsasgnParens(s,rhs);
    case '.'
        this = this.subsasgnDot(s,rhs);
    case '{}'
        error(message('MATLAB:calendarDuration:CellAssignmentNotAllowed'));
    end

catch ME
    throwAsCaller(ME);
end
