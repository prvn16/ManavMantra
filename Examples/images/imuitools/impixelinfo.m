function hpanel = impixelinfo(varargin)
%IMPIXELINFO Pixel Information tool.
%   IMPIXELINFO creates a pixel information tool in the current figure.  The
%   pixel information tool displays information about the pixel in an image that
%   the cursor is positioned over. The tool can display pixel information for
%   all the images in a figure.
%  
%   The pixel information tool is a uipanel object, positioned in the lower-left
%   corner of the figure, that contains the text string "Pixel Info" followed by
%   the pixel information. The information displayed depends on the image type,
%   as shown below. If the cursor is outside of the image area in the figure,
%   the pixel information tool displays the default string.
%  
%   Image Type     Default String         Example
%   ----------     --------------         -----------------
%   Intensity      (X,Y) Intensity        (13,30) 82
%   Indexed        (X,Y) <index> [R G B]  (2,6) <4> [0.29 0.05 0.32]
%   Binary         (X,Y) BW               (12,1) 0
%   Truecolor      (X,Y) [R G B]          (19,10) [15 255 10]
%  
%   If you want to display pixel information without the "Pixel Info" label, use
%   IMPIXELINFOVAL.
%  
%   IMPIXELINFO(H) creates a pixel information tool in the figure specified by
%   the handle H, where H is an image, axes, uipanel, or figure object. Axes,
%   uipanel, or figure objects must contain at least one image object.
%  
%   IMPIXELINFO(HPARENT,HIMAGE) creates a pixel information tool in HPARENT that
%   provides information about the pixels in HIMAGE.  HIMAGE is a handle to an
%   image or an array of image handles.  HPARENT is a handle to the figure or
%   uipanel object that contains the pixel information tool.
%  
%   HPANEL = IMPIXELINFO(...) returns a handle to the pixel information tool
%   uipanel.
%  
%   Note
%   ----
%   To copy the pixel information string to the clipboard, right-click
%   while the cursor is positioned over a pixel. In the context menu,
%   choose Copy pixel info.
%   
%   For a floating point image with the 'CDataMapping' property set to
%   'direct', the pixel information tool displays this default string: 
%   (X,Y) value <index> [R G B]
%  
%   Examples
%   --------
%
%       h = imshow('hestain.png');
%       hp = impixelinfo;
%       set(hp,'Position',[5 1 300 20]);
%  
%       figure
%       subplot(1,2,1), imshow('liftingbody.png');
%       subplot(1,2,2), imshow('autumn.tif');
%       impixelinfo
%  
%   See also IMPIXELINFOVAL, IMTOOL.

%   Copyright 1993-2015 The MathWorks, Inc.

[h,parent] = parseInputs(varargin{:});

if strcmp(get(parent,'Type'),'figure')
    parentIsFigure = true;
else
    parentIsFigure = false;
end

imageHandles = imhandles(h);

if isempty(imageHandles)
    error(message('images:impixelinfo:noImageInFigure'))
end

hPixInfoPanel = createPanel;

reactToImageChangesInFig(imageHandles,hPixInfoPanel,@reactDeleteFcn,[]);
registerModularToolWithManager(hPixInfoPanel,imageHandles);

if isequal(parent,ancestor(imageHandles,'figure')) && ...
        strcmp(get(parent,'Visible'),'on')
    figure(parent);
end

if nargout > 0
    hpanel = hPixInfoPanel;
end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function reactDeleteFcn(obj,evt) %#ok<INUSD>
        if ishghandle(hPixInfoPanel)
            delete(hPixInfoPanel);
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function hPixInfoPanel = createPanel

        units = 'pixels';
        posPanel = [1 1 300 20];
        visibility = 'off';

        if parentIsFigure
            backgrndColor = get(parent,'Color');
        else
            backgrndColor = get(parent,'BackgroundColor');
        end

        fudge = 2;

        hPixInfoPanel = uipanel('Parent',parent,...
            'Units',units,... 
            'Tag','pixelinfo panel',...
            'Visible',visibility,...
            'Bordertype','none',...
            'BackgroundColor', backgrndColor);
        matlab.ui.internal.PositionUtils.setDevicePixelPosition(hPixInfoPanel, posPanel);

        set(hPixInfoPanel,'Visible','on');  % must be in this function.

        hPixelInfoLabel = uicontrol('Parent',hPixInfoPanel,...
            'Style','text',...
            'String',getString(message('images:impixelinfoUIString:pixelInfoLabel')), ...
            'Tag','pixelinfo label',...
            'Units',units,...
            'Visible',visibility,...
            'BackgroundColor',backgrndColor);
                
        labelExtent = matlab.ui.internal.PositionUtils.getDevicePixelExtent(hPixelInfoLabel);
        posLabel = [posPanel(1) posPanel(2) labelExtent(3) labelExtent(4)];
        matlab.ui.internal.PositionUtils.setDevicePixelPosition(hPixelInfoLabel,posLabel);

        % initialize uicontrol that will contain the pixel info values.
        hPixelInfoValue = impixelinfoval(hPixInfoPanel,imageHandles);
        posPixInfoValue = matlab.ui.internal.PositionUtils.getDevicePixelPosition(hPixelInfoValue);
        matlab.ui.internal.PositionUtils.setDevicePixelPosition(hPixelInfoValue,...
            [posLabel(1)+posLabel(3) posPanel(2) posPixInfoValue(3) posPixInfoValue(4)]);
        posPixInfoValue = matlab.ui.internal.PositionUtils.getDevicePixelPosition(hPixelInfoValue);

        % link visibility of hPixInfoPanel and its children 
        hlink = linkprop([hPixInfoPanel hPixelInfoLabel hPixelInfoValue],...
            'Visible');
        setappdata(hPixInfoPanel,'linkToChildren',hlink);

        newPanelWidth = posPixInfoValue(1)+posPixInfoValue(3)+fudge;
        newPanelHeight = max([posLabel(4) posPixInfoValue(4)]) + 2*fudge;
        matlab.ui.internal.PositionUtils.setDevicePixelPosition(hPixInfoPanel,...
            [posPanel(1) posPanel(2) newPanelWidth newPanelHeight]);



    end

end  %main function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [h,parent] = parseInputs(varargin)

narginchk(0,2);

switch nargin
    case 0
        %IMPIXELINFO
        h = get(0, 'CurrentFigure');
        if isempty(h)
            error(message('images:impixelinfo:noImageInFigure'))
        end
        parent = h;

    case 1
        h = varargin{1};
        if ~ishghandle(h)
            error(message('images:impixelinfo:invalidGraphicsHandle', 'H'))
        end
        parent = ancestor(h,'Figure');

    case 2
        parent = varargin{1};
        if ishghandle(parent)
            type = get(parent,'type');
            if ~strcmp(type,'uipanel') && ~strcmp(type,'uicontainer') && ...
                    ~strcmp(type,'figure')
                error(message('images:impixelinfo:invalidParent'))
            end
        else
            error(message('images:impixelinfo:invalidGraphicsHandle', 'HPARENT'))
        end

        h = varargin{2};
        checkImageHandleArray(h,mfilename);
end

end
