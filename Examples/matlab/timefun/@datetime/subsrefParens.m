function value = subsrefParens(this,s)

%   Copyright 2014 The MathWorks, Inc.

if ~isstruct(s), s = struct('type','()','subs',{s}); end

value = this;
value.data = subsref(this.data,s(1));
if ~isscalar(s)
    switch s(2).type
    case '.'
        value = subsrefDot(value,s(2:end));
    case {'()' '{}'}
        error(message('MATLAB:datetime:InvalidSubscriptExpr'));
    end
end
