function this = subsasgnParens(this,s,rhs)

%   Copyright 2014-2017 The MathWorks, Inc.

if ~isstruct(s), s = struct('type','()','subs',{s}); end

if ~isscalar(s)
    switch s(2).type
    case '.'
        name = s(2).subs;
        if strcmp(name,'Format')
            error(message('MATLAB:calendarDuration:SubArrayPropertyAssignment',name,name));
        end
        subThis = subsrefParens(this,s(1));
        rhs = subsasgnDot(subThis,s(2:end),rhs);
        s = s(1);
    case {'()' '{}'}
        error(message('MATLAB:calendarDuration:InvalidSubscriptExpr'));
    end
end

if isa(rhs,'calendarDuration')
    if isa(this,'calendarDuration') % assignment from a calendarDuration array into another
        this.components = assignFields(this.components,s.subs,rhs.components);
    else
        error(message('MATLAB:calendarDuration:InvalidAssignmentLHS',class(rhs)));
    end
elseif isa(rhs, 'missing')
    this.components = assignFields(this.components,s.subs,struct('months',0,'days',0,'millis',double(rhs)));
else
    % Check isnumeric/isequal before builtin to short-circuit for performance
    % and to distinguish between '' and [].
    if isnumeric(rhs) && isequal(rhs,[]) && builtin('_isEmptySqrBrktLiteral',rhs) % deletion by assignment
        theComponents = this.components;
        fnames = fieldnames(theComponents);
        for i = 1:3
            fname = fnames{i};
            f = theComponents.(fname);
            if isequal(f,0)
                % leave the scalar zero placeholder
            else
                theComponents.(fname)(s.subs{:}) = [];
            end
        end
        this.components = theComponents;
    elseif isnumeric(rhs) && ~any(isfinite(rhs(:))) % Assigning NaN or Inf
        % Replace the specified elements of all three fields with the same nonfinite into.
        rhsComponents.months = double(rhs); rhsComponents.days = double(rhs); rhsComponents.millis = double(rhs);
        this.components = assignFields(this.components,s.subs,rhsComponents);
    else
        error(message('MATLAB:calendarDuration:InvalidAssignment',class(this)));
    end
end


function theComponents = assignFields(theComponents,subs,rhsComponents)
sz = calendarDuration.getFieldSize(theComponents);
fnames = fieldnames(theComponents);
for i = 1:3
    fname = fnames{i};
    f = theComponents.(fname);
    rf = rhsComponents.(fname);
    if isequal(rf,0) && isequal(f,0)
        % leave the scalar zero placeholder
    else
        if isequal(f,0)
            theComponents.(fname) = repmat(f,sz);
        end
        theComponents.(fname)(subs{:}) = rf; % might be scalar expansion of rf
    end
end
