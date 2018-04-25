classdef ImagePreview < handle
% ImagePreview Class for the main image preview display in the Image Capture Tab
%
% This class takes care of figure creation and destruction, figure and
% handle visibility, and zoom controls.
    
% Copyright 2014 The MathWorks, Inc.

    properties
        Fig = [];
        ImHandle = [];
        ScrollPanelHandle = [];
        HAxes
        ImageAxesTag = 'PreviewImageAxes';        
        Title;
        Width;
        Height;
    end

    methods
        function this = ImagePreview
            this.Title = getString(message('images:colorSegmentor:MainPreviewFigure'));
            this.Fig = figure('WindowStyle', get(0,'FactoryFigureWindowStyle'), ... % Must appear first.
                'Resize', 'off', 'Visible','off', ...
                'NumberTitle', 'off', 'Name', this.Title, 'HandleVisibility',...
                'callback', 'IntegerHandle','off');
        end
           
        %------------------------------------------------------------------
        function drawImage(this, width, height)
            makeHandleVisible(this);
            this.HAxes = createImageAxes(this);
            
            % Create the image.
            if isempty(this.ImHandle)
                this.ImHandle = imshow(zeros(height, width, 3), 'Parent', this.HAxes, 'InitialMagnification', 'fit');
                this.ScrollPanelHandle = imscrollpanel(this.Fig, this.ImHandle);            
            end
            set(this.HAxes, 'Tag', this.ImageAxesTag);            
            makeHandleInvisible(this);
        end  
        
        %------------------------------------------------------------------
        function setTitle(this, titleString)
            hAxes = getImageAxes(this);
            title(hAxes, titleString, 'Interpreter', 'none');
        end
        
        %------------------------------------------------------------------
        function wipeFigure(this)
            if ishandle(this.Fig)
                set(this.Fig,'HandleVisibility','on');
                clf(this.Fig);
            end           
        end
        
        %------------------------------------------------------------------
        function makeFigureVisible(this)
            if isvalid(this.Fig)
                set(this.Fig, 'Visible', 'on');
            end
        end
        
        %------------------------------------------------------------------
        function makeFigureInvisible(this)
            if isvalid(this.Fig)
                set(this.Fig, 'Visible', 'off');
            end
        end        
        
        %------------------------------------------------------------------
        function makeHandleVisible(this)
            set(this.Fig,'HandleVisibility','on');
        end
        
        %------------------------------------------------------------------
        function makeHandleInvisible(this)
            set(this.Fig,'HandleVisibility','off');
        end
        
        %------------------------------------------------------------------
        function close(this)
            if ishandle(this.Fig)
                this.makeHandleVisible();
                delete(this.Fig);
            end
        end
        
        %------------------------------------------------------------------
        function tf = isAxesValid(this)
            tf = ~isempty(getImageAxes(this));
        end
        
        %------------------------------------------------------------------
        function hAxes = getImageAxes(this)            
            % hAxes = findobj(this.Fig, 'Type','axes','Tag', this.ImageAxesTag);
            hAxes = this.HAxes;
        end
        
        %------------------------------------------------------------------
        function hAxes = createImageAxes(this)
            hAxes = getImageAxes(this);
            if isempty(hAxes) % add an axes if needed                
                hAxes = axes('Parent', this.Fig, 'Tag', this.ImageAxesTag);
            end
        end
        
        function replaceImage(this, width, height)
            % Resolution may have changed, replace with new image.
            api = iptgetapi(this.ScrollPanelHandle);
            data = zeros(height, width, 3);
            api.replaceImage(data);
        end
        
        function clearAxes(this)
            if ~isempty(this.HAxes)
                cla(this.HAxes);
                this.HAxes = [];
            end
        end
    end
end