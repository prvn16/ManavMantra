function output = set(obj,varargin)
%SET Configure or display timer object properties.
%
%    SET(OBJ) displays property names and their possible values for all
%    configurable properties of timer object OBJ. OBJ must be a single
%    timer object.
%
%    PROP_STRUCT = SET(OBJ) returns the property names and their
%    possible values for all configurable properties of timer object OBJ.
%    OBJ must be a single timer object. The return value, PROP_STRUCT, is a
%    structure whose field names are the property names of OBJ, and whose
%    values are cell arrays of possible property values or empty cell arrays
%    if the property does not have a finite set of possible values.
%
%    SET(OBJ,'PropertyName') displays the possible values
%    for the specified property, PropertyName, of timer object OBJ.
%    OBJ must be a single timer object.
%
%    PROP_CELL = SET(OBJ,'PropertyName') returns the possible values
%    for the specified property, PropertyName, of timer object OBJ.
%    OBJ must be a single timer object. The returned array, PROP_CELL,
%    is a cell array of possible values or an empty cell
%    array if the property does not have a finite set of possible
%    values.
%
%    SET(OBJ,'PropertyName',PropertyValue,...) configures the property,
%    PropertyName, to the specified value, PropertyValue, for timer
%    object OBJ. You can specify multiple property name/property
%    value pairs in a single statement. OBJ can be a single timer
%    object or a vector of timer objects, in which case SET configures
%    the property values for all the timer objects specified.
%
%    SET(OBJ,S) configures the properties of OBJ, with the values specified
%    in S, where S is a structure whose field names are object
%    property names.
%
%    SET(OBJ,PN,PV) configures the properties specified in the cell array
%    of character vectors, PN, to the corresponding values in the cell array
%    PV, for the timer object OBJ. PN must be a vector. If OBJ is an
%    array of timer objects, PV can be an M-by-N cell array, where M
%    is equal to the length of the timer object array and N is equal to
%    the length of PN. In this case, each timer object is updated with
%    a different set of values for the list of property names contained
%    in PN.
%
%    Param-value pairs, structures, and param-value cell array pairs
%    may be used in the same call to SET.
%
%    Example:
%       t = timer;
%       set(t) % Display all configurable properties and their possible values
%       set(t, 'ExecutionMode') % Display all possible values of property
%       set(t, 'TimerFcn', 'callbk', 'ExecutionMode', 'FixedRate')
%       set(t, {'StartDelay', 'Period'}, {30, 30})
%       set(t, 'Name', 'MyTimerObject')
%
%    See also TIMER, TIMER/GET.
%

%    RDD 11-20-2001
%    Copyright 2001-2017 The MathWorks, Inc.

try
    if (nargout == 0) % e.g., "set(OBJ,'PN',PV,....)"
        if nargin == 2 && ischar(varargin{1}) % e.g., "set(OBJ,'PN')"
            jObj = obj.getJobjects;
            out = set(jObj, varargin{:});
            % Get fully qualified property name.
            hProp = findprop(jObj, varargin{:});
            if ~isempty(strfind(hProp.Name, 'Fcn'))
                % We have an '...Fcn' property.
                fprintf(getString(message('MATLAB:timer:propfunction')));
            elseif isempty(out)
                propHandle = findprop(jObj, varargin{1});
                fprintf(getString(message('MATLAB:timer:propnotenumtype', propHandle.Name)));
            else
                fprintf([formatEnum(out) '\n']);
            end
        else
            ans = [];            
            set@matlab.mixin.SetGet(obj,varargin{:});           
            if ~isempty(ans) % if set returned something in ans, pass it on.
                output = ans;
            end
        end
    else % e.g., "OPT=set(OBJ)"
        if nargin==1 || (nargin == 2 && ischar(varargin{1})) % e.g., "OPT=set(OBJ,'PN')"
            jObj = obj.getJobjects;
            output = set(jObj, varargin{:});
        else
            output = set@matlab.mixin.SetGet(obj,varargin{:});
        end
    end
catch ME
    if(strcmp(ME.identifier,'MATLAB:class:noSetMethod'))
        msg = getString(message('MATLAB:class:SetProhibitedReadOnly', varargin{1}, 'timer'));
        ME = MException('MATLAB:class:SetProhibited',msg);
        throw(ME);
    end
    rethrow(ME);
end


function out = formatEnum(field)
out = ['[ {' field{1} '}' ];
for lcv2=2:length(field)
    out = [out ' | ' field{lcv2} ]; %#ok<AGROW>
end
out = [out ' ]'];
