classdef TwoMaskScrollPanel < handle
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties (Access = public)
        Visible
        AlphaMaskOpacity
    end
    
    properties (SetAccess=private,GetAccess=public)
        hIm
        hFig
        Axes
        
        PreviewMask
        CommittedMask
    end
    
    properties (Access=private)
        CachedOpacity
        CachedColormap
        CachedImage
        CachedImageForBinary
        
        IncludeList = [1 2];
        ColormapInternal = single([1 1 0; 0 1 1]);
        
        hLegend
        hScrollpanel
        
        isShowBinary
        isLegendVisible
    end
    
    methods
        % Constructor
        function self = TwoMaskScrollPanel(im)
            
            sz = size(im);
            self.PreviewMask = zeros(sz(1:2));
            self.CommittedMask = zeros(sz(1:2));
            im = im2single(im);
            self.CachedImage = im;
            
            self.hFig = figure(...
                'NumberTitle','off',...
                'Name','Segmentation',...
                'Colormap',gray(2),...
                'IntegerHandle','off',...
                'Visible','off');
            
            % Set the WindowKeyPressFcn to a non-empty function. This is
            % effectively a no-op that executes everytime a key is pressed
            % when the App is in focus. This is done to prevent focus from
            % shifting to the MATLAB command window when a key is typed.
            self.hFig.WindowKeyPressFcn = @(~,~)[];
            
            iptPointerManager(self.hFig);
            
            imPanel = uipanel(...
                'Parent', self.hFig,...
                'Position', [0 0 1 1],...
                'BorderType', 'none',...
                'tag', 'ImagePanel');
            
            layoutScrollpanel(self, imPanel, im);
            self.AlphaMaskOpacity = 1;
            
            % Prevent MATLAB graphics from being drawn in figures docked
            % within App.
            set(self.hFig, 'HandleVisibility', 'callback');
            
        end
        % Install in app
        function addToApp(self, hToolGroup)
            hToolGroup.addFigure(self.hFig);
            hToolGroup.getFiguresDropTargetHandler.unregisterInterest(self.hFig);
            
            % Disable figure closing
            drawnow; % This is important: getClient calls fail without this.
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            md.getClient('Segmentation', hToolGroup.Name).putClientProperty(...
                com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE,...
                java.lang.Boolean.FALSE);
        end
        
        % Mask control
        function updatePreviewMask(self,previewMask)
            
            assert(isequal(size(previewMask),size(self.PreviewMask)),'Size mismatch when updating scrollpanel preview mask.')
            
            self.PreviewMask = previewMask;
            
            self.redraw();
                        
        end
        
        function updateCommittedMask(self,committedMask)
            
            assert(isequal(size(committedMask),size(self.CommittedMask)),'Size mismatch when updating scrollpanel committed mask.')
            
            self.CommittedMask = committedMask;
            
            self.redraw();
                        
        end
        
        function resetPreviewMask(self)
            
            sz = size(self.PreviewMask); 
            sz = sz(1:2);
            
            updatePreviewMask(self,zeros(sz));
            
        end
        
        function resetCommittedMask(self)
            
            sz = size(self.PreviewMask); 
            sz = sz(1:2);
            
            updateCommittedMask(self,zeros(sz));
            
        end
        
        function redraw(self)
            L = double(self.CommittedMask);
            L(self.PreviewMask == 1) = 2;
            I = images.internal.labeloverlayalgo(im2single(self.CachedImage),L,self.ColormapInternal,self.AlphaMaskOpacity,self.IncludeList);
            self.hIm.CData = I;
        end
        
        % Show binary
        function showBinary(self)
            
            % Do not fire view changes if we are already in show binary 
            % mode.
            if self.isShowBinary
                return;
            end
            
            self.isShowBinary = true;
            
            self.CachedOpacity = self.AlphaMaskOpacity;
            self.AlphaMaskOpacity = 1;
            
            self.CachedImageForBinary = self.CachedImage;
            self.CachedImage = zeros(size(self.CachedImage),'like',self.CachedImage);
            self.CachedColormap = self.ColormapInternal;
            self.ColormapInternal = ones([2,3],'single');
            
            self.hLegend.Visible = 'off';
            
            self.redraw();
            
        end
        
        function unshowBinary(self)
            
            % Do not fire view changes if we are already in grayscale mode.
            if ~self.isShowBinary
                return;
            end
            
            self.isShowBinary = false;
            
            self.AlphaMaskOpacity = self.CachedOpacity;
            
            if ~isempty(self.CachedImageForBinary)
                self.CachedImage = self.CachedImageForBinary;
                self.CachedImageForBinary = [];

                self.ColormapInternal = self.CachedColormap;
            end
            
            if self.isLegendVisible && ~isempty(self.hLegend)
                self.hLegend.Visible = 'on';
            end
            
            self.redraw();
            
        end
        
        % Legend
        function addLegend(self)
            
            if isempty(self.hLegend)
                self.createLegend();
            else
                if self.isShowBinary
                    self.isLegendVisible = true;
                    return;
                end
                self.hLegend.Visible = 'on';
            end
            
            self.isLegendVisible = true;
        end
        
        function removeLegend(self)
            
            if ~isempty(self.hLegend)
                self.hLegend.Visible = 'off';
            end
            
            self.isLegendVisible = false;
        end
        
        % Magnification
        function updateImageMagnification(self)
            
            % We need to ensure that graphics objects related to the
            % scrollpanel are constructed before we set the
            % magnification of the tool.
            drawnow; drawnow;
            
            api = iptgetapi(self.hScrollpanel);
            fitmag = api.findFitMag();
            api.setMagnification(fitmag);
            
        end
        
        % Destructor
        function delete(self)
            if isvalid(self.hFig)                
		delete(self.hFig)
            end
        end
    end
    
    % Set/Get accessor methods
    methods
        function set.Visible(self,newValue)
            
            switch (lower(newValue))
                case 'off'
                    self.Visible = 'off';
                case 'on'
                    self.Visible = 'on';
                otherwise
                    assert(false, 'Acceptable values for Visible property are ''On'' and ''Off''.')
            end
            
            self.setVisibility(self.Visible);
            
        end
        
        function set.AlphaMaskOpacity(self,newValue)
            
            if ~isempty(newValue) && newValue>=0 && newValue<=1
                self.AlphaMaskOpacity = newValue;
            end
            self.redraw()
        end
        
        function hAx = get.Axes(self)
            hAx = findobj(self.hScrollpanel,'type','axes');
        end
        
    end
    
    methods (Access = private)
        function layoutScrollpanel(self, imPanel, im)
            hAx = axes('Parent', imPanel);
            set(hAx,'Visible','off')
            
            % Figure will be docked before imshow is invoked. We want
            % to avoid warning about fit mag in context of a docked
            % figure.
            warnState1 = warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');
            warnState2 = warning('off', 'images:initSize:adjustingMag');
            
            % We don't want to auto-scale uint8's, but want to
            % auto-scale uint16 and double.
            if isa(im, 'uint8')
                self.hIm = imshow(im, 'Parent', hAx);
            else
                self.hIm = imshow(im, 'Parent', hAx, 'DisplayRange', []);
            end
            warning(warnState1);
            warning(warnState2);
            
            self.hIm.Tag = 'InputImage';
            
            self.hScrollpanel = imscrollpanel(imPanel, self.hIm);
            self.hScrollpanel.Units = 'normalized';
            self.hScrollpanel.Position = [0 0 1 1];
            
            self.updateImageMagnification()
            
            hAx.XTick = [];
            hAx.YTick = [];
            
            self.isLegendVisible = false;
        end
        
        function createLegend(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            previewColor = self.ColormapInternal(2,:);
            committedColor = self.ColormapInternal(1,:);
            
            % Create invisible patch objects of preview and committed color
            hPreviewPatch   = patch(1,1,previewColor,'Parent',self.Axes,'Visible','off');
            hCommittedPatch = patch(1,1,committedColor,'Parent',self.Axes,'Visible','off');
            
            self.hLegend = legend([hPreviewPatch,hCommittedPatch],{getMessageString('preview'),getMessageString('applied')},...
                'HandleVisibility','off','PickableParts','none','HitTest','off');
            self.hLegend.Location = 'northwest';
            
            % Remove the context menu
            self.hLegend.UIContextMenu.delete();
        end
        
        function setVisibility(self, visibility)
            set(self.hFig, 'Visible', visibility)
        end
        
    end
    
end