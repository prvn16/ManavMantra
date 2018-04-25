classdef TextureManager < handle

%   Copyright 2016-2017 The MathWorks, Inc.
    
    properties
        Section
        TextureButton
    end
    
    properties (Dependent)
        Enabled
        Selected
    end
    
    properties (Access = private)
        hApp
        hToolstrip
        isButtonClicked = true;
    end
    
    events
        TextureButtonClicked
    end
    
    methods
        
        function self = TextureManager(hTab,hApp,hToolstrip)
            self.hApp = hApp;
            self.hToolstrip = hToolstrip;
            self.layoutTextureSection(hTab);
        end
        
        function updateTextureState(self,TF)
            self.isButtonClicked = false;
            self.Selected = TF;
        end
        
    end
    
    methods
    % set/get methods
    function set.Enabled(self,TF)
        self.TextureButton.Enabled = TF;
    end
    
    function TF = get.Enabled(self)
        TF = self.TextureButton.Enabled;
    end
    
    function set.Selected(self,TF)
        self.TextureButton.Value = TF;
    end
    
    function TF = get.Selected(self)
        TF = self.TextureButton.Value;
    end
    
    end
    
    methods (Access = private)
        
        function textureCallback(self)
            if self.isButtonClicked
                self.toggleTexture();
            end
            self.isButtonClicked = true;
        end
        
        function toggleTexture(self)
            
            import iptui.internal.segmenter.AppMode;

            if self.Selected
                self.hApp.ToolGroup.setWaiting(true);
                TF = self.hApp.Session.createTextureFeatures();
                self.hApp.ToolGroup.setWaiting(false);
                self.hApp.Session.UseTexture = TF;
                self.Selected = TF;
            end
            
            self.hApp.Session.UseTexture = self.Selected;
            notify(self,'TextureButtonClicked');
            self.hToolstrip.setMode(AppMode.ToggleTexture);
            
        end
        
        function layoutTextureSection(self,hTab)
            
            import images.internal.app.Icon;
            import iptui.internal.segmenter.getMessageString;
            
            section = hTab.addSection(getMessageString('texture'));
            section.Tag = 'texture';

            %Texture Button
            self.TextureButton = matlab.ui.internal.toolstrip.ToggleButton(getMessageString('textureTitle'), Icon.TEXTURE_24);
            self.TextureButton.Tag = 'btnTexture';
            self.TextureButton.Description = getMessageString('textureTooltip');            
            addlistener(self.TextureButton, 'ValueChanged', @(~,~) self.textureCallback());
            
            %Layout
            c = section.addColumn();
            c.add(self.TextureButton);
            self.Section = section;
            
        end
        
    end
    
end

