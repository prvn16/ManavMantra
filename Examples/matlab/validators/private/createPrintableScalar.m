function A = createPrintableScalar(B)
% Convert B to charactor vector A appropriate for output as
% validator error message.
% B must be a scalar and its type must be numeric, logical, string, or
% enum.
% Copyright 2016 The MathWorks, Inc.

    A = '';
    if ~isscalar(B)
        return;
    end
    if ~isnumeric(B) && ~islogical(B) && ~ischar(B) && ~isa(B, 'string') && ~isenum(B)
        return;
    end

    toQuote = false;
    
    if isenum(B)
        B = [class(B) '.' char(B)];
    elseif isnumeric(B)
        B = num2str(B);
    elseif islogical(B)
        B = char(string(B));
    elseif ischar(B)
        toQuote = true;
    elseif isa(B, 'string')
        B = char(B);
        toQuote = true;
    end
    
    if toQuote 
        msg = message('MATLAB:validators:quotedName', B);
        A = getString(msg);
    else
        A = B;
    end
end
