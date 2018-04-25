function moveDisplayData(hObj, dim, itemBeingMoved, newIndex)
% Move an item in the display data to another location and update the
% limits if necessary.

% Copyright 2017 The MathWorks, Inc.

dataProp = [dim 'DisplayData'];
limitsProp = [dim 'Limits_I'];

% Determine the current index.
currentOrder = hObj.(dataProp);
[~, currentIndex] = ismember(itemBeingMoved, currentOrder);

% Determine the current limits.
currentLimits = hObj.(limitsProp);

% Threshold the new index.
numItems = numel(currentOrder);
newIndex = max(1,min(numItems, newIndex));

% Calculate the new data order.
[newOrder, reorder] = calculateNewOrder(numItems, currentIndex, newIndex);

if reorder
    % If item being moved started out as the first or last item in the limits,
    % or is becoming the first or last item in the limits, adjust the limits to
    % account for the item being moved and keep the same items with the range
    % of the new limits.
    newLimits = calculateNewLimits(currentIndex, newIndex, currentOrder, currentLimits);
    
    % Set the new limits. Use internal property to avoid validation error if
    % the limits are temporarily out of order, and to avoid toggling the mode.
    hObj.(limitsProp) = newLimits;
    
    % Update the display data.
    hObj.(dataProp) = currentOrder(newOrder);
end

end

function [newOrder, reorder] = calculateNewOrder(numItems, currentIndex, newIndex)

if currentIndex > 0 && currentIndex < newIndex
    % Item is moving to a position later in the list.
    newOrder = [1:currentIndex-1 currentIndex+1:newIndex currentIndex newIndex+1:numItems];
    reorder = true;
elseif currentIndex > newIndex
    % Item is moving to a position earlier in the list.
    newOrder = [1:newIndex-1 currentIndex newIndex:currentIndex-1 currentIndex+1:numItems];
    reorder = true;
else
    % Item has not moved.
    newOrder = 1:numItems;
    reorder = false;
end

end

function newLimits = calculateNewLimits(currentIndex, newIndex, currentOrder, currentLimits)

% Initialize the new limits to match the current limits.
newLimits = currentLimits;

% Find the current indices of the limits and item being moved.
[~,limits] = ismember(currentLimits, currentOrder);

% Make sure the item has actually moved, and there is more than
% one item showing.
if newIndex ~= currentIndex && limits(1) ~= limits(2)
    if currentIndex == limits(1)
        % Item being moved is currently the first item.
        % Update the limits to use the second item.
        newLimitIndex = min(limits(1)+1,numel(currentOrder));
        newLimits(1) = currentOrder(newLimitIndex);
    elseif currentIndex == limits(2)
        % Item being moved is currently the last item.
        % Update the limits to use the second to last item.
        newLimitIndex = max(limits(2)-1,1);
        newLimits(2) = currentOrder(newLimitIndex);
    end
    
    if newIndex == limits(1)
        % Item being moved is becoming the first item.
        % Update the limits to use the item as first item.
        newLimits(1) = currentOrder(currentIndex);
    elseif newIndex == limits(2)
        % Item being moved is becoming the last item.
        % Update the limits to use the item as last item.
        newLimits(2) = currentOrder(currentIndex);
    end
end

end
