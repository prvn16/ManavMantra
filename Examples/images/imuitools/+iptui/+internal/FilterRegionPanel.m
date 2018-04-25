%FilterRegionPanel  Object to manage region filtering panel for Region
%Analyzer app

classdef FilterRegionPanel < handle
    properties
        popup
        filterPanel
    end
    
    methods
        function self = FilterRegionPanel
            panel = toolpack.component.TSPanel(...
                '5px,p:g,5px',...
                '5px, f:p:g, f:p:g, f:p:g, f:p:g, f:p:g, 5px');
            
            % Parent the panel to a tearoff popup.
            self.popup = toolpack.component.TSTearOffPopup(panel);
            
            self.filterPanel{1} = constructFilterPanel();
            self.filterPanel{2} = constructFilterPanel();
            panel.add(self.filterPanel{1}, 'xy(2,2)')
            panel.add(constructSpacerPanel(), 'xy(2,3)')
            panel.add(self.filterPanel{2}, 'xy(2,4)')
        end
    end
end

%--------------------------------------------------------------------------
function hTSPanel = constructFilterPanel()

hTSPanel = toolpack.component.TSPanel(...
    '7dlu, f:p, 7dlu, f:p, 7dlu, f:p, 7dlu, f:p, 3dlu, f:p', ... % columns
    'f:p, f:p, 9dlu, f:p'); % rows

% xy(2,2) = combobox
% xy(2,4) = combobox
% xy(4,4) = spinner
% xy(6,4) = "and"
% xy(8,4) = spinner
% xywh(10,1,1,4) = button

hPropCombo = toolpack.component.TSComboBox({'Area', 'Perimeter', 'Eccentricity'});
hTSPanel.add(hPropCombo, 'xy(2,2)')

hOpCombo = toolpack.component.TSComboBox({'==', '~=','>', '>=',  '<=', '<', 'Between'});
hTSPanel.add(hOpCombo, 'xy(2,4)')

hValueOneSpinner = toolpack.component.TSSpinner(0, 65535, 0, 1);
hTSPanel.add(hValueOneSpinner, 'xy(4,4)')

hTSPanel.add(toolpack.component.TSLabel('and'), 'xy(6,4)')

hValueTwoSpinner = toolpack.component.TSSpinner(0, 65535, 0, 1);
hTSPanel.add(hValueTwoSpinner, 'xy(8,4)')

hRemoveButton = toolpack.component.TSButton('Remove', toolpack.component.Icon.CLOSE);
hTSPanel.add(hRemoveButton, 'xywh(10,1,1,4)')
end

%--------------------------------------------------------------------------
function hTSPanel = constructSpacerPanel()

hTSPanel = toolpack.component.TSPanel(...
    '3dlu, f:p', ... % columns
    '7dlu, f:p, 7dlu'); % rows

hLabel = toolpack.component.TSLabel('And');
hTSPanel.add(hLabel, 'xy(2,2)')

end