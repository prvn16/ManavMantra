classdef ApplyCloseManager < handle
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties
        Section
        
        ApplyButton
        CloseButton
    end
    
    methods
        function self = ApplyCloseManager(hTab,varargin)
            
            import iptui.internal.utilities.setToolTipText;
            
            if nargin > 2 && varargin{2}
                applyLabel = getMessageString('createMask');
                applyTooltip = getMessageString('createMaskTooltip');
            else
                applyLabel = getMessageString('apply');
                applyTooltip = getMessageString('applyTooltip');
            end
            
            if nargin > 2 && varargin{2}
                closeLabel = getMessageString('cancel');
                closeTooltip = getMessageString('cancelTooltip');
            elseif nargin > 1
                tabName = varargin{1};
                closeLabel = getMessageString('closeTab',tabName);
                closeTooltip = getMessageString('closeTabTooltip',tabName);
            else
                closeLabel = getMessageString('close');
                closeTooltip = getMessageString('closeTooltip');
            end
            section = hTab.addSection(getMessageString('close'));
            section.Tag = 'ApplyClose';
            
            self.ApplyButton = matlab.ui.internal.toolstrip.Button(applyLabel,matlab.ui.internal.toolstrip.Icon.CONFIRM_24);
            self.ApplyButton.Tag = 'btnApply';
            self.ApplyButton.Description = applyTooltip;
            
            self.CloseButton = matlab.ui.internal.toolstrip.Button(closeLabel,matlab.ui.internal.toolstrip.Icon.CLOSE_24);
            self.CloseButton.Tag = 'btnClose';
            self.CloseButton.Description = closeTooltip;

            % Layout
            c = section.addColumn();
            c.add(self.ApplyButton);
            c2 = section.addColumn();
            c2.add(self.CloseButton);
            
            self.Section = section;
            
        end
    end
end

function string = getMessageString(identifier, varargin)
    
% Copyright 2015 The MathWorks, Inc.

if (nargin == 1)
    string = getString(message(sprintf('images:commonUIString:%s', identifier)));
elseif (nargin > 1)
    string = getString(message(sprintf('images:commonUIString:%s', identifier), varargin{:}));
end

end