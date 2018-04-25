classdef VideoVisual < matlabshared.scopes.visual.Visual
    %VIDEOVISUAL Class definition for VideoVisual class
    
    %   Copyright 2015-2017 The MathWorks, Inc.
    
    properties(SetAccess=protected)
        ColorMap
        VideoInfo
        Image = -1
        ScrollPanel = -1
        MaxDimensions
        Axes = -1
    end
    
    properties(SetAccess=protected,Dependent,AbortSet)
        DataType
        IsIntensity
    end
    
    properties(Access=protected)
        ScalingChangedListener
        DataSourceChangedListener
        DataLoadedListener
        ToolsMenuListener
        Extension
        OldDimensions
        DimsStatus
        KeyPlayback
        VideoInfoMenu
        ColormapMenu
        %VideoInfoButton % Moved to PixelRegionTool
    end
    
    methods
        %Constructor
        function this = VideoVisual(varargin)
            
            this@matlabshared.scopes.visual.Visual(varargin{:});
            
            % Create the Video Information dialog.
            this.VideoInfo = matlabshared.scopes.visual.VideoInformation(this.Application);
            update(this.VideoInfo);
            
            this.ToolsMenuListener = event.listener(this.Application, ...
                'ToolsMenuOpening', @this.onToolsMenuOpening);
            this.DataLoadedListener = event.listener(this.Application, ...
                'DataReleased', @this.dataReleased);
            this.DataSourceChangedListener = event.listener(this.Application, ...
                'DataSourceChanged', @this.dataSourceChanged);
        end
    end
    
    methods
        function dataType = get.DataType(this)
            dataType = this.ColorMap.DataType;
        end
        
        function isIntensity = get.IsIntensity(this)
            isIntensity = this.ColorMap.IsIntensity;
        end
        
        function this = set.DataType(this,dataType)
            
            if ~isempty(this.ColorMap)
                this.ColorMap.DataType = dataType;
                displayType = this.ColorMap.DisplayDataType;
            else
                displayType = dataType;
            end
            
            if ~isempty(this.VideoInfo)
                this.VideoInfo.DataType        = dataType;
                this.VideoInfo.DisplayDataType = displayType;
            end
            
        end
        
        function this = set.IsIntensity(this,isIntensity)
            
            if ~isempty(this.ColorMap)
                this.ColorMap.IsIntensity = isIntensity;
            end
            
            if ~isempty(this.VideoInfo)
                if isIntensity
                    colorSpace = 'Intensity';
                else
                    colorSpace = 'RGB';
                end
                this.VideoInfo.ColorSpace = colorSpace;
            end
            
        end
    end
    
    methods (Access = protected)
        cleanup(this, hVisParent)
        hInstall = createGUI(this)
    end
    methods(Static)
        propSet = getPropertySet
    end
    
    methods (Static,Hidden)
        function b = isRGB(hSource)
            b = getNumInputs(hSource) == 3;
            if ~b
                maxDimensions = getMaxDimensions(hSource, 1);
                b = numel(maxDimensions) == 3 && maxDimensions(3) == 3;
            end
        end
    end
end
