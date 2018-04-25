classdef ProgressDialogController < handle
    %Progress Dialog controller for dialogs in WebGUIs
    
    properties
        PeerNode;
        ChannelID;
        PMM;
    end
    
    events
        CancelRequested;
    end
    
    methods
        function this = ProgressDialogController(channelID,f,model)
            
            this.ChannelID = ['/gbt/figure/DialogService/' channelID];
            pmm = matlab.ui.internal.dialog.DialogHelper.getPeerModelDialogService(this.ChannelID,f);
            
            % Temporarily disable sync to setup new node with props
            % This prevents the possibility of the client side peer node
            % from being created with partial sets of properties
            % initialized.
            pmm.setSyncEnabled(false);
            this.PeerNode = pmm.getRoot().addChild('matlab.ui.dialog.ProgressDialog');
            % Set props
            props = properties(model);
            props = props(~ismember(props,'CancelRequested'));
            cellfun(@(prop) this.updateProperty(prop, model.(prop)),props);
            % Since CancelRequested is dependent on the Controller/PeerNode
            % We need to manually add it here.
            this.updateProperty('CancelRequested',false);
            % Localized string to show when the cancel button is pressed
            this.updateProperty('CancelRequestedText', getString(message('MATLAB:uitools:uidialogs:CancelRequested')));
            
            this.PMM = pmm;
            
        end
        
        function show(this)
            this.PMM.setSyncEnabled(true);
            this.PMM = [];
        end        
        
        function updateProperty(this, prop, val, varargin)
            if strcmpi(prop, 'Icon')
                % Serialize icons
                type = 'preset';
                if ~isempty(varargin)
                    type = varargin{1};
                end
                val = matlab.ui.internal.dialog.IconUtils.getIconForView(val,type);
            end
            try
                javaValue = appdesservices.internal.peermodel.convertMatlabValueToJavaValue(val);
            catch
                javaValue = val;
            end
            this.PeerNode.setProperty(prop,javaValue);
        end
        
        function delete(this)
            this.PeerNode.destroy();
        end
        
        function out = getCancelRequested(this)
            out = this.PeerNode.getProperty('CancelRequested');
        end
    end
    
end

