function hScrollpanel = imscrollpanel(varargin)
%IMSCROLLPANEL Scroll panel for interactive image navigation.
%   HPANEL = IMSCROLLPANEL(HPARENT, HIMAGE) creates a scroll panel
%   containing the target image (the image to be navigated). HIMAGE
%   is a handle to the target HIMAGE.  HPARENT is the handle to the
%   figure or uipanel object that will contain the new scroll panel.
%   HPANEL is the handle to the scroll panel, which is a uipanel object.
%
%   A scroll panel makes an image scrollable. If the size or magnification
%   makes an image too large to display in a figure on the screen, the
%   scroll panel displays a portion of the image at 100% magnification
%   (one screen pixel represents one image pixel). The scroll panel adds
%   horizontal and vertical scroll bars to enable navigation around the
%   image
%
%   IMSCROLLPANEL changes the object hierarchy of the target image. Instead
%   of the familiar figure->axes->image object hierarchy, IMSCROLLPANEL
%   inserts several uipanel and uicontrol objects between the figure and
%   the axes object.
%
%   API Function Syntaxes
%   ---------------------
%   A scroll panel contains a structure of function handles,
%   called an API. You can use the functions in this API to manipulate
%   the scroll panel. To retrieve this structure, use the IPTGETAPI
%   function, as in the following.
%
%       api = iptgetapi(HPANEL)
%
%   Functions in the API, listed in the order they appear in the structure,
%   include:
%
%   setMagnification
%
%       Sets the magnification of the target image in units of
%       screen pixels per image pixel.
%
%           api.setMagnification(new_mag)
%
%       where new_mag is a scalar magnification factor.
%
%   getMagnification
%
%      Returns the current magnification factor of the target image
%      in units of screen pixels per image pixel.
%
%           mag = api.getMagnification()
%
%      Multiply mag by 100 to convert to percentage. For example,
%      if mag=2, the magnification is 200%.
%
%   setMagnificationAndCenter
%
%       Changes the magnification and makes the point cx,cy in the
%       target image appear in the center of the scroll panel. This
%       operation is equivalent to a simultaneous zoom and recenter.
%
%           api.setMagnificationAndCenter(mag,cx,cy)
%
%   findFitMag
%
%       Returns the magnification factor that would make the target
%       image just fit in the scroll panel.
%
%           mag = api.findFitMag()
%
%   setVisibleLocation
%
%       Moves the target image so that the specified location is
%       visible. Scrollbars update.
%
%           api.setVisibleLocation(xmin,ymin)
%           api.setVisibleLocation([xmin ymin])
%
%   getVisibleLocation
%
%       Returns the location of the currently visible portion of the
%       target image.
%
%           loc = api.getVisibleLocation()
%
%       where loc is a vector [xmin ymin].
%
%   getVisibleImageRect
%
%       Returns the current visible portion of the image.
%
%           r = api.getVisibleImageRect()
%
%       where r is a rectangle [xmin ymin width height].
%
%   addNewMagnificationCallback
%
%       Adds the function handle FCN to the list of new-magnification callback
%       functions.
%
%           id = api.addNewMagnificationCallback(fcn)
%
%       Whenever the scroll panel magnification changes, each function in
%       the list is called with the syntax:
%
%           fcn(mag)
%
%       where mag is a scalar magnification factor.
%
%       The return value, id, is used only with
%       removeNewMagnificationCallback.
%
%   removeNewMagnificationCallback
%
%       Removes the corresponding function from the new-magnification callback
%       list.
%
%           api.removeNewMagnificationCallback(id)
%
%       where id is the identifier returned by
%       api.addNewMagnificationCallback.
%
%   addNewLocationCallback
%
%       Adds the function handle FCN to the list of new-location callback
%       functions.
%
%           id = api.addNewLocationCallback(fcn)
%
%       Whenever the scroll panel location changes, each function in
%       the list is called with the syntax:
%
%           fcn(loc)
%
%       where loc is [xmin ymin].
%
%       The return value, id, is used only with
%       removeNewLocationCallback.
%
%   removeNewLocationCallback
%
%       Removes the corresponding function from the new-location callback
%       list.
%
%           api.removeNewLocationCallback(id)
%
%       where id is the identifier returned by
%       api.addNewLocationCallback.
%
%   replaceImage
%
%       Replaces the existing image data in the scrollpanel.       
%
%           api.replaceImage(I)
%           api.replaceImage(BW)
%           api.replaceImage(RGB)
%           api.replaceImage(I, MAP)
%           api.replaceImage(FILENAME)
%
%       By default, the new image data is displayed centered, at 100%
%       magnification.  The image handle is unchanged. 
%
%           api.replaceImage(...,PARAM1,VAL1,PARAM2,VAL2,...) replaces the
%           image, specifying parameters and corresponding values that
%           control various aspects of the image display. Parameter names
%           can be abbreviated, and case does not matter.
%
%       Parameters include:
%
%           'PreserveView'     A logical scalar.  If set to true
%                              imscrollpanel will try to preserve the
%                              current center and magnification during
%                              image replacement.
%
%       Additional parameters include 'Colormap', 'DisplayRanage', and
%       'InitialMagnification'. Type "help imshow" to get more information
%       on these parameters.
%
%   Notes
%   -----
%   Scrollbar navigation as provided by IMSCROLLPANEL is incompatible with the
%   default MATLAB figure navigation buttons (pan, zoom in, zoom out). The
%   corresponding menu items and toolbar buttons should be removed in a custom
%   GUI that includes a scrollable uipanel created by IMSCROLLPANEL.
%
%   When you run IMSCROLLPANEL, it appears to take over the entire figure
%   because by default HPANEL has 'Units' set to 'normalized' and 'Position'
%   set to [0 0 1 1]. If you want to see other children of HPARENT while
%   using your new scroll panel, you must manually set the 'Position' property
%   of HPANEL.
%
%   Example
%   -------
%
%       % Create a scroll panel
%       hFig = figure('Toolbar','none',...
%                     'Menubar','none');
%       hIm = imshow('saturn.png');
%       hSP = imscrollpanel(hFig,hIm);
%       set(hSP,'Units','normalized',...
%               'Position',[0 .1 1 .9])
%
%       % Add a magnification box and an overview tool
%       hMagBox = immagbox(hFig,hIm);
%       pos = get(hMagBox,'Position');
%       set(hMagBox,'Position',[0 0 pos(3) pos(4)])
%       imoverview(hIm)
%
%       % Get the scroll panel API to programmatically control the view
%       api = iptgetapi(hSP);
%
%       % Get the current magnification and position
%       mag = api.getMagnification()
%       r = api.getVisibleImageRect()
%
%       % View the top left corner of the image
%       api.setVisibleLocation(0.5,0.5)
%
%       % Change the magnification to the value that just fits
%       api.setMagnification(api.findFitMag())
%
%       % Zoom in to 1600% on the dark spot
%       api.setMagnificationAndCenter(16,306,800)
%
%   See also IMMAGBOX, IMOVERVIEW, IMOVERVIEWPANEL, IMSHOW, IMTOOL, IPTGETAPI.

%   Copyright 2004-2017 The MathWorks, Inc.

narginchk(2, 2);
parent = varargin{1};
hIm = varargin{2};
hAx = ancestor(hIm,'Axes');

% validate handles
validateHandles(parent,hIm,hAx)

% validate image HG properties
[imageWidth,imageHeight] = validateImageDims(hIm);
validateXYData(hIm,imageWidth,imageHeight);

% Magnification as ratio of screen per image pixel.
screenPerImagePixel = 1;

% arbitrary big choice, 1024 screen pixels for one
% image pixel seems more than anyone could want
maxMag = 1024; 

% hScrollpanel contains:
%    hSliderHor
%    hSliderVer
%    hFrame
%    hAxes
hScrollpanel= uipanel(...
    'BorderType','none',...
    'Parent', parent,...
    'Tag','imscrollpanel',...
    'Units','normalized',...
    'Position',[0 0 1 1]);

iptui.internal.setChildColorToMatchParent(hScrollpanel,parent)

sliderColor = [.9 .9 .9];

hSliderHor = uicontrol(...
    'Style','slider',...
    'Parent',hScrollpanel,...
    'Tag','horizontal slider',...
    'Value', 0.5,...
    'BackgroundColor',sliderColor);

hSliderVer = uicontrol(...
    'Style','slider',...
    'Parent',hScrollpanel,...
    'Tag','vertical slider',...
    'Value', 0.5,...
    'BackgroundColor',sliderColor);

% Scroll bar width
sbwp = 13; 
dprect = matlab.ui.internal.PositionUtils.getPixelRectangleInDevicePixels(...
    [0 0 sbwp sbwp], ancestor(hScrollpanel,'figure'));
sbw = dprect(3);

% Must use events to get continuous events fired as slider
% thumb is dragged. Regular callbacks on sliders give only one event when
% the thumb is released.
hSliderHorListener = iptui.iptaddlistener(hSliderHor,...
        'Value','PostSet',@scrollHorizontal);
    
hSliderVerListener = iptui.iptaddlistener(hSliderVer,...
        'Value','PostSet',@scrollVertical);
                                      
setappdata(hScrollpanel,'hSliderHorListener',hSliderHorListener);
setappdata(hScrollpanel,'hSliderVerListener',hSliderVerListener);

clear hSliderHorListener hSliderVerListener;
                                      
% initialize slider positions at function scope
hSliderHorPos = get(hSliderHor,'Value');
hSliderVerPos = get(hSliderVer,'Value');

hFrame = uicontrol(...
    'Style','frame',...
    'Parent',hScrollpanel);

% Position axes just above horizontal scrollbar to make coordinate
% calculations simpler.
set(hAx,...
    'Parent',hScrollpanel,...
    'Units','pixels',...    
    'TickDir', 'out', ...
    'XGrid', 'off', ...
    'YGrid', 'off', ...
    'XLim',[.5 (imageWidth  + .5)],... % in case someone set xlim,ylim
    'YLim',[.5 (imageHeight + .5)],...
    'Visible','off', ...
    'Tag','hImscrollpanelAxes');
matlab.ui.internal.PositionUtils.setDevicePixelPosition(hAx, ...
    [1 1 getOnScreenImW() getOnScreenImH()]);

% newMagnificationCallbackFunctions is used by sendNewMagnification() to
% notify interested parties whenever the magnification changes.
newMagnificationCallbackFunctions = makeList;

% Pattern for set associated with callbacks that get called as a
% result of the set.
insideSetMagnification = false;

% newLcationCallbackFunctions is used by sendNewLocation() to
% notify interested parties whenever the location changes.
newLocationCallbackFunctions = makeList;

% Pattern for set associated with callbacks that get called as a
% result of the set.
insideSetVisibleLocation = false;

% Stores the id returned by IPTADDCALLBACK for the image object's
% ButtonDownFcn callback.
imageButtonDownFcnId = [];

viewport = []; % gets set by call to updatePositions

% make sure we don't send dupe "events"
lastMagnification = [];
lastLocation = [];

updatePositions();

% Initialize so scrollbars are in sync with location of image
cxInit = 0.5 + imageWidth/2; % Must add 0.5 for default spatial coords
cyInit = 0.5 + imageHeight/2;
setMagnificationAndCenter(screenPerImagePixel,cxInit,cyInit)

set(hScrollpanel,'ResizeFcn',@resizeView);

api.setMagnification                = @setMagnification;
api.getMagnification                = @getMagnification;
api.setMagnificationAndCenter       = @setMagnificationAndCenter;
api.findFitMag                      = @findFitMag;
api.setVisibleLocation              = @setVisibleLocation;
api.getVisibleLocation              = @getVisibleLocation;
api.getVisibleImageRect             = @getVisibleImageRect;
api.addNewMagnificationCallback     = @addNewMagnificationCallback;
api.removeNewMagnificationCallback  = @removeNewMagnificationCallback;
api.addNewLocationCallback          = @addNewLocationCallback;
api.removeNewLocationCallback       = @removeNewLocationCallback;
api.replaceImage                    = @replaceImage;

% undocumented interface, may change in the future
api.setImageButtonDownFcn           = @setImageButtonDownFcn;
api.findMagnification               = @findMagnification;
api.turnOffScrollpanel              = @turnOffScrollpanel;
api.getMinMag                       = @getMinMag;
api.getViewport                     = @getViewport;
    
setappdata(hScrollpanel,'API',api);

    %-------------------------------
    function setMagnification(ratio)

        % Pattern to break recursion
        if insideSetMagnification
            return
        else
            insideSetMagnification = true;
        end

        if ishghandle(get(hScrollpanel,'Parent'))

            [cx,cy] = getCurrentCenter();

            setMagnificationAndCenter(ratio,cx,cy)

        end

        % Pattern to break recursion
        insideSetMagnification = false;


        %----------------------------------
        function [cx,cy] = getCurrentCenter

            % Get current center so we can hold it.
            r = getVisibleImageRect();
            cx = r(1) + r(3)/2;
            cy = r(2) + r(4)/2;

        end

    end

    %--------------------------------
    function ratio = getMagnification

        if ishghandle(get(hScrollpanel,'Parent'))
            ratio = screenPerImagePixel;
        else
            ratio = [];
        end

    end

    %------------------------------------------
    function setMagnificationAndCenter(s,cx,cy)
        % cx and cy are center of new viewport
        % s is requested mag in screenPerImagePixels

        screenPerImagePixel = constrainMag(s);

        % Find xmin,ymin that correspond to holding this cx, cy in the center.
        [xmin,ymin] = findXminYminFromCenter(cx,cy,screenPerImagePixel);
        
        updateAxesPosition(xmin,ymin)
        resizeView()

        sendNewMagnification()
        sendNewLocation()

        %--------------------------------------------
        function ratio = constrainMag(candidateRatio)

            minMag = getMinMag();
            ratio = max(min(candidateRatio,maxMag),minMag);

        end

        %----------------------------
        function sendNewMagnification

            new_magnification = screenPerImagePixel;
            if ~isequal(lastMagnification,new_magnification)
                lastMagnification = new_magnification;
                list = newMagnificationCallbackFunctions.getList();
                for k = 1:numel(list)
                    fun = list(k).Item;
                    fun(new_magnification);
                end
            end
            
        end

    end % setMagnificationAndCenter

    %------------------------------------------------------------------
    function [xmin,ymin] = findXminYminFromCenter(desired_cx,desired_cy,s)
        % desired_cx, desired_cy is the requested center in image coordinates.

        % get viewport size
        vpW = viewport(1);
        vpH = viewport(2);

        % compute requested xmin / ymin
        desiredXmin = desired_cx - vpW/s/2;
        desiredYmin = desired_cy - vpH/s/2;

        % validate xmin ymin
        [xmin,ymin] = findXminYmin(desiredXmin,desiredYmin,s);

    end

    %---------------------------------------------------------------
    function [xmin,ymin] = findXminYmin(desired_xmin,desired_ymin,s)
        % desired_xmin, desired_ymin is the requested TL of the image

        % image dimensions in image pixels
        imW = imageWidth;
        imH = imageHeight;

        % viewport size in screen pixels
        vpW = viewport(1);
        vpH = viewport(2);

        % maximum possible number of image pixels visible in viewport
        visImW = findVisImageDim(imW,vpW);
        visImH = findVisImageDim(imH,vpH);

        % extent of image in screen pixels for magnification "s"
        onScreenImW = imW*s;
        onScreenImH = imH*s;

        % compute the xmin/ymin coordinates for scrollpanel
        xmin = findValidImTL(desired_xmin,imW,onScreenImW,vpW,visImW);
        ymin = findValidImTL(desired_ymin,imH,onScreenImH,vpH,visImH);

        %-------------------------------------------
        function dim = findVisImageDim(imDim, vpDim)

            % compute how many image pixels could fit in the viewport
            % with the image at magnification "s"
            visibleImDim = vpDim/s;

            % if viewport is larger than on-screen visible image dimension
            % then we display the entire image with gray space around it
            dim = min(visibleImDim,imDim);

        end

        %-------------------------------------------------
        function TL = findValidImTL(desiredVisImTL,...
                imDim,...
                onScreenImDim,...
                vpDim,...
                visImDim)

            if (onScreenImDim <= vpDim)
                % TL is TL of image
                TL = 0.5;

            else
                % constrain TL so you cannot scroll past the edge of
                % image
                validVisImTL = clip(desiredVisImTL,imDim,visImDim);
                TL = validVisImTL;

            end

            %---------------------------------------
            function out = clip(in, imDim, visImDim)
                % clip so coordinate stays inside image

                out = max(in,0.5);
                out = min(out, imDim - visImDim + 0.5);

            end

        end

    end % findXminYmin

    %---------------------------
    function fitMag = findFitMag

        candidateFitMag = findMagnification(imageWidth, imageHeight);
        fitMag = max(candidateFitMag,getMinMag());

    end

    %------------------------------------
    function setVisibleLocation(varargin)

        % Pattern to break recursion
        if insideSetVisibleLocation
            return
        else
            insideSetVisibleLocation = true;
        end

        narginchk(1, 2);

        switch nargin
            case 1
                loc = varargin{1};
                xIm = loc(1);
                yIm = loc(2);
            case 2
                xIm = varargin{1};
                yIm = varargin{2};
        end

        % xIm, yIm is the location of the minimum image coordinates in the
        % corner of the viewport.
        %
        % If 'YDir' is 'reverse' this will be the top left corner. If 'YDir' is
        % 'normal' this will be the bottom left corner.

        % validate location
        [xmin,ymin] = findXminYmin(xIm,yIm,getMagnification());
        
        % set new location
        updateAxesPosition(xmin,ymin)

        sendNewLocation()

        % Pattern to break recursion
        insideSetVisibleLocation = false;

    end

    %--------------------------------
    function loc = getVisibleLocation

        pos = getVisibleImageRect();
        loc = pos(1:2);

    end

    %---------------------------------
    function pos = getVisibleImageRect

        % xmin, ymin should be edge of pixel with row=1, col=1.
        % The units are user units as defined by XData and YData

        hAxesPos =  matlab.ui.internal.PositionUtils.getDevicePixelPosition(hAx);

        xdata = getXData(hIm);
        if isFullImageWShowing()
            [xmin,width] = getMinAndDim(xdata,imageWidth);
        else
            dxOnePixel = getDeltaOnePixel(xdata,imageWidth);
            xmin = -dxOnePixel * (hAxesPos(1)-1)/screenPerImagePixel + ...
                xdata(1) - dxOnePixel/2;

            width = dxOnePixel * viewport(1) / screenPerImagePixel;
            
        end

        ydata = getYData(hIm);
        if isFullImageHShowing()
            
            [ymin,height] = getMinAndDim(ydata,imageHeight);

        else
            dyOnePixel = getDeltaOnePixel(ydata,imageHeight);

            % account for scrollbar if showing
            hAxesPosY = hAxesPos(2);
            if isSliderHorShowing
                hAxesPosY = hAxesPosY - sbw; % shift Y-origin by sbw
            end

            maxYInScreenPixels = getOnScreenImH() - viewport(2);
            ymin = dyOnePixel*(maxYInScreenPixels + (hAxesPosY-1) )/screenPerImagePixel + ...
                ydata(1) - dyOnePixel/2;

            height = dyOnePixel * viewport(2) / screenPerImagePixel;

        end

        pos = [xmin ymin width height];

        %--------------------------------------------------
        function [dimMin,dim] = getMinAndDim(dimData,imDim)

            delta = dimData(2) - dimData(1);
            deltaOnePixel = getDeltaOnePixel(dimData,imDim);
            dimMin = dimData(1) - deltaOnePixel/2;
            dim = delta + deltaOnePixel;

        end

    end

    %---------------------------------------------
    function id = addNewMagnificationCallback(fun)
        id = newMagnificationCallbackFunctions.appendItem(fun);
    end

    %------------------------------------------
    function removeNewMagnificationCallback(id)
        newMagnificationCallbackFunctions.removeItem(id);
    end

    %----------------------------------------
    function id = addNewLocationCallback(fun)
        id = newLocationCallbackFunctions.appendItem(fun);
    end

    %-------------------------------------
    function removeNewLocationCallback(id)
        newLocationCallbackFunctions.removeItem(id);
    end

    %----------------------------------
    function setImageButtonDownFcn(fun)

        if ~isempty(imageButtonDownFcnId)
            iptremovecallback(hIm,'ButtonDownFcn',imageButtonDownFcnId);
        end

        if ~isempty(fun)
            imageButtonDownFcnId = iptaddcallback(hIm,'ButtonDownFcn',fun);
        else
            imageButtonDownFcnId = [];
        end

    end

    %------------------------------------
    function mag = findMagnification(w,h)

        % Calculate screenPerImagePixel so image region
        % with width w, height h fits in scrollpanel with no scrollbars
        % showing.                              
        spPos = matlab.ui.internal.PositionUtils.getDevicePixelPosition(hScrollpanel);                           
        spWidth = spPos(3);
        spHeight = spPos(4);
        
        xMag = spWidth / w;
        yMag = spHeight / h;
        mag = min(xMag,yMag);

    end

    %--------------------------
    function turnOffScrollpanel
        % This function turns off the scrollpanel. First, it sets the axes parent
        % to the current parent of the scrollpanel, then it deletes the handle
        % to the scrollpanel. This is needed by clients who want to reuse the
        % handles to an image and/or axes object.

        spParent = get(hScrollpanel,'Parent');
        if ishghandle(spParent)

            % Remove current ButtonDownFcn as it may not work with scrollpanel off
            if ~isempty(imageButtonDownFcnId)
                iptremovecallback(hIm,'ButtonDownFcn',imageButtonDownFcnId);
            end

            set(hAx,'Parent',spParent)
            delete(hScrollpanel)
        end

    end

    %------------------------
    function vp = getViewport

        vp = viewport;
    
    end
    
    %--------------------------
    function minMag = getMinMag
        % Calculate the minimum magnification to always show at least one
        % pixel in each dimension.

        minMag = 1/max(1,min(imageWidth,imageHeight)); % ensure denom~=0
    end

    %------------------------------
    function replaceImage(varargin)
        % The input image will replace the existing image in the
        % scrollpanel.
        % The new image will be displayed centered, at 100% magnification.
        % An active mode, e.g.pan, zoom, set with setImageButtonDownFcn
		% will continue in effect after the image is replaced.
        % The image handle will remain active and
        % unchanged.

        args = matlab.images.internal.stringToChar(varargin);
        
        narginchk(1,Inf);

        specificArgNames = {'PreserveView'};

        [common_args,specific_args] = images.internal.imageDisplayParseInputs(specificArgNames,args{:});
               
        % cache size/view of image prior to replacement
        prev_image_size = [size(get(hIm,'CData'),1)...
            size(get(hIm,'CData'),2)];
        prev_mag = getMagnification();
        prev_vis_rect = getVisibleImageRect();

        % disable modular tool react listeners temporarily
        modular_tool_mgr = getappdata(hIm,'modularToolManager');
        if ~isempty(modular_tool_mgr)
            modular_tool_mgr.disableTools();
        end
        
        % Set properties of new image into the figure, axes and image
		% objects to assure correct display.

        % update the hg image object
        set(hIm, ...
            'CData',common_args.CData,...
            'CDataMapping', common_args.CDataMapping, ...
            'XData', common_args.XData, ...
            'YData', common_args.YData);

        % adjust the axes  
        if ~isempty(common_args.DisplayRange)
            set(hAx, 'CLim', common_args.DisplayRange);
        end

        % if the image has a colormap, update the axes
        if ~isempty(common_args.Map)
            hAx.Colormap = common_args.Map;
        end
        
        % perform input validation as imscrollpanel does      
        [imageWidth,imageHeight] = validateImageDims(hIm);      
        validateXYData(hIm,imageWidth,imageHeight);

        % adjust the axes limits with the new image dimensions
        set(hAx,'XLim', [0.5 imageWidth+0.5])
        set(hAx,'YLim', [0.5 imageHeight+0.5])

        % get new view for scrollpanel (initialize with defaults)
        mag = 1;
        [xCenter,yCenter] = getDefaultView(imageWidth,imageHeight);
        
        % validate 'PreserveView' parameter
        preserveViewSpecified = isfield(specific_args,'PreserveView');
        if preserveViewSpecified
            validatePreserveViewProperty(specific_args.PreserveView);
            preserveViewValue = specific_args.PreserveView;
        else
            preserveViewValue = false;
        end

        % handle/validate 'InitialMagnification' parameter
        initialMagSpecified = ~isempty(common_args.InitialMagnification);
        if initialMagSpecified
            mag = validateInitialMagProperty(common_args.InitialMagnification);
        end
        
        % disallow 'InitialMagnification' parameter and 'PreserveView' true
        if initialMagSpecified && preserveViewValue
            error(message('images:imscrollpanel:incompatibleParameters'))
        end
        
        % handle 'PreserveView' parameter
        if preserveViewValue
            mag = prev_mag;
            [xCenter,yCenter] = getPreserveViewCenter(prev_image_size,...
                [imageHeight,imageWidth],prev_vis_rect);
        end
        
        % set mag and center
        setMagnificationAndCenter(mag,xCenter,yCenter);
        
        % update all
        updatePositions();
        
        % refresh and re-enable react listeners for managed modular tools
        if ~isempty(modular_tool_mgr)
            modular_tool_mgr.refreshTools();
            modular_tool_mgr.enableTools();
        end
        
    end

    %----------------------------------------------
    function [xCenter,yCenter,mag] = getDefaultView(imageWidth,imageHeight)
    
        % Set the center of the view to the center of the image
        xCenter = 0.5 + imageWidth/2; % Must add 0.5 for spatial coords
        yCenter = 0.5 + imageHeight/2;
        mag = 1;
     
    end


    %-------------------------------------------------------------------
    function validatePreserveViewProperty(preserve_view)
        % does error checking on the 'PreserveView' parameter and returns
        % the value
        if  ~islogical(preserve_view) && ~isnumeric(preserve_view)
            error(message('images:imscrollpanel:preserveViewInvalidValue'))
        end
        
    end


    %----------------------------------------------------------------
    function [new_cx,new_cy] = getPreserveViewCenter(prev_size,new_size,...
            prev_rect)
        % find corresponding image center for new image size based on
        % relative position of center to image width and height
        
        % find image center in spatial coords
        prev_cx = prev_rect(1) + 0.5 * prev_rect(3);
        prev_cy = prev_rect(2) + 0.5 * prev_rect(4);
        
        % translate center back to have zero origin
        prev_cx = prev_cx - 0.5;
        prev_cy = prev_cy - 0.5;
        
        % compute "normalized" center position
        prev_cx_normalized = prev_cx / prev_size(2);
        prev_cy_normalized = prev_cy / prev_size(1);
        
        % convert to new image size
        new_cx = prev_cx_normalized * new_size(2);
        new_cy = prev_cy_normalized * new_size(1);
        
        % translate back to 0.5 origin offset
        new_cx = new_cx + 0.5;
        new_cy = new_cy + 0.5;
        
    end


    %---------------------------------------------------------------------------------
    function mag = validateInitialMagProperty(initMag)
    
        % Validates 'InitialMagnification' parameter and handles the 'fit' 
        % case.
        mag = images.internal.checkInitialMagnification(initMag,{'fit'},'replaceImage',...
            'InitialMagnification',[]);
        
        if ~isnumeric(mag)
            mag = findFitMag();
        else
            mag = mag / 100;
        end
    end

    %-------------------------------------------
    function updateAxesPosition(xmin,ymin)
        
        if isFullImageWShowing()
            % x contains the bottom left corner of the visible image. When
            % the conplete image is centered in the view, there is a left
            % and a right margin and x is the required amount of left
            % margin required to center image in the viewport center. The
            % + 1 is necessary because the left-most position of the axes
            % relative to the hScrollpanel is (1,1) in HG pixel units. 
            x = (viewport(1)-getOnScreenImW()) * 0.5 + 1;           
        else
            x = calcVisibleX(xmin);
            updateSliderX(x)
        end

        if isFullImageHShowing()
            y = (viewport(2)-getOnScreenImH()) * 0.5 + 1;
        else
            y = calcVisibleY(ymin);
            updateSliderY(y)
        end

        [w,h] = calcAxesDims();

        matlab.ui.internal.PositionUtils.setDevicePixelPosition(hAx,...
            [x y w h]);

        %--------------------------------
        function xVis = calcVisibleX(xIm)

            xdata = getXData(hIm);
            dxOnePixel = getDeltaOnePixel(xdata,imageWidth);

            xVis = -(xIm - xdata(1) + dxOnePixel/2)*screenPerImagePixel / ...
                dxOnePixel + 1;

        end

        %--------------------------------
        function yVis = calcVisibleY(yIm)

            ydata = getYData(hIm);
            dyOnePixel = getDeltaOnePixel(ydata,imageHeight);

            maxYInScreenPixels = getOnScreenImH() - viewport(2);
            yVis = (yIm - ydata(1) + dyOnePixel/2)*screenPerImagePixel / ...
                dyOnePixel - maxYInScreenPixels + 1;
            
            if isSliderHorShowing
                yVis = yVis + sbw; % shift Y-origin by sbw
            end

        end

        %---------------------------
        function updateSliderX(xVis)

            % g741568 We disable the listener on the sliders so that
            % adjusting the value of the sliders does not count as a
            % vertical/horizontal scroll. Accidentally triggering scroll
            % events causes unintended and difficult to diagnose behavior.
            hSliderHorListener = getappdata(hScrollpanel,'hSliderHorListener');
            setListenerEnabled(hSliderHorListener,false);
            
            numerator = 1 - xVis;
            xSlider = numerator/(getOnScreenImW() - viewport(1));
            xSlider = min(max(xSlider,0),1);
            set(hSliderHor,'Value',xSlider)
            hSliderHorPos = xSlider;

            setListenerEnabled(hSliderHorListener,true);

        end

        %---------------------------
        function updateSliderY(yVis)

            % g741568 We disable the listener on the sliders so that
            % adjusting the value of the sliders does not count as a
            % vertical/horizontal scroll. Accidentally triggering scroll
            % events causes unintended and difficult to diagnose behavior.
            hSliderVerListener = getappdata(hScrollpanel,'hSliderVerListener');
            setListenerEnabled(hSliderVerListener,false);
            
            maxYInScreenPixels = getOnScreenImH() - viewport(2);
            numerator = yVis - 1 + maxYInScreenPixels;
            if isSliderHorShowing
                numerator = numerator - sbw;
            end
            ySlider = 1 - numerator/(getOnScreenImH() - viewport(2));
            ySlider = min(max(ySlider,0),1);
            set(hSliderVer,'Value',ySlider)
            hSliderVerPos = ySlider;
            
            setListenerEnabled(hSliderVerListener,true);

        end

    end % updateAxesPosition

    %------------------------------------------------------
    function [axesW,axesH] = calcAxesDims

        % Need to change size of hAxes to match new mag
        axesW = getOnScreenImW();
        axesH = getOnScreenImH();

    end

    %-----------------------
    function sendNewLocation

        new_location = getVisibleLocation;        
        if ~isequal(lastLocation,new_location) 
            lastLocation = new_location;
            list = newLocationCallbackFunctions.getList();
            for k = 1:numel(list)
                fun = list(k).Item;
                fun(new_location);
            end
        end
        
    end

    %----------------------------------
    function scrollHorizontal(varargin)

        new_slider_pos = get(hSliderHor,'Value');
        if ~isequal(hSliderHorPos,new_slider_pos)
            hSliderHorPos = new_slider_pos;

            hAxesPos = matlab.ui.internal.PositionUtils.getDevicePixelPosition(hAx);
            xPos = findPos(viewport(1),getOnScreenImW(),hSliderHor);
            matlab.ui.internal.PositionUtils.setDevicePixelPosition(hAx,...
                [xPos hAxesPos(2:4)]);

            sendNewLocation()
        end

    end

    %--------------------------------
    function scrollVertical(varargin)

        new_slider_pos = get(hSliderVer,'Value');
        if ~isequal(hSliderVerPos,new_slider_pos)
            hSliderVerPos = new_slider_pos;
            
            hAxesPos = matlab.ui.internal.PositionUtils.getDevicePixelPosition(hAx);
            yPos = findYPos;
            matlab.ui.internal.PositionUtils.setDevicePixelPosition(hAx,...
                [hAxesPos(1) yPos hAxesPos(3:4)]);

            sendNewLocation()
        end

    end

    %----------------------------
    function resizeView(varargin)

        % Temporarily disable ResizeFcn to avoid recursion
        actualResizeFcn = get(hScrollpanel,'ResizeFcn');
        set(hScrollpanel,'ResizeFcn','')

        hAxesPos =  matlab.ui.internal.PositionUtils.getDevicePixelPosition(hAx);
        updateViewport() % Need to do this to get positions correctly

        xPos = findPos(viewport(1),getOnScreenImW(),hSliderHor);
        yPos = findYPos();

        matlab.ui.internal.PositionUtils.setDevicePixelPosition(hAx,...
            [xPos yPos hAxesPos(3:4)]);

        % Call this last to make sure position of hAx is right even when
        % full image is visible.
        updatePositions() 
       
        % Restore ResizeFcn
        set(hScrollpanel,'ResizeFcn',actualResizeFcn)

    end

    %------------------------
    function [pos] = findYPos

        pos = findPos(viewport(2),getOnScreenImH(),hSliderVer);

        if isSliderHorShowing
            pos = pos + sbw;
        end

    end

    %--------------------------------------
    function isShowing = isSliderHorShowing

        isShowing = strcmp('on',get(hSliderHor,'Visible'));

    end

    %----------------------
    function updateViewport
        
        spPos =  matlab.ui.internal.PositionUtils.getDevicePixelPosition(hScrollpanel);

        spWidth  = spPos(3);
        spHeight = spPos(4);

        set(hSliderVer, 'units', 'pixels');
        set(hSliderHor, 'units', 'pixels');
        set(hFrame, 'units', 'pixels');

        onScreenImW = getOnScreenImW();
        onScreenImH = getOnScreenImH();

        showSlider = @(onScreenImDim,spDim) (onScreenImDim > spDim) && (spDim-sbw > 0);
        
        % Decide whether scrollbar is showing based on scrollpanel size 
        showSliderHor = showSlider(onScreenImW,spWidth);
        showSliderVer = showSlider(onScreenImH,spHeight);
        % adjust viewport based on whether sliders show
        viewport = adjustViewportBasedOnWhichSlidersShow();
        
        % Fine tune viewport size based on initial size estimate above.
        % When the viewport size is smaller than the scrollpanel size, by
        % about the size of the scrollbar, the initial size estimate will be
        % wrong. see g347083.
        showSliderHor = showSlider(onScreenImW,viewport(1));
        showSliderVer = showSlider(onScreenImH,viewport(2));
        viewport = adjustViewportBasedOnWhichSlidersShow();
        
        set(hSliderVer, 'units', 'normalized');
        set(hSliderHor, 'units', 'normalized');
        set(hFrame, 'units', 'normalized');

        % Only update sliders if they are showing
        if showSliderHor
            updateSliderThumb(viewport(1), onScreenImW, hSliderHor)
        end

        if showSliderVer
            updateSliderThumb(viewport(2), onScreenImH, hSliderVer)
        end

        %--------------------------------------------------------
        function viewport = adjustViewportBasedOnWhichSlidersShow

            viewport(2) = getViewportDim(showSliderHor,hSliderHor,spHeight);
            viewport(1) = getViewportDim(showSliderVer,hSliderVer,spWidth);

            % Slider and frame positions depend on which sliders are showing
            if showSliderVer && ~showSliderHor
                matlab.ui.internal.PositionUtils.setDevicePixelPosition(hSliderVer,...
                    [(spWidth-sbw)+1 1 sbw spHeight]);
                set(hFrame,'Visible','off')

            elseif ~showSliderVer && showSliderHor
                matlab.ui.internal.PositionUtils.setDevicePixelPosition(hSliderHor,...
                    [1 1 spWidth sbw]);
                set(hFrame,'Visible','off')

            elseif showSliderVer && showSliderHor
                matlab.ui.internal.PositionUtils.setDevicePixelPosition(hSliderHor, ...
                    [1 1 (spWidth-sbw) sbw]);
                matlab.ui.internal.PositionUtils.setDevicePixelPosition(hSliderVer,...
                    [(spWidth-sbw)+1 sbw+1 sbw (spHeight-sbw)]);
                matlab.ui.internal.PositionUtils.setDevicePixelPosition(hFrame,...
                    [(spWidth-sbw)+1 1 sbw sbw]);
                set(hFrame,'Visible','on')                

            else
                set(hFrame,'Visible','off')

            end

            %--------------------------------------------------------
            function vpDim = getViewportDim(showSlider,hSlider,spDim)

                if showSlider
                    set(hSlider,'visible','on')
                    vpDim = (spDim  - sbw);
                else
                    set(hSlider,'visible','off')
                    vpDim = spDim;
                end

            end

        end

        %------------------------------------------------------
        function updateSliderThumb(vpDim,onScreenImDim,hSlider)
        % This routine is a workaround to a limitation in the
        % uicontrol(...,'Style','slider') so that the "thumb" has a length
        % proportional to the amount of image being shown.
        
            if isFullImageShowing(vpDim,onScreenImDim)
                maxStep = inf;
                minStep = 0.01;
            else
                f = vpDim/onScreenImDim;
                maxStep = 1/(1/f - 1);
                minStep = min(1, maxStep/10); % must be between 0 and 1.
            end

            set(hSlider,'SliderStep',[minStep maxStep]);

        end

    end % updateViewport

    %-----------------------
    function updatePositions
        
        updateViewport()
        sendNewLocation()
        

    end

    %---------------------------------------
    function isShowing = isFullImageWShowing

        isShowing = isFullImageShowing(viewport(1),getOnScreenImW());

    end

    %---------------------------------------
    function isShowing = isFullImageHShowing

        isShowing = isFullImageShowing(viewport(2),getOnScreenImH());

    end

    %------------------------------------
    function onScreenImW = getOnScreenImW

        onScreenImW = imageWidth * screenPerImagePixel;

    end

    %------------------------------------
    function onScreenImH = getOnScreenImH

        onScreenImH = imageHeight * screenPerImagePixel;

    end

end % imscrollpanel

%----------------------------------------------------
function [pos] = findPos(vpDim,onScreenImDim,hSlider)

% Find position of hAxes with respect to viewport
if isFullImageShowing(vpDim,onScreenImDim)
    % Center the view at the current magnification. The slider isn't
    % showing and its value is not well defined.
    pos = (vpDim-onScreenImDim) * 0.5 + 1;
else
    pos = (vpDim-onScreenImDim) * get(hSlider, 'value') + 1;
end

end

%--------------------------------------------------------
function isFull = isFullImageShowing(vpDim,onScreenImDim)

if (vpDim >= onScreenImDim)
    isFull = true;
else
    isFull = false;
end

end


%-------------------------------------------------------
function deltaOnePixel = getDeltaOnePixel(dimData,imDim)
% Calculate the extent of one pixel in terms of the user units as defined by
% dimData which will be either the 'XData' or 'YData' associated with an image.

delta = dimData(2) - dimData(1);
if (imDim ~= 1)
    deltaOnePixel = delta/(imDim-1);
else
    deltaOnePixel = 1;
end

end % getDeltaOnePixel

%---------------------------------------
function validateHandles(parent,hIm,hAx)

iptcheckhandle(parent,...
    {'figure','uipanel','uicontainer'},...
    mfilename,'HPARENT',1)
iptcheckhandle(hIm,{'image'},mfilename,'HIMAGE',2)

% Check that hIm is only image child of axes
axKids = get(hAx,'Children');
axImKids = findobj(axKids,'flat','Type','image');
if ~isequal(get(hIm,'parent'),hAx) || ~isscalar(axImKids)
    error(message('images:imscrollpanel:axDoesNotContainOneImage'))
end

% Check that axes is a child of parent
if ~isequal(get(hAx,'parent'),parent)
    error(message('images:imscrollpanel:axNotChildOfParent'))
end

end % validateHandles


%---------------------------------------------------------
function [imageWidth,imageHeight] = validateImageDims(hIm)

% get image dimensions
imageWidth  = images.internal.getImWidth(hIm);
imageHeight = images.internal.getImHeight(hIm);

% For degenerate zero-sized CData we force imageWidth and imageHeight to 
% be nonzero and set some default appropriate XData and YData (g221748).
if imageWidth == 0
    imageWidth = 1;
    set(hIm,'XData',[1 1])
end

if imageHeight == 0
    imageHeight = 1;
    set(hIm,'YData',[1 1])
end

end % validateImageDims


%-----------------------------------------------------------------------------
function validateXYData(hIm,imageWidth,imageHeight)

% Check if XData or YData are non-default, warn and reset
defaultXData = [1 imageWidth];
defaultYData = [1 imageHeight];
xdata = get(hIm,'XData');
ydata = get(hIm,'YData');
isXDataDefault = compareEquality(xdata,defaultXData);
isYDataDefault = compareEquality(ydata,defaultYData);

if ~images.internal.isRSetImage(hIm) && (~isXDataDefault || ~isYDataDefault)  && ...
               (~isempty(xdata) || ~isempty(ydata))
    
    % else reset the XData and YData to be defaults
    
    if ~isXDataDefault
        set(hIm,'XData',[1 imageWidth])
        msgXData = [getString(message('images:imscrollpanel:hasNonDefaultData',...
            'XData',1,imageWidth)) '\n'];
    else
        msgXData = '';
    end
    
    if ~isYDataDefault
        set(hIm,'YData',[1 imageHeight])
        msgYData = getString(message('images:imscrollpanel:hasNonDefaultData',...
            'YData',1,imageHeight));
    else
        msgYData = '';
    end
    
    warning(message('images:imscrollpanel:nonDefaultXDataOrYData', msgXData, msgYData));
    
end

end % validateXYData

%-----------------------------
function TF = compareEquality(data,defaultData)
    if isscalar(data)
        TF = (data == 1);
    else
        TF = isequal(data,defaultData);
    end
end

%-----------------------------
function xdata = getXData(hIm)

xdata = get(hIm,'XData');
if isscalar(xdata)
    xdata = [xdata xdata];
end
if images.internal.isRSetImage(hIm)
    imageWidth = images.internal.getSpatialDims(hIm);
    xdata = [1 imageWidth];
end

end % getXData


%-----------------------------
function ydata = getYData(hIm)

ydata = get(hIm,'YData');
if isscalar(ydata)
    ydata = [ydata ydata];
end
if images.internal.isRSetImage(hIm)
    [~,imageHeight] = images.internal.getSpatialDims(hIm);
    ydata = [1 imageHeight];
end

end % getYData

function setListenerEnabled(h,TF)

h.Enabled = TF;
end

