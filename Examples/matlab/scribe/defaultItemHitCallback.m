function defaultItemHitCallback(hSrc,eventData)
% This is the default function that executes when you click an item in the
% legend. When you double-click a legend label, by default this function
% initiates interactive text editing.
% 
% To customize the response when you click a legend item, create a new
% function with the behavior you want. Then, set the ItemHitFcn property of
% the legend to the name of that new function. For example:
% 
%    lgd = legend; 
%    lgd.ItemHitFcn = @customfunction
%
% Editing this defaultItemHitCallback function is not recommended. If you
% want to change the behavior, create a new function instead. This default
% function is intended for internal use only and is subject to change at
% any time without warning.

    % initiate interactive text editing when double-clicking over a legend label.
    if strcmp(eventData.SelectionType, 'open') && strcmp(eventData.Region,'label')
        startLabelEditing(hSrc,eventData.Peer);
    end

end