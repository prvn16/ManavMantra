function toText(hFunc,hVariableTable)
% Determines text representation

% Copyright 2006 The MathWorks, Inc.

% Only input arguments marked as parameters will be
% represented as variables
hArginList = get(hFunc,'Argin');
for n = 1:length(hArginList)
    hArgin = hArginList(n);
    % Convert data type into text representation
    err = hArgin.toText(hVariableTable);
    % Prevent the variable from being removed
    setRemovalPermissions(hArgin.ActiveVariable,false);

    % If an error occurred converting the argument into text
    % then ignore this property. If the argument is part of
    % parameter-value syntax, then be sure to ignore its
    % corresponding parameter name.
    if (err)
        set(hArgin,'Ignore','true');
        type = get(hArgin,'ArgumentType');
        if strcmpi(type,'PropertyValue')
            if (((n-1)>0) && ...
                    strcmpi(get(hArginList(n-1),'ArgumentType'),'PropertyName'))
                set(hArginList(n-1),'Ignore','true');
            end
        end
    end

    % Suppply default comment with format
    % 'myfunction mypropertyname', for example 'surface xdata'
    if ~err && get(hArgin,'IsParameter') && isempty(get(hArgin,'Comment'))
        hSubFunc = get(hFunc,'SubFunction');
        if isempty(hSubFunc)
            func_name = get(hFunc,'Name');
        else
            func_name = get(hSubFunc,'String');
        end
        var_name = get(hArgin,'Name');
        if ~isempty(func_name) && ~isempty(var_name)
            set(hArgin,'Comment',[func_name, ' ', var_name]);
        end
    end
end

% All output arguments must be represented as variables
hArgoutList = get(hFunc,'Argout');
n_argout = length(hArgoutList);
% Check to see if the output arguments can be removed:
numCanBeRemoved = 0;
for i = 1:n_argout
    if canRemove(hArgoutList(i),hFunc)
        numCanBeRemoved = numCanBeRemoved + 1;
    end
end
% If all the outputs can be removed, don't generate the output
if numCanBeRemoved == n_argout
    hFunc.Argout = [];
    n_argout = 0;
end

for n = 1:n_argout
    % Flag output variables
    set(hArgoutList(n),'IsOutputArgument',true);
    hArgoutList(n).toText(hVariableTable);
    % Allow the variable to be removed
    setRemovalPermissions(hArgoutList(n).ActiveVariable,true,hFunc);
end
