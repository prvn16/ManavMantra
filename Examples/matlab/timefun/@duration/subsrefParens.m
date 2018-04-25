function that = subsrefParens(this,s)

%   Copyright 2014 The MathWorks, Inc.

if ~isstruct(s), s = struct('type','()','subs',{s}); end

that = this;
that.millis = subsref(this.millis,s(1));
if ~isscalar(s)
    switch s(2).type
    case '.'
        that = subsrefDot(that,s(2:end));
    case {'()' '{}'}
        error(message('MATLAB:duration:InvalidSubscriptExpr'));
    end
end

