function output = timerfind(varargin)
%TIMERFIND Find visible timer objects with specified property values.
%
%    OUT = TIMERFIND returns all visible timer objects that exist in memory.  Visible
%    timer object are timer objects that have the OBJECTVISIBILITY parameter set to
%    'on'.  The visible timer objects are returned as an array to OUT.
%
%    OUT = TIMERFIND('P1', V1, 'P2', V2,...) returns an array, OUT, of visible timer
%    objects whose property names and property values match those passed as
%    param-value pairs, P1, V1, P2, V2,... The param-value pairs can be specified as
%    a cell array.
%
%    OUT = TIMERFIND(S) returns an array, OUT, of visible timer objects whose
%    property values match those defined in structure S whose field names are timer
%    object property names and the field values are the requested property values.
%
%    OUT = TIMERFIND(OBJ, 'P1', V1, 'P2', V2,...) restricts the search for matching
%    param-value pairs to the timer objects listed in OBJ. OBJ can be an array of
%    timer objects.
%
%    Note that it is permissible to use parameter name-value pairs, structures, and
%    param-value cell array pairs in the same call to TIMERFIND.
%
%    When a property value is specified, it must use the same format as GET returns.
%    For example, if GET returns the Name as 'MyObject', TIMERFIND will not find an
%    object with a Name property value of 'myobject'. However, properties which have
%    an enumerated list data type will not be case sensitive when searching for
%    property values. For example, TIMERFIND will find an object with a ExecutionMode
%    property value of 'singleShot' or 'singleshot'.
%
%    Example:
%      t1 = timer('Tag', 'broadcastProgress', 'Period', 5);
%      t2 = timer('Tag', 'displayProgress');
%      out1 = timerfind('Tag', 'displayProgress')
%      out2 = timerfind({'Period', 'Tag'}, {5, 'broadcastProgress'})
%
%    See also TIMER/GET, TIMERFINDALL.

%    Copyright 2001-2017 The MathWorks, Inc.

% Make sure that there are an even number excepting struct arguments.
numstructs = 0;
for lcv = 1:length(varargin)
    numstructs = numstructs + isa(varargin{lcv}, 'struct');
end

if mod(nargin - numstructs, 2)
    error(message('MATLAB:timer:incompletepvpair'));
end

obj = mltimerpackage('GetList');

% Filter out the non-visible timer objects.
obj = obj(2:end); % first found jobjs is the database, so remove it

idxsToRemove = false(size(obj));
for i = 1:numel(obj)    
    idxsToRemove(i) = isInvisibleTimer(obj(i));
end
obj = obj(~idxsToRemove);


if isempty(obj)
    % e.g., no timer object found
    output = [];
else
    output = obj;
    if ~isempty(varargin)
        % e.g., timerfind('PN',PV,...);
        try
            output = sharedTimerfind(output,varargin{:});
        catch exception
            throw(exception);
        end
    end
end

end

% Helper function to detect/filter out invisible timers
function TF = isInvisibleTimer(obj)
%Java timer object can be deleted between the if (visility check) & body of the if
%check the existence of the ObjectVisibility property to allow
%support of the old timer object 1.0 java codebase
try
    TF = isfield(get(obj),'ObjectVisibility') && strcmp(obj.ObjectVisibility,'off');
catch
    TF = true;
end
end