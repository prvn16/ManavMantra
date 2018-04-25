function [varargout] = split(this,units)
%SPLIT Split calendar durations into equivalent numeric date/time units.
%   [...] = SPLIT(T,UNITS) splits the calendar durations in T into separate
%   numeric arrays, one for each of the date/time units in UNITS. UNITS is one
%   of the strings 'Years', 'Quarters, 'Months', 'Weeks', 'Days', or 'Time', or
%   a cell array containing one or more of those strings.
%
%   SPLIT returns numeric arrays of whole numbers for years, quarters, months,
%   weeks, and days, with larger units (when specified) taking precedence.
%   However, values for weeks and days are separate from values for years,
%   quarters, and months. SPLIT returns an array of durations for time, and
%   values for time are separate from all of the calendar units.
%
%   Examples:
%      dt = calmonths(15:17) + caldays(8) + hours(1.2345)
%      [y,q,m,d,t] = split(dt,{'years' 'quarters' 'months' 'days' 'time'})
%      m = split(dt,'months')
%
%   See also CALYEARS, CALQUARTERS, CALMONTHS, CALWEEKS, CALDAYS, TIME,
%            CALENDARDURATION.

%   Copyright 2014-2017 The MathWorks, Inc.

units = checkComponents(units);
nargoutchk(0,length(units));
varargout = cell(1,min(length(units),max(nargout,1)));

% Expand scalar zero placeholders out to the full size. May also have to put
% appropriate nonfinites into elements of fields that were expanded.
components = calendarDuration.expandScalarZeroPlaceholders(this.components);
[components,nonfiniteElems,nonfiniteVals] = calendarDuration.reconcileNonfinites(components);
mo = components.months; d = components.days; ms = components.millis;

for i = 1:length(varargout)
    switch units{i}
    case 'years'
        y = fix(mo / 12);
        mo = rem(mo,12);
        if ~isempty(nonfiniteVals), mo(nonfiniteElems) = nonfiniteVals; end
        varargout{i} = y;
    case 'quarters'
        q = fix(mo / 3);
        mo = rem(mo,3);
        if ~isempty(nonfiniteVals), mo(nonfiniteElems) = nonfiniteVals; end
        varargout{i} = q;
    case 'months'
        varargout{i} = mo;
    case 'weeks'
        w = fix(d / 7);
        d = rem(d,7);
        if ~isempty(nonfiniteVals), d(nonfiniteElems) = nonfiniteVals; end
        varargout{i} = w;
    case 'days'
        varargout{i} = d;
    case 'time'
        varargout{i} = duration.fromMillis(ms);
    end
end

function components = checkComponents(components)

try

    [tf,components] = matlab.internal.datatypes.isCharStrings(components);
    if ~tf
        error(message('MATLAB:datetime:InvalidComponents'));
    end
    
    componentNames = {'years' 'quarters' 'months' 'weeks' 'days' 'time'};
    componentNums = zeros(size(components));
    for i = 1:length(components)
        str = components{i};
        tf = strncmpi(str,componentNames,max(length(str),1));
        if any(tf)
            componentNums(i) = find(tf,1);
            components{i} = componentNames{tf};
        else
            error(message('MATLAB:datetime:InvalidComponent'));
        end
    end
    
    % Since componentNames is in decreasing order, just need to check if
    % componentNames is sorted without flipping
    if ~issorted(componentNums) 
        error(message('MATLAB:datetime:InvalidComponentsOrder'));
    end
    
    componentNums = unique(componentNums); % sorted
    components = componentNames(componentNums);
    
catch ME
    throwAsCaller(ME);
end
