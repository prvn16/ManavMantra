function movePropertyBefore(hThis,propname,otherpropnames)
% Move the specified property so that it occurs before the specified other
% properties in the property list. This method does not change whether the
% property is ignored or not.

% Copyright 2017 The MathWorks, Inc.

% Property name should be a character vector.
if ~ischar(propname)
    error(message('MATLAB:codetools:codegen:InvalidInputStringRequired'));
end

% Make sure otherpropnames is a cellstr
if ischar(otherpropnames)
    otherpropnames = {otherpropnames};
elseif ~iscellstr(otherpropnames)
    error(message('MATLAB:codetools:codegen:InvalidInputRequiresCellArrayOfStrings'));
end

% Get handles
hMomento = get(hThis,'MomentoRef');

% Get the property list and list of property names.
hPropList = get(hMomento,'PropertyObjects');
if isempty(hPropList)
    % There are no properties in the list, so there is nothing to do.
    return
end
hPropNames = {hPropList.Name};

% Find all the requested properties in the property list.
[tf, ind] = ismember([{propname}; otherpropnames(:)], hPropNames);
hasProp = tf(1);
hasOtherProp = tf(2:end);

% If the property is not in the list, or none of the other properties are
% in the list, then no action is necessary.
if hasProp && any(hasOtherProp)
    % Get the indices of the properties.
    propInd = ind(1);
    otherInd = ind(2:end);
    
    % Find the first occurance of the other property names.
    firstOtherInd = min(otherInd(hasOtherProp));
    if propInd > firstOtherInd
        % Reorder the properties so that the requested property comes
        % immediately before the first occurance of the other properties.
        n = numel(hPropNames);
        newOrder = [1:firstOtherInd-1 propInd firstOtherInd:propInd-1 propInd+1:n];
        hPropList = hPropList(newOrder);
        
        % Store the updated property list.
        set(hMomento,'PropertyObjects',hPropList);
    end
end
