function Obj = subsasgn(Obj, Struct, Value)
%SUBSASGN Subscripted assignment into serial port objects.
%
%   SUBSASGN Subscripted assignment into serial port objects.
%
%   OBJ(I) = B assigns the values of B into the elements of OBJ specified by
%   the subscript vector I. B must have the same number of elements as I
%   or be a scalar.
%
%   OBJ(I).PROPERTY = B assigns the value B to the property, PROPERTY, of
%   serial port object OBJ.
%
%   Supported syntax for serial port objects:
%
%   Dot Notation:                  Equivalent Set Notation:
%   =============                  ========================
%   obj.Tag='sydney';              set(obj, 'Tag', 'sydney');
%   obj(1).Tag='sydney';           set(obj(1), 'Tag', 'sydney');
%   obj(1:4).Tag='sydney';         set(obj(1:4), 'Tag', 'sydney');
%   obj(1)=obj(2);
%   obj(2)=[];
%
%   See also SERIAL/SET.
%

%   Copyright 1999-2014 The MathWorks, Inc.

if isempty(Obj)
    % Ex. s(1) = serial('COM1');
    if isequal(Struct.type, '()') && isequal(Struct.subs{1}, 1:length(Value))
        Obj = Value;
        return;
    elseif length(Value) ~= length(Struct.subs{1})
        % Ex. s(1:2) = serial('COM1');
        error(message('MATLAB:serial:subsasgn:index_assign_element_count_mismatch'));
    elseif Struct.subs{1}(1) <= 0
        error(message('MATLAB:serial:subsasgn:badsubscriptindices'))
    else
        % Ex. s(2) = serial('COM1'); where s is originally empty.
        error(message('MATLAB:serial:subsasgn:badsubscriptGap'));
    end
end

% Initialize variables.
oldObj = Obj;
prop1  = '';
index1 = {};

% Types of indexing allowed.
% g(1)
% g(1).UserData
% g(1).UserData(1,:)
% g.UserData
% g.UserData(1,:)
% d(1).Input
% d(1).Input(1).Name
% d(1).Input(1).Name(1:3)
% d.Input(1).Name
% d.Input(1).Name(1:3)

% Initialize variables for finding the object and property.
remainingStruct = [];
foundProperty   = false;
needToContinue  = true;
exception       = [];
i               = 0;

% Want to loop until there is an object and a property. There may be
% more structure elements - for indexing into the property, e.g.
% g(1).UserData(1,:) = [1 2 3];
while (needToContinue == true)
    % If there was an error and need to continue checking the
    % subsasgn structure, throw the error message.
    if ~isempty(exception)
        throw(exception);
    end
    
    % Increment the counter.
    i = i+1;
    
    switch Struct(i).type
        case '.'
            % e.g. d.Input;
            prop1 = Struct(i).subs;
            
            try
                tempObj = get(Obj, prop1);
            catch aException
                
                try
                    tempObj = igetfield(Obj,  prop1);
                catch %#ok<CTCH>
                        throw(localFixError(aException));
                end
            end
            
            if isa(tempObj, 'icgroup') && isempty(Struct(i+1:end))
                tempObj = subsasgn(tempObj, Struct(i+1:end), Value); %#ok<NASGU>
                Obj = oldObj;
                return;
            else
                foundProperty   = true;
                remainingStruct = Struct(i+1:end);
            end
        case '()'
            index1 = Struct(i).subs;
            index1 = localConvertIndices(Obj, index1);
            [Obj, exception]  = localIndexOf(Obj, index1);
            % Don't throw error here, in case the expression is
            % x = [obj obj]; x(3) = obj; If the expression is not
            % valid, e.g. x(4).UserData, the error will be thrown
            % the next time through the while loop.
        case '{}'
            error(message('MATLAB:serial:subsasgn:invalidSubscriptExpression'));
    end
    
    % Determine if the loop needs to continue.
    if i == length(Struct)
        needToContinue = false;
    elseif (foundProperty == true)
        needToContinue = false;
    end
end

% Set the specified value.
if ~isempty(prop1)
    % Ex. obj.BaudRate = 9600
    % Ex. obj(2).BaudRate = 9600
    
    % Set the property.
    try
        if isempty(remainingStruct)
            set(Obj, prop1, Value);
        else
            tempObj   = get(Obj, prop1);
            tempValue = subsasgn(tempObj, remainingStruct, Value);
            set(Obj, prop1, tempValue);
        end
        
        % Reset the object so that it's value isn't corrupted.
        Obj = oldObj;
    catch aException
        try
            Obj = isetfield(Obj, prop1, Value);
        catch %#ok<CTCH>
            throw(localFixError(aException));
        end
    end
else
    % Reset the object.
    Obj = oldObj;
    
    % Ex. obj(2) = obj(1);
    if ~(isa(Value, 'instrument') || isempty(Value))
        error(message('MATLAB:serial:subsasgn:invalidConcat'));
    end
    
    % Ex. s(1) = [] and s is 1-by-1.
    if ((length(Obj) == 1) && isempty(Value))
        error(message('MATLAB:serial:subsasgn:invalidAssignment'));
    end
    
    % Error if index is a non-number.
    for i=1:length(index1)
        if ~isnumeric(index1{i}) && (~(ischar(index1{i}) && (strcmp(index1{i}, ':'))))
            error(message('MATLAB:serial:subsasgn:badsubscriptindex', class( index1{ i } )));
        end
    end
    
    % Error if a gap will be placed in array or if the value being assigned has an
    % incorrect size.
    for i = 1:length(index1)
        % If index is specified as ':', then the length of the value
        % must be either one or the length of size.
        if strcmp(index1{i}, ':')
            if i < 3
                if length(Value) == 1 || isempty(Value)
                    % If the length is one or is empty, do nothing.
                elseif ~(length(Value) == size(Obj, 1) || length(Value) == size(Obj, 2))
                    % If the length is greater than one, it must equal the
                    % length of the dimension.
                    error(message('MATLAB:serial:subsasgn:index_assign_element_count_mismatch'));
                end
            end
        elseif ~isempty(index1{i}) && max(index1{i}) > size(Obj, i)
            % Determine if any of the indices specified exceeds the length
            % of the object array.
            currentIndex = index1{i};
            temp  = currentIndex(currentIndex>length(Obj));
            
            % Don't allow gaps into array.
            if ~isempty(temp)
                % Ex. x = [g g g];
                %     x([3 5]) = [g1 g1];
                temp2 = min(temp):max(temp);
                if ~isequal(temp, temp2)
                    error(message('MATLAB:serial:subsasgn:badsubscriptGap'));
                end
            end
            
            % Verify that the index doesn't add a gap.
            if min(temp) > length(Obj)+1
                % Ex. x = [g g g];
                %     x([5 6]) = [g1 g1];
                error(message('MATLAB:serial:subsasgn:badsubscriptGap'));
            end
            
            % If the length of the object being assigned is not one, it must
            % match the length of the index array.
            if ~isempty(Value) && length(Value) > 1
                if length(currentIndex) ~= length(Value)
                    error(message('MATLAB:serial:subsasgn:index_assign_element_count_mismatch'));
                end
            end
        end
    end
    
    % Assign the value.
    try
        Obj = localReplaceElement(Obj, index1, Value);
    catch aException
        throw(localFixError(aException));
    end
end

% -----------------------------------------------------------------------
function index = localConvertIndices(obj, index)

% Index1 will be entire object if not specified.
if isempty(index)
    index = 1:length(obj);
end

% Convert index1 to a cell if necessary.
if ~iscell(index)
    index = {index};
end

% If indexing with logicals, extract out the correct values.
if islogical(index{1})
    % Determine which elements to extract from obj.
    indices = find(index{1} == true);
    
    % If there are no true elements within the length of obj, return.
    if isempty(indices)
        index = {};
        return;
    end
    
    % Construct new array of doubles.
    index = {indices};
end

% -----------------------------------------------------------------------
% Replace the specified element.
function obj = localReplaceElement(obj, index, Value)

try
    % If the index is empty then there are no replacements. 
    if (isempty(index))
       return; 
    end
    
    % Get the current state of the object.
    jobject     = igetfield(obj, 'jobject');
    constructor = igetfield(obj, 'constructor');
    
    if ~iscell(constructor)
        constructor = {constructor};
    end
    
    % Replace the specified index with Value.
    if isempty(Value)
        jobject(index{:})      = [];
        constructor(index{:})  = [];
    elseif length(Value) == 1
        jobject(index{:})     = igetfield(Value, 'jobject');
        constructor(index{:}) = {igetfield(Value, 'constructor')};
    else
        % Ex. y(:) = x(2:-1:1); where y and x are 1-by-2 instrument arrays.
        jobject(index{:})     = igetfield(Value, 'jobject');
        constructor(index{:}) = igetfield(Value, 'constructor');
    end

    if length(constructor) == 1 && iscell(constructor)
        constructor = constructor{:};
    end
    
    if length(constructor) ~= numel(constructor)
        throwAsCaller(MException(message('MATLAB:serial:subsasgn:nonMatrixConcat')));
    end
    
    % Assign the new state back to the original object.
    obj = isetfield(obj, 'jobject', jobject);
    obj = isetfield(obj, 'constructor', constructor);
    
catch aException
    throw(aException);
end

% -----------------------------------------------------------------------
% Index into an instrument array.
function  [result, exception]  = localIndexOf(obj, index1)

exception = [];
try
    % Default result, when the index1 is empty
    result = obj;
    
    % Create result with the indexed elements.
    if (~isempty(index1))
        % Get the field information of the entire object.
        jobj        = igetfield(obj, 'jobject');
        constructor = igetfield(obj, 'constructor');
        
        result = isetfield(result, 'jobject', jobj(index1{:}));
        result = isetfield(result, 'constructor', constructor(index1{:}));
    end
catch %#ok<CTCH>
    exception = MException(message('MATLAB:serial:subsasgn:badsubscriptDim'));
end

% -----------------------------------------------------------------------
% Remove any extra carriage returns.
function aException = localFixError(exception)

% Initialize variables.
id = exception.identifier;
errmsg = exception.message;

% Remove the trailing carriage returns.
while errmsg(end) == sprintf('\n')
    errmsg = errmsg(1:end-1);
end

aException = MException(id, errmsg);



