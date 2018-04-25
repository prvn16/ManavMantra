classdef ColorSpaceMontageView < handle

    %   Copyright 2013-2016 The MathWorks, Inc.

    properties (Access = private)
             
        % Handles to figure and panels
        hFig             
        hPanels
        hGam
        
        % Listener to manage behavior of rotate3d for 3D views
        hgamutRotatedListener
        
        % Background color of 3D plots
        rgbColor
        
        % Default projections for each color space
        pcaProjHolder
                
    end
    
    properties (SetObservable)
       
        % String specifying color space that was chosen by user
        SelectedColorSpace
        
        % Transformation matrix for current 3D view
        tMat
        
        % Camera Position for current view
        camPosition
        camVector
        
    end
    
    methods
        
        
        function self = ColorSpaceMontageView(hToolGroup,RGB,rgbColor,rotatePointer)

            % Add multiple colorspace view panel to figure parented to
            % toolgroup.
            self.hFig  = figure('Name',getString(message('images:colorSegmentor:chooseColorspace')),...
                'NumberTitle','off',...
                'IntegerHandle','off',...
                'Tag','clusterFigure', ...
                'DeleteFcn',@(varargin) delete(self),...
                'Toolbar','none',...
                'Menubar','none');

            % Set the WindowKeyPressFcn to a non-empty function. This is
            % effectively a no-op that executes everytime a key is pressed
            % when the App is in focus. This is done to prevent focus from
            % shifting to the MATLAB command window when a key is typed.
            self.hFig.WindowKeyPressFcn = @(~,~)[];
            
            hToolGroup.addFigure(self.hFig);
            self.rgbColor = rgbColor;
            iptPointerManager(self.hFig);
         
            % The only purpose of this panel is to work around a rendering bug with
            % uipanel layout in MATLAB Graphics 1 in which the seams of the
            % individual color space panels are showing when they should
            % not.
            hPanel = uipanel('Parent',self.hFig,'Position',[0 0 1 0.95],'HitTest','off','BorderType','none');
            
            hRGB    = self.layoutMontageView(hPanel,[0 0.5 0.25 0.5],'R','G','B','RGB');
            hHSV    = self.layoutMontageView(hPanel,[0.25 0.5 0.25 0.5],'H','S','V','HSV');
            hYCbCr  = self.layoutMontageView(hPanel,[0.5 0.5 0.25 0.5],'Y','Cb','Cr','YCbCr');
            hLAB    = self.layoutMontageView(hPanel,[0.75 0.5 0.25 0.5],'L*','a*','b*','L*a*b*');

            impanel = uipanel('Parent',hPanel,'Units','Normalized','Position',[0 0 1 0.5],...
                'BorderType','none','tag','imPreview','hittest','off');
            
            hImax = axes('Parent',impanel,'hittest','off','Position',[0 0 1 1],'tag','previewAxes');
            
            % Obtain thumbnail sized representation of RGB input image so
            % that we can avoid needing to compute full scale color
            % transformation.  
            imPreview = iptui.internal.resizeImageToFitWithinAxes(hImax,RGB);
            
            doubleDataOutsideZeroOneRange = isfloat(imPreview) && (any(imPreview(:) < 0) || any(imPreview(:) > 1));
            
            if doubleDataOutsideZeroOneRange
                imPreview = mat2gray(imPreview);
            end
            
            S = warning('off','images:imshow:magnificationMustBeFitForDockedFigure');
            imshow(imPreview,'Parent',hImax);            
            warning(S);
            
            self.hPanels = [hRGB, hHSV, hYCbCr, hLAB, impanel];

            [hgamRGB, tMatRGB] = displayColorSpaceInPanel(hRGB, imPreview, 'RGB', self.rgbColor, rotatePointer);
            [hgamHSV, tMatHSV] = displayColorSpaceInPanel(hHSV, imPreview, 'HSV', self.rgbColor, rotatePointer);
            [hgamYCbCr, tMatYCbCr] = displayColorSpaceInPanel(hYCbCr, imPreview, 'YCbCr', self.rgbColor, rotatePointer);
            [hgamLAB, tMatLAB] = displayColorSpaceInPanel(hLAB, imPreview, 'L*a*b*', self.rgbColor, rotatePointer);
            
            self.hGam = [hgamRGB hgamHSV hgamYCbCr hgamLAB];
            self.pcaProjHolder = {tMatRGB, tMatHSV, tMatYCbCr, tMatLAB};
            
            % No colorspace is selected in the initial state.
            self.SelectedColorSpace = '';
            
            addlistener(self.hFig,'WindowMousePress',@(hObj,evt) self.reactToMousePress(hObj,evt));
                                             
            set(self.hFig,'HandleVisibility','callback');
            
            self.showStatusMessage(hToolGroup);   
                         
        end

      
        function reactToMousePress(self,~,evt)
            % reactToMousePress - turns on 3D rotation when user clicks on
            % a 3D plot
            
            currentObject = evt.HitObject;
            
            if strcmp(get(currentObject.Parent,'tag'),'gamut')          
                if isempty(self.hgamutRotatedListener)
                    rotate3d(currentObject,'on');
                    % Add listener to determine when the user has finished
                    % rotating to turn off rotate3d
                    self.hgamutRotatedListener = addlistener(self.hFig,'WindowMouseRelease',@(hObj,evt) self.reactToMouseRelease(hObj,evt,currentObject));
                end
            end
              
        end
        
        
        function reactToMouseRelease(self,~,~,currentObject)
            % reactToMouseRelease - turns off 3D rotation when user
            % releases the mouse
            
            % Turn off rotate3d and delete listener. This will return the
            % figure's WindowKeyPressFcn to empty
            rotate3d(currentObject,'off');
            delete(self.hgamutRotatedListener);
            self.hgamutRotatedListener = [];
            
        end
        
        
        function hpanel = layoutMontageView(self,hParent,position,~,~,~,colorSpaceString)
            % layoutMontageView - layout panels for each color space 
            
            hpanel = uipanel('Parent',hParent,...
                'Units','Normalized',...
                'Position',position,...
                'BorderType','none',...
                'hittest','off',...
                'tag',colorSpaceString);

            uipanel('Parent',hpanel,...
                'Units','Normalized',...
                'Position',[0 0 1 0.8],...
                'BorderType','none',...
                'tag','imagepanel',...
                'hittest','off');

            hTitlePanel = uipanel('Parent',hpanel,...
                'Units','Normalized',...
                'Position',[0 0.8 1 0.2],...
                'BorderType','none',...
                'tag','titlepanel',...
                'hittest','off');

            hFlowContainer = uiflowcontainer('v0',...
                'parent',hTitlePanel,...
                'Units','normalized',...
                'Position',[0.3, 0.1, 0.4, 0.8],...
                'hittest','off');

            % Add text description of color space
            uicontrol('style', 'pushbutton',...
                'String',colorSpaceString,...
                'Parent',hFlowContainer,...
                'FontUnits','normalized',...
                'FontSize',0.5,...
                'Callback',@(src,evt) self.selectFromButtons(src,evt));

        end


        function selectFromButtons(self,src,~)
            % selectFromButtons - Callback for when a color space is
            % selected
            
            % Updating the contents of SelectedColorSpace will trigger an
            % event in ColorSegmentationTool to create a new document
            if isempty(self.SelectedColorSpace)
                self.customProjection(src.String)
                self.SelectedColorSpace = src.String;
                close(self.hFig); 
            end
            
        end
        
        
        function customProjection(self,csname)
            % customProjection - Determines the transformation matrix for
            % the current view of the selected color space
            
            % Find selected color space
            switch csname
                case 'RGB'
                    hAx = findobj(self.hGam(1).Children,'type','axes');
                case 'HSV'
                    hAx = findobj(self.hGam(2).Children,'type','axes');
                case 'YCbCr'
                    hAx = findobj(self.hGam(3).Children,'type','axes');
                case 'L*a*b*'
                    hAx = findobj(self.hGam(4).Children,'type','axes');
            end
            
            % Obtain the transformation matrix for the current projection
            T = view(hAx);
            
            % Define matrix to normalize transformation matrix based on
            % axes limits
            xl=get(hAx,'xlim');
            yl=get(hAx,'ylim');
            zl=get(hAx,'zlim');
            
            N=[1/(xl(2)-xl(1)) 0 0 0; ...
              0 1/(yl(2)-yl(1)) 0 0; ...
              0 0 1/(zl(2)-zl(1)) 0; ...
              0 0 0 1];
          
            % Normalize transformation matrix
            self.tMat = T*N;
            
            % Get relative camera position vector to apply to 3D view
            self.camPosition = hAx.CameraPosition - hAx.CameraTarget;
            self.camVector = hAx.CameraUpVector;
             
        end
        
        
        function updateScatterBackground(self,rgbColor)
            % updateScatterBackground - Set the background color of the 3D
            % plots
            
            self.rgbColor = rgbColor;
            hScat = findall(self.hPanels,'type','scatter');
            arrayfun( @(h) set(h.Parent, 'Color',rgbColor), hScat);
            
        end

        
        function showStatusMessage(~,hToolGroup)
            % Show busy message in status bar
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            f = md.getFrameContainingGroup(hToolGroup.Name);
            javaMethodEDT('setStatusText', f, getString(message('images:colorSegmentor:colorSpaceHintMessage'))); 
        end
        
        
        function delete(self)
            % Cleanup associated figure when delete is called
            delete(self.hFig);
        end
        
        
        function bringToFocusInSpecifiedPosition(self)
            % Bring document tab to front 
            figure(self.hFig);            
        end
        
        
        function setVisible(self)
            set(self.hFig,'Visible','on');
        end
        
        
        function setInvisible(self)
            set(self.hFig,'Visible','off');
        end
        
    end
    
    % Methods provided for testing
    methods
        
        function hButton = getButtonHandle(self,csname)
            %getButtonHandle - This method returns the handle to the
            %uicontrol that selects the color space in the montage view.
            %Possible values for csname are 'RGB', 'HSV', 'YCbCr', and
            %'L*a*b*'
            
            hButton = findobj(self.hPanels,'Style','pushbutton','-and','String',csname);
            
        end
        
        
    end
    
    
end

function [hgam, tMatPCA] = displayColorSpaceInPanel(hpanel, RGB, csname, rgbColor, rotatePointer)

% Add axes containing each PCA projection. 0,0 is at bottom left of
% parent panel.

hgam = findobj(hpanel,'tag','imagepanel');

colorcloud(RGB,csname(1),'Parent',hgam,'WireFrameColor','none','OrientationAxesColor','none');

% Customize colorcloud axes
hAx = findobj(hgam,'Type','Axes');
reset(hAx)
hScat = findobj(hgam,'Type','Scatter');

% Obtain PCA projection to use as default view
if strcmp(csname,'L*a*b*') || strcmp(csname,'YCbCr')
    im = [hScat.ZData' hScat.XData' hScat.YData'];
    im = bsxfun(@minus, im, mean(im,1));
    set(hScat,'XData',im(:,2),'YData',im(:,3),'ZData',im(:,1));
else
    im = [hScat.XData' hScat.YData' hScat.ZData'];
    im = bsxfun(@minus, im, mean(im,1));
    set(hScat,'XData',im(:,1),'YData',im(:,2),'ZData',im(:,3));
end

if size(im,1) < 3
    im = padarray(im,[1 0],'symmetric','both');
end

[~,~,coeff] = svd(im,'econ');
tMatPCA = coeff(1:3,1:3);

% Set axes settings for scatter plots
hAx.XLim = iptui.internal.setAxesLimits(hScat.XData);
hAx.YLim = iptui.internal.setAxesLimits(hScat.YData);
hAx.ZLim = iptui.internal.setAxesLimits(hScat.ZData);
set(hAx,'box','on',...
    'Color',rgbColor,...
    'XColor',[0.5 0.5 0.5],...
    'YColor',[0.5 0.5 0.5],...
    'ZColor',[0.5 0.5 0.5],...
	'XTick',[],...
    'YTick',[],...
    'ZTick',[],...
    'Units','normalized',...
	'Position',[0.05 0.05 0.9 0.9]);

grid(hAx,'off')
set(hgam,'Tag','gamut');

% Set viewpoint
view(hAx,tMatPCA(:,3));

% Turn off hittest for all children of gamut panels for
% callback that toggles rotate3d on and off
handleList = allchild(hgam.Children);
arrayfun( @(h) set(h, 'HitTest','off'), handleList);

iptSetPointerBehavior(hAx,@(hObj,evt) set(hObj,'Pointer','custom','PointerShapeCData',rotatePointer));

end