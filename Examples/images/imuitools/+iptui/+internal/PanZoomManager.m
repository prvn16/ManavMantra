classdef PanZoomManager < handle
    
%   Copyright 2015-2017 The MathWorks, Inc.

    properties
        Section
        ZoomInButton
        ZoomOutButton
        PanButton
    end
    
    properties (Dependent)
        Enabled
    end
    
    properties (Access = private)
        hApp
    end
    
    methods
        
        function self = PanZoomManager(hTab,hApp)
            
            import iptui.internal.*;
            
            section = hTab.addSection(getMessageString('zoomAndPan'));
            
            % Zoom in button.
            self.ZoomInButton = matlab.ui.internal.toolstrip.ToggleButton(getMessageString('zoomInTooltip'),...
                matlab.ui.internal.toolstrip.Icon.ZOOM_IN_16);
            addlistener(self.ZoomInButton, 'ValueChanged', @(hobj,evt) self.zoomIn(hobj,evt) );
            self.ZoomInButton.Description = getMessageString('zoomInTooltip');
            self.ZoomInButton.Tag = 'btnZoomIn';
            
            % Zoom out button.
            self.ZoomOutButton = matlab.ui.internal.toolstrip.ToggleButton(getMessageString('zoomOutTooltip'),...
                matlab.ui.internal.toolstrip.Icon.ZOOM_OUT_16);
            addlistener(self.ZoomOutButton, 'ValueChanged', @(hobj,evt) self.zoomOut(hobj,evt) );
            self.ZoomOutButton.Description = getMessageString('zoomOutTooltip');
            self.ZoomOutButton.Tag = 'btnZoomOut';
            
            % Pan button.
            self.PanButton = matlab.ui.internal.toolstrip.ToggleButton(getMessageString('pan'),...
                matlab.ui.internal.toolstrip.Icon.PAN_16 );
            addlistener(self.PanButton, 'ValueChanged', @(hobj,evt) self.panImage(hobj,evt) );
            self.PanButton.Description = getMessageString('pan');
            self.PanButton.Tag = 'btnPan';
            
            % Add buttons to panel.
            c = section.addColumn();
            c.add(self.ZoomInButton);
            c.add(self.ZoomOutButton);
            c.add(self.PanButton);
            
            % Cache handle to app to which this manager is associated. We
            % need this to be able to query for the image handle for
            % zooming/panning.
            self.hApp = hApp;
            self.Section = section;
            self.Enabled = false;
        end
        
        function unselectAll(self)
            if self.ZoomInButton.Value
                self.ZoomInButton.Value  = false;
                notify(self.ZoomInButton,'ValueChanged');
            end
            if self.ZoomOutButton.Value
                self.ZoomOutButton.Value  = false;
                notify(self.ZoomOutButton,'ValueChanged');
            end
            if self.PanButton.Value
                self.PanButton.Value  = false;
                notify(self.PanButton,'ValueChanged');
            end
        end
        
    end
    
    % Set/Get accessors
    methods
        
        function TF = get.Enabled(self)
            
            TF = self.ZoomInButton.Enabled;
            
        end
        
        function set.Enabled(self,TF)
            
            self.ZoomInButton.Enabled  = TF;
            self.ZoomOutButton.Enabled = TF;
            self.PanButton.Enabled     = TF;
            
        end
    end
    
    % Callbacks
    methods (Access = private)
        
        function zoomIn(self,hToggle,~)
            
            hIm = self.hApp.getScrollPanelImage();
            if hToggle.Value
                self.ZoomOutButton.Value = false;
                self.PanButton.Value = false;
                warnstate = warning('off','images:imuitoolsgate:undocumentedFunction');
                zoomInFcn = imuitoolsgate('FunctionHandle', 'imzoomin');
                warning(warnstate);
                set(hIm,'ButtonDownFcn',zoomInFcn);
                glassPlus = setptr('glassplus');
                iptSetPointerBehavior(hIm,@(hFig,~) set(hFig,glassPlus{:}));
            else
                if ~(self.ZoomOutButton.Value || self.PanButton.Value)
                    set(hIm,'ButtonDownFcn','');
                    iptSetPointerBehavior(hIm,[]);
                end
            end
        end
        
        function zoomOut(self,hToggle,~)
            
            hIm = self.hApp.getScrollPanelImage();
            if hToggle.Value
                self.ZoomInButton.Value = false;
                self.PanButton.Value    = false;
                warnstate = warning('off','images:imuitoolsgate:undocumentedFunction');
                zoomOutFcn = imuitoolsgate('FunctionHandle', 'imzoomout');
                warning(warnstate);
                set(hIm,'ButtonDownFcn',zoomOutFcn);
                glassMinus = setptr('glassminus');
                iptSetPointerBehavior(hIm,@(hFig,~) set(hFig,glassMinus{:}));
            else
                if ~(self.ZoomInButton.Value || self.PanButton.Value)
                    set(hIm,'ButtonDownFcn','');
                    iptSetPointerBehavior(hIm,[]);
                end
            end
        end
        
        function panImage(self,hToggle,~)
            
            hIm = self.hApp.getScrollPanelImage();
            if hToggle.Value
                self.ZoomOutButton.Value = false;
                self.ZoomInButton.Value = false;
                warnstate = warning('off','images:imuitoolsgate:undocumentedFunction');
                panFcn = imuitoolsgate('FunctionHandle', 'impan');
                warning(warnstate);
                set(hIm,'ButtonDownFcn',panFcn);
                handCursor = setptr('hand');
                iptSetPointerBehavior(hIm,@(hFig,~) set(hFig,handCursor{:}));
            else
                if ~(self.ZoomInButton.Value || self.ZoomOutButton.Value)
                    set(hIm,'ButtonDownFcn','');
                    iptSetPointerBehavior(hIm,[]);
                    
                end
            end
            
        end
        
    end
end

function str = getMessageString(id)

str = getString( message( sprintf('images:commonUIString:%s',id) ) );

end