function A = createPrintableList(B)
% Convert B to formated charactor vector A appropriate for output as validator error message
% For example
%   CreatePrintable([1 23 456]) returns
%     '____1
%      ____23
%      ____456'
%
%  _ represents a white space.
% 
% Copyright 2016 The MathWorks, Inc.

    A = '';
    if ~isnumeric(B) && ~islogical(B) && ~ischar(B) && ~iscellstr(B) && ~isa(B, 'string') && ~isenum(B)
        return;
    end

    toQuote = false;
    
    if isenum(B)
        B = enum2String(B);
    elseif isnumeric(B)
        B = num2String(B);
    elseif islogical(B)
        B = string(B);
    elseif ischar(B) || iscellstr(B)
        B = string(B);
        toQuote = true;
    elseif isa(B, 'string')
        toQuote = true;
    end
    
    A = toFormatedCharVector(B, toQuote);
end

function str = enum2String(data)
    str = string.empty;
    for idx = 1:numel(data)
        str(idx) = [class(data) '.' char(data(idx))];
    end
end

function str = num2String(data)
    str = string.empty;
    for idx = 1:numel(data)
        str(idx) = num2str(data(idx));
    end
end

function ch = toFormatedCharVector(cs, toQuote)
% Input is a string array
    ch = '';
    for i=1:numel(cs)
        ch = [ch '\n    ' toChar(cs(i), toQuote)];
    end
end

function ch = toChar(str, toQuote)
    if toQuote 
        msg = message('MATLAB:validators:quotedName', char(str));
        ch = getString(msg);
    else
        ch = char(str);
    end
end
