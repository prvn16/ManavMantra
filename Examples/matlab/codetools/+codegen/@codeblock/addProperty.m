function addProperty(hThis,propnames)
% Tells code object add property

% Copyright 2004-2012 The MathWorks, Inc.

% Only cell array of strings valid input
if ischar(propnames)
    propnames = {propnames};
end

% Only cell array of strings valid input
if ~iscellstr(propnames)
  error(message('MATLAB:codetools:codegen:InvalidInputRequiresCellArrayOfStrings'));
end

% Get handles
hMomento = get(hThis,'MomentoRef');
hObj = get(hMomento,'ObjectRef');
if ~ishandle(hObj)
    error(message('MATLAB:codetools:codegen:InvalidState'));
end
hObj = handle(hObj);

% Get list of properties
hPropList = get(hMomento,'PropertyObjects');
for i = 1:length(propnames)
    propname = propnames{i};
    % Get property object
    hProp = findprop(hObj,propname);
    if isempty(hProp)
        error(message('MATLAB:codetools:codegen:InvalidProperty',propname));
        return;
    end

    % If the property already exists, do not repeat it, but set its "Ignore"
    % flag to false
    if isempty(hPropList)
        hProp = [];
        hPropList = handle([]);
    else
        hProp = findobj(hPropList,'Name',propname);
    end
    if ~isempty(hProp)
        set(hProp,'Ignore',false);
    else
        % Store property info
        pobj = codegen.momentoproperty;
        set(pobj,'Name',propname);
        set(pobj,'Value',get(hObj,propname));
        set(pobj,'Object',hProp);

        % Update list
        hPropList = [hPropList pobj]; %#ok<AGROW>
    end
end
set(hMomento,'PropertyObjects',hPropList);