function this = subsasgnParens(this,s,rhs)

%   Copyright 2014-2017 The MathWorks, Inc.

if ~isstruct(s), s = struct('type','()','subs',{s}); end

if ~isscalar(s)
    switch s(2).type
    case '.'
        name = s(2).subs;
        if any(strcmp(name,{'Format' 'TimeZone'}))
            error(message('MATLAB:datetime:SubArrayPropertyAssignment',name,name,name));
        end
        % Setting sub-element properties (e.g. dt(2).Month = 1): get the
        % subArray, set the properties, then reassign the subarray back
        % into the larger array as though it were the RHS.
        subThis = subsrefParens(this,s(1));
        rhs = subsasgnDot(subThis,s(2:end),rhs);
        s = s(1);
    case {'()' '{}'}
        error(message('MATLAB:datetime:InvalidSubscriptExpr'));
    end
end

thisData = this.data;
szIn = size(thisData);
% Check isnumeric/isequal before builtin to short-circuit for performance
% and to distinguish between '' and [].
deleting = isnumeric(rhs) && isequal(rhs,[]) && builtin('_isEmptySqrBrktLiteral',rhs);
if isa(rhs,'datetime')
    if isa(this,'datetime') % assignment from a datetime array into another
        % Check that both datetimes either have or don't have timezones
        if isempty(this.tz) ~= isempty(rhs.tz)
            if ~isempty(rhs.tz) || any(isfinite(rhs))
                error(message('MATLAB:datetime:IncompatibleTZ'));
            else
                % Allow an unzoned NaT/Inf as the RHS even for assignment to zoned
            end
        elseif ~isempty(this.tz)
            if strcmp(this.tz,datetime.UTCLeapSecsZoneID) ~= strcmp(rhs.tz,datetime.UTCLeapSecsZoneID)
                error(message('MATLAB:datetime:IncompatibleTZLeapSeconds'));
            end
        end
        rhs_data = rhs.data;
        thisData(s.subs{:}) = rhs_data;
    else
        error(message('MATLAB:datetime:InvalidAssignmentLHS',class(rhs)));
    end
elseif isstring(rhs) || matlab.internal.datatypes.isCharStrings(rhs) % assignment from date strings
    rhs = autoConvertStrings(rhs,this);
    rhs_data = rhs.data;
    thisData(s.subs{:}) = rhs_data;
elseif isa(rhs, 'missing')
    rhs_data = nan(size(rhs));
    thisData(s.subs{:}) = rhs_data;
elseif deleting % deletion by assignment
    thisData(s.subs{:}) = [];
elseif isnumeric(rhs)
    error(message('MATLAB:datetime:InvalidNumericAssignment',class(this)));
else
    error(message('MATLAB:datetime:InvalidAssignment',class(this)));
end

% Infill with NaN, not 0
if ~isequal(size(thisData),szIn) && ~deleting
    nondefault = true(szIn); % pre-existing elements
    nondefault(s.subs{:}) = true(size(rhs_data)); % assigned elements
    thisData(~nondefault) = complex(NaN,0); % elements that were created by expansion, but not assigned
end

this.data = thisData;
