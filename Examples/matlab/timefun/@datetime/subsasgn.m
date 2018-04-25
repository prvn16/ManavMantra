function this = subsasgn(this,s,rhs)

%   Copyright 2014 The MathWorks, Inc.

try

    switch s(1).type
    case '()'
        if isnumeric(this) && isequal(this,[]) % creating, RHS must have been a datetime
            this = rhs;
            this.data = [];
        end
        this = this.subsasgnParens(s,rhs);
    case '.'
        this = this.subsasgnDot(s,rhs);
    case '{}'
        error(message('MATLAB:datetime:CellAssignmentNotAllowed'))
    end

catch ME
    throwAsCaller(ME);
end
