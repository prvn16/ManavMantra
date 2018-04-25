function button = buildSplitButton(topLevelDetails, subItemDetails)
    
% Copyright 2015 The MathWorks, Inc.

button = toolpack.component.TSSplitButton(getString(message(topLevelDetails.DisplayName)), ...
    topLevelDetails.Icon);
button.Orientation = toolpack.component.ButtonOrientation.VERTICAL;
button.Name = topLevelDetails.ButtonTag;
button.Popup = toolpack.component.TSDropDownPopup(convertToOptions(subItemDetails), ...
    'icon_text');
button.Popup.Name = topLevelDetails.PopupTag;

iptui.internal.utilities.setToolTipText(button, ...
    getString(message(topLevelDetails.Tooltip)))

end


function options = convertToOptions(subItemDetails)

options = struct([]);

numOptions = size(subItemDetails,1);

for idx = 1:numOptions
    options(idx).Title = getString(message(subItemDetails{idx, 1}));
    options(idx).Description = '';
    options(idx).Icon = subItemDetails{idx, 2};
    options(idx).Help = [];
    options(idx).Header = false;
end

end
