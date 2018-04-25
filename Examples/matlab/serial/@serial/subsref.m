function result = subsref(obj, Struct)
%SUBSREF Subscripted reference into serial port objects.
%
%   SUBSREF Subscripted reference into serial port objects.
%
%   OBJ(I) is an array formed from the elements of OBJ specified by the
%   subscript vector I.
%
%   OBJ.PROPERTY returns the property value of PROPERTY for serial port
%   object OBJ.
%
%   Supported syntax for serial port objects:
%
%   Dot Notation:                  Equivalent Get Notation:
%   =============                  ========================
%   obj.Tag                        get(obj,'Tag')
%   obj(1).Tag                     get(obj(1),'Tag')
%   obj(1:4).Tag                   get(obj(1:4), 'Tag')
%   obj(1)
%
%   See also SERIAL/GET.
%

%   Copyright 1999-2014 The MathWorks, Inc.


% Initialize variables.
prop1 = '';
index1 = {};

% Parse the input.

% The first Struct can either be:
% obj(1);
% obj.SampleRate;
switch Struct(1).type
    case '.'
        prop1 = Struct(1).subs;
    case '()'
        index1 = Struct(1).subs;
    case '{}'
        throwAsCaller(MException(message('MATLAB:serial:subsref:invalidSubscriptExpression')));
    otherwise
        throwAsCaller(MException(message('MATLAB:serial:subsref:invalidSubscriptExpressionType',Struct(1).type)));
end

% Index1 will be entire object if not specified.
if isempty(index1)
    index1 = 1:length(obj);
end

% Convert index1 to a cell if necessary.
isColon = false;
if ~iscell(index1)
    index1 = {index1};
end

% If indexing with logicals, extract out the correct values.
if islogical(index1{1})
    % Determine which elements to extract from obj.
    indices = find(index1{1} == true);
    
    % If there are no true elements within the length of obj, return.
    if isempty(indices)
        result = [];
        return;
    end
    
    % Construct new array of doubles.
    index1 = {indices};
end

% Error if index is a non-number.
for i=1:length(index1)
    if ~isnumeric(index1{i}) && (~(ischar(index1{i}) && (strcmp(index1{i}, ':'))))
        if ischar(index1{i})
            index1{i} = double(index1{1}); %#ok<AGROW>
        else
            throwAsCaller(MException(message('MATLAB:serial:subsref:undefinedFunction',class(index1{i}))));
        end
    end
end

if any(cellfun('isempty', index1))
    for i = 1:length(index1)
        if ~isempty(index1{i}) && index1{i} > size(obj, i)
            throwAsCaller(MException(message('MATLAB:serial:subsref:exceedsdims')));
        end
    end
    result = [];
    return;
elseif length(index1{1}) ~= (numel(index1{1}))
    thowAsCaller(MException(message('MATLAB:serial:subsref:onlyRowOrColumnVector')));
elseif length(index1) == 1
    if strcmp(index1{:}, ':')
        isColon = true;
        index1 = {1:length(obj)};
    end
else
    for i=1:length(index1)
        if (strcmp(index1{i}, ':'))
            index1{i} = 1:size(obj,i); %#ok<AGROW>
        end
    end
end

% Return the specified value.
if ~isempty(prop1)
    % Ex. obj.BaudRate
    % Ex. obj(2).BaudRate
    
    % Extract the object.
    indexObj = localIndexOf(obj, index1, isColon);
    
    % Get the property value.
    try
        result = get(indexObj, prop1);
    catch aException
        
        % Try IGETFIELD but do not compound new error message
        try
            result = igetfield(obj,  prop1);
        catch %#ok<CTCH>
            result = localCheckForNamedProperty(indexObj, prop1, aException);
        end
    end
else
    % Ex. obj(2);
    
    % Extract the object.
    result= localIndexOf(obj, index1, isColon);
end

% Handle the next element of the subsref structure if it exists.
if length(Struct) > 1
    Struct(1) = [];
    try
        result = subsref(result, Struct);
    catch  aException
        rethrow(aException);
    end
end

% -----------------------------------------------------------------------
% Index into an instrument array.
function result = localIndexOf(obj, index1, isColon)

try
    % Get the field information of the entire object.
    jobj = igetfield(obj, 'jobject');
    constructor = igetfield(obj, 'constructor');
    
    if ischar(constructor)
        % Ex. obj(1) when obj only contains one element.
        constructor = {constructor};
    end
    
    % Create the first object and then append the remaining objects.
    try
        c = constructor(index1{:});
    catch %#ok<CTCH>
        constructor = constructor';
        c = constructor(index1{:});
    end
    if (length(c) == 1)
        % This is needed so that the correct classname is assigned
        % to the object.
        result = feval(c{1}, jobj(index1{:}));
    else
        % The class will be instrument since there are more than
        % one instrument objects.
        result = obj;
        result = isetfield(result, 'jobject', jobj(index1{:}));
        result = isetfield(result, 'constructor', constructor(index1{:}));
    end
    
    if isColon && size(result,1) == 1
        result = result';
    end
catch aException
    throwAsCaller(localFixError(aException));
end

% -----------------------------------------------------------------------
function result = localCheckForNamedProperty(obj, prop , exception)

% Initialize variables.
result  = []; %#ok<NASGU>

% If the object isn't a device object it doesn't have any groups.
if ~isa(obj, 'icdevice')
    throwAsCaller(localFixError(exception));
end

% Get a list of all the groups in the object.
jobj = igetfield(obj, 'jobject');
groupnames = jobj.getPropertyGroups;

% If there are no groups return.
if isempty(groupnames) || (groupnames.size == 0)
    throwAsCaller(localFixError(exception));
end

% Loop through each group and determine if there is a group
% object with a HwName property value that is equivalent to the
% property value specified.
for i=1:groupnames.size
    % Get the next group name.
    gname = groupnames.elementAt(i-1);
    
    % Get the group objects.
    g = get(obj, gname);
    
    % Get the HwNames for each object in the group.
    hwnames = get(g, {'HwName'});
    
    % Compare the HwNames to the specified property.
    % If one matches, extract the associated group object
    % and return.
    if any(strcmpi(hwnames, prop))
        result = g(strcmpi(hwnames, prop));
        return;
    end
end

% No group objects were found that have the same HwName property
% value.
throwAsCaller(localFixError(exception));

% -----------------------------------------------------------------------
% Remove any extra carriage returns.
function aException = localFixError (exception)

% Initialize variables.
id = exception.identifier;
errmsg = exception.message;

% Remove the trailing carriage returns.
while errmsg(end) == sprintf('\n')
    errmsg = errmsg(1:end-1);
end

aException = MException(id, errmsg);

% LocalWords:  Subscripted exceedsdims jobject
