function this = subsasgnParens(this,s,rhs)

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.internal.datetime.datenumToMillis
import matlab.internal.datatypes.throwInstead

if ~isstruct(s), s = struct('type','()','subs',{s}); end

if ~isscalar(s)
    switch s(2).type
        case '.'
            name = s(2).subs;
            if strcmp(name,'Format')
                error(message('MATLAB:duration:SubArrayPropertyAssignment',name,name));
            end
            subThis = subsrefParens(this,s(1));
            rhs = subsasgnDot(subThis,s(2:end),rhs);
            % s = s(1); There are no per-element properties of duration
            % which can be set (as there is for datetime). The call to
            % subsasgnDot gets the proper error handling.
        case {'()' '{}'}
            error(message('MATLAB:duration:InvalidSubscriptExpr'));
    end
end

if isa(rhs,'duration')
    if isa(this,'duration') % assignment from a duration array into another
        this.millis(s.subs{:}) = rhs.millis;
    else
        error(message('MATLAB:duration:InvalidAssignmentLHS',class(rhs)));
    end
elseif isa(rhs, 'missing')
    this.millis(s.subs{:}) = double(rhs);
    % Check isnumeric/isequal before builtin to short-circuit for performance
    % and to distinguish between '' and [].
elseif isnumeric(rhs) && isequal(rhs,[]) && builtin('_isEmptySqrBrktLiteral',rhs) % deletion by assignment
    this.millis(s.subs{:}) = [];
else
    try
        if isnumeric(rhs) || islogical(rhs)
            millis = datenumToMillis(rhs,true); % allow non-double numeric
        else
            [~,millis,~] = duration.compareUtil(this,rhs);
        end
    catch ME
        throwInstead(ME,{'MATLAB:datetime:DurationConversion','MATLAB:duration:AutoConvertString','MATLAB:duration:InvalidComparison'},message('MATLAB:duration:InvalidAssignment',class(this)));
    end
    this.millis(s.subs{:}) = millis;
    
end
