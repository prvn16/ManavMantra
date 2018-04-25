classdef ColorSpaceProjectionView < handle

    %   Copyright 2016 The MathWorks, Inc.

    properties (Access = private)
       
        % X, Y, Z coordinates of pixels in color space
        pointCloud
        
        % RGB values for each pixel in point cloud
        RGB 
        
        % Factor by which point cloud has been downsampled, if image is
        % greater than 2e6 pixels
        sampleFactor   
        
        hRotate3DListener
        hgamutRotatedListener
        
    end
    
    properties      
      
        % Panels containing 3D point cloud
        hPanels
        
    end
    
    methods
        

        function self = ColorSpaceProjectionView(hPanel,hFig,RGB,csname,camPosition,camVector,rgbColor,isHidden)
            
            % Add panel for 3D scatter plot where the LeftScrollPanel was
            hProjPanel = uipanel('Parent',hPanel,'Position',[0 0 1 0.6],'BorderType','none','tag','proj3dpanel','BackgroundColor',rgbColor);
            if isHidden
                set(hProjPanel,'Visible','off');
            end
            hAxgam = axes('Parent',hProjPanel,'hittest','off','Position',[0.01 0.01 0.98 0.98]);

            % Convert RGB data into specified colorspace
            colorData = computeColorspaceRepresentation(RGB,csname);
            colorData = double(colorData);
            
            % Resize data into 1D array
            [m,n,~] = size(RGB);
            colorData = reshape(colorData,[m*n 3]);
            RGB = reshape(RGB,[m*n 3]);
         
            % Downsample to 2e6 points if image is large to keep number of points in
            % scatter plot manageable
            targetNumPoints = 2e6;
            numPixels = m*n;
            
            if numPixels > targetNumPoints
                self.sampleFactor = round(numPixels/targetNumPoints);
                colorData = colorData(1:self.sampleFactor:end,:);
                RGB = RGB(1:self.sampleFactor:end,:);
            end

            % Create 3D scatterplot
            self.createScatter(hAxgam,colorData,RGB,csname,rgbColor,camPosition,camVector);
            
            % Declare object properties
            self.hPanels = hProjPanel;
            self.RGB = RGB;
            
            % Create listener to rotate 
            self.hRotate3DListener = addlistener(hFig,'WindowMousePress',@(hObj,evt) self.reactToMousePress(hObj,evt,hFig));
            
        end
        
        
        function [tMat, xlim, ylim] = customProjection(self)
            % customProjection - Determine transformation matrix for
            % current 3D view
            
            % Obtain the transformation matrix for the current projection
            hAx = findobj(self.hPanels,'Tag','scatteraxes');
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
            tMat = T*N;  
 
            % Apply transformation matrix to plot box corners
            plotBox = [xl(1) yl(1) zl(1) 1; ...
                xl(2) yl(1) zl(1) 1; ...
                xl(1) yl(2) zl(1) 1; ...
                xl(1) yl(1) zl(2) 1; ...
                xl(2) yl(1) zl(2) 1; ...
                xl(2) yl(2) zl(1) 1; ...
                xl(1) yl(2) zl(2) 1; ...
                xl(2) yl(2) zl(2) 1];
            
            plotBox = (tMat*plotBox')';
            
            % Get boundary limits for plot
            xlim = [min(plotBox(:,1)) max(plotBox(:,1))];
            ylim = [min(plotBox(:,2)) max(plotBox(:,2))];
            
        end
        
        
        function applyDefaultProjection(~,hAx,camPosition,camVector)
            % applyDefaultProjection - set the current view to be the
            % default view from PCA projection
            
            % Apply third column of PCA transformation matrix to specify
            % the vector orthogonal to the PCA projection plane
            newView = camPosition + get(hAx,'CameraTarget');
            set(hAx,'CameraPosition',newView); 
            set(hAx,'CameraUpVector',camVector);

        end
        
        
        function view3DPanel(self)
            
            if strcmp(get(self.hPanels,'Visible'),'off')
                set(self.hPanels,'Visible','on')
            else
                set(self.hPanels,'Visible','off')
            end
            
        end
        
        
        function updatePointCloud(self,BW)
            % updatePointCloud - apply changes from histogram sliders and
            % polygons to the 3D point cloud
            
            % Get point cloud x, y, z, and RGB color data
            xData = self.pointCloud(:,1);
            yData = self.pointCloud(:,2);
            zData = self.pointCloud(:,3);
            
            BW = BW(:);
            
            % If 3D point cloud has been downsampled, downsample the
            % sliderMask
            if ~isempty(self.sampleFactor)
                BW = BW(1:self.sampleFactor:end,:);
            end
            
            % Change the color of the points outside the impoly region
            cData1 = self.RGB(:,1);
            cData2 = self.RGB(:,2);
            cData3 = self.RGB(:,3);
            
            % Apply the sliderMask to filter out points
            xData = xData(BW);
            yData = yData(BW);
            zData = zData(BW);
            cData = [cData1(BW) cData2(BW) cData3(BW)];
            
            % Apply masked point cloud
            hScat = findobj(self.hPanels(1),'Type','Scatter');
            set(hScat,'XData',xData,'YData',yData,'ZData',zData,'CData',cData);
                  
        end
        
        
        function createScatter(self,hAx,colorData,RGB,csname,rgbColor,camPosition,camVector)
            % createScatter - normalize point cloud by subtracting the mean
            % for each channel and plot 3D point cloud
            
            switch (csname)
                case 'RGB'
                    camTarget = mean(colorData,1);
                    colorData = bsxfun(@minus, colorData, camTarget);
                    self.pointCloud = colorData;
                case 'HSV'
                    % Convert to cartesian coordinates from conical coordinates for
                    % plotting with scatter3
                    Xcoord = colorData(:,2).*colorData(:,3).*cos(2*pi*colorData(:,1));
                    Ycoord = colorData(:,2).*colorData(:,3).*sin(2*pi*colorData(:,1));
                    colorData(:,1) = Xcoord;
                    colorData(:,2) = Ycoord;
                    camTarget = mean(colorData,1);
                    colorData = bsxfun(@minus, colorData, camTarget);
                    self.pointCloud = colorData;
                case 'YCbCr'
                    camTarget = mean(colorData,1);
                    colorData = bsxfun(@minus, colorData, camTarget);
                    self.pointCloud = [colorData(:,2),colorData(:,3),colorData(:,1)];
                case 'L*a*b*'
                    camTarget = mean(colorData,1);
                    colorData = bsxfun(@minus, colorData, camTarget);
                    self.pointCloud = [colorData(:,2),colorData(:,3),colorData(:,1)];
                otherwise
                    assert('Unknown colorspace name specified.');
            end
            
            % Create 3D scatter plot
            scatter3(hAx,self.pointCloud(:,1),self.pointCloud(:,2),self.pointCloud(:,3),6,im2double(RGB),'.');
            
            % Set Axes properties
            set(hAx,'XTick',[],'YTick',[],'ZTick',[]);
            set(hAx,'box','on','Color',rgbColor)
            set(hAx,'XColor',[0.5 0.5 0.5],'YColor',[0.5 0.5 0.5],'ZColor',[0.5 0.5 0.5])
            grid(hAx,'off')
            set(hAx,'Tag','scatteraxes');
            
            % Set Axes limits
            hAx.XLim = iptui.internal.setAxesLimits(self.pointCloud(:,1));
            hAx.YLim = iptui.internal.setAxesLimits(self.pointCloud(:,2));
            hAx.ZLim = iptui.internal.setAxesLimits(self.pointCloud(:,3));
            
            % Set camera position
            self.applyDefaultProjection(hAx,camPosition,camVector)
            
            % Turn off hit test for scatter plot
            set(findall(hAx.Children),'hittest','off');
            
        end
        
                
        
        function reactToMousePress(self,~,evt,hFig)
            % reactToMousePress - Turns on rotation when the 3D view panel
            % is clicked
            
            currentObject = evt.HitObject;
            
            if strcmp(get(currentObject,'Tag'),'scatteraxes')          
                if isempty(self.hgamutRotatedListener)
                    rotate3d(currentObject,'on');
                    % Add listener to determine when the user has finished
                    % rotating to turn off rotate3d
                    self.hgamutRotatedListener = addlistener(hFig,'WindowMouseRelease',@(hObj,evt) self.reactToMouseRelease(hObj,evt,currentObject));
                end
            end    
               
        end
        
        
        function reactToMouseRelease(self,~,~,currentObject)
            % reactToMouseRelease - Turns off rotation when the mouse is
            % released after triggering reactToMousePress
            
            % Turn off rotate3d and delete listener. This will return the
            % figure's WindowKeyPressFcn to empty
            delete(self.hgamutRotatedListener);
            rotate3d(currentObject,'off');
            self.hgamutRotatedListener = [];
            
        end
        
        
    end
    
    
end

function cdata = computeColorspaceRepresentation(RGB,csname)

% Convert data into specified colorspace representation
switch (csname)

    case 'RGB'
        cdata = RGB;
    case 'HSV'
        cdata = rgb2hsv(RGB);
    case 'YCbCr'
        cdata = rgb2ycbcr(RGB);
    case 'L*a*b*'
        cdata = rgb2lab(RGB);

    otherwise
        assert('Unknown colorspace name specified.');
end

end

