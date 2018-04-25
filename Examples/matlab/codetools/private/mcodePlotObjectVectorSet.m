function mcodePlotObjectVectorSet(hCode,hConstructMomentoList,isDataSpecificFunction)
% Generates a call to "set(...)" for every object in the input momento
% list.

% Copyright 2006 The MathWorks, Inc.

% Loop through objects and properties and determine which properties will
% end up in the constructor and which will end up in individual calls to
% "set".

% Use a structure to keep track of properties. Each field-name
% represents a property. Each field is a cell-array containing a list
% of values and votes for each value.
propStruct = [];
% Keep a default value marker
defVal = 'MCodeDefaultValueMarker';
for n = 1:length(hConstructMomentoList)
    hPeerMomento = hConstructMomentoList(n);
    hPeerPropertyList = get(hPeerMomento,'PropertyObjects');
    hPeerObj = get(hPeerMomento,'ObjectRef');
    % Keep track of properties that are set:
    if ~isempty(propStruct)
        nameList = fieldnames(propStruct);
        visitedFlags = false(1,length(nameList));
    else
        nameList = {};
        visitedFlags = [];
    end
    % Loop through the properties, store the values of properties which are
    % different
    % Ignore data-specific properties and the parent since it has already
    % been established that the objects all share a parent.
    for m = 1:length(hPeerPropertyList)
        if ~get(hPeerPropertyList(m),'Ignore') && ~isDataSpecificFunction(hPeerObj, hPeerPropertyList(m))
            name = get(hPeerPropertyList(m),'Name');
            value = get(hPeerPropertyList(m),'Value');
            isParam = get(hPeerPropertyList(m),'IsParameter');
            nestedStoreProperty(name,value,isParam,n);
        end
    end
    % Deal with any default properties we may have:
    nestedStoreProperty(nameList(~visitedFlags),defVal,false,n);
end

% Loop through the structure and find non-default properties which are the
% same for at least half of the objects. This implies that the property is
% set from the constructor and not afterwards...
thresh = floor(length(hConstructMomentoList)/2);
constructorProps = [];
if ~isempty(propStruct)
    propNames = fieldnames(propStruct);
else
    propNames = {};
end
for i = 1:length(propNames)
    fName = propNames{i};
    propMax = max(propStruct.(fName){1});
    if propMax > thresh
        propIndex = find(propStruct.(fName){1} == propMax);
        propVal = propStruct.(fName){2}{propIndex};
        propParam = propStruct.(fName){3};
        if ~isequal(propStruct.(fName){2}{propIndex},defVal)
            % Store the value
            constructorProps.(fName) = propVal;
            localAddConstructorPropValue(hCode,fName,propParam,propVal);
        end
    end
end

% Loop through peer momento object list
for n = 1:length(hConstructMomentoList)
    hPeerMomento = hConstructMomentoList(n);
    hPeerObj = get(hPeerMomento,'ObjectRef');
    hPeerPropertyList = get(hPeerMomento,'PropertyObjects');
    hGenPropList = [];
    if ~isempty(constructorProps)
        propNames = fieldnames(constructorProps);
    else
        propNames = {};
    end
    visitedList = false(1,length(propNames));
    % Loop through properties, cache properties that are different
    for m = 1:length(hPeerPropertyList)
        % Get property info
        name = get(hPeerPropertyList(m),'Name');
        value = get(hPeerPropertyList(m),'Value');
        % If the property is different from the constructor, generate
        % it.
        if isfield(constructorProps,name)
            if ~isequal(constructorProps.(name),value)
                set(hPeerPropertyList(m),'Ignore',false);
            else
                set(hPeerPropertyList(m),'Ignore',true);
            end
            visitedList(strcmpi(propNames,name)) = true;
        end
        if ~get(hPeerPropertyList(m),'Ignore')
            isparameter = get(hPeerPropertyList(m),'IsParameter');
            if ~isparameter && ~isDataSpecificFunction(hPeerObj,hPeerPropertyList(m))
                % Save this property and value for code generation
                hGenPropList = [hGenPropList;hPeerPropertyList(m)];
            end
        end % if
    end % for
    % If any properties are left unvisited, deal with them now
    for i = find(~visitedList)
        % Store property info
        fName = propNames{i};
        if ~isequal(get(hPeerObj,fName),constructorProps.(fName))
            pobj = codegen.momentoproperty;
            set(pobj,'Name',fName);
            set(pobj,'Value',get(hPeerObj,fName));
            hGenPropList = [hGenPropList;pobj];
        end
    end
    % Generate code for properties
    local_generate_individual_set_args(hCode,hPeerObj,hGenPropList);
end % for

%----------------------------------------------------------%
    function nestedStoreProperty(propName, value, isParameter, index)

        % Insert the value into the list of non-default properties
        if ~iscell(propName)
            propName = {propName};
        end
        for i = 1:length(propName)
            currName = propName{i};
            if isfield(propStruct,currName)
                % If the value is already registered, search the table for an
                % occurrence of the value.
                found = false;
                % Indicate that we stored this property
                visitedFlags(strcmpi(nameList,currName)) = true;
                for i = 1:length(propStruct.(currName){1})
                    if isequal(propStruct.(currName){2}{i},value)
                        propStruct.(currName){1}(i) = propStruct.(currName){1}(i)+1;
                        found = true;
                        break;
                    end
                end
                if ~found
                    % Add a new value for the property
                    propStruct.(currName){1}(end+1) = 1;
                    propStruct.(currName){2}{end+1} = value;
                    propStruct.(currName){3} = isParameter;
                end
            else
                % Add a new entry into the table
                propStruct.(currName){1} = 1;
                propStruct.(currName){2}{1} = value;
                propStruct.(currName){3} = isParameter;
                % Other previous objects have default properties, which we need
                % to capture
                propStruct.(currName){1}(2) = index-1;
                propStruct.(currName){2}{2} = defVal;
            end
        end

    end % function

end

%----------------------------------------------------------%
function local_generate_individual_set_args(hCode,hObj,hGenPropList)
% Generate arguments to "set(...)"

if ~isempty(hGenPropList)

    % Generate call to "set(...)" for input
    hFunc = codegen.codefunction('Name','set','CodeRef',hCode);
    addPostConstructorFunction(hCode,hFunc);

    % Create first input argument: line handle
    hArg = codegen.codeargument('Value',hObj,'IsParameter',true);
    addArgin(hFunc,hArg);

    % Generate param-value syntax
    generatePropValueList(hFunc,hGenPropList);
end

end % function

%-----------------------------------------------------------%
function localAddConstructorPropValue(hCode,fName,propParam,propVal)
% Given a property name and value, add it as a prop/value pair to the
% constructor

% Create param argument
hFunc = hCode.Constructor;
hArg = codegen.codeargument('Value',fName,'ArgumentType',codegen.ArgumentType.PropertyName);
addArgin(hFunc,hArg);
% Create value argument
hArg = codegen.codeargument('ArgumentType',codegen.ArgumentType.PropertyValue);
set(hArg,'Name',fName);
set(hArg,'Value',propVal);
set(hArg,'IsParameter',propParam);
addArgin(hFunc,hArg);

end