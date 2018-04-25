function hout = imoverviewpanel(varargin)
%IMOVERVIEWPANEL Overview tool panel for image displayed in scroll panel.
%   HPANEL = IMOVERVIEWPANEL(HPARENT, HIMAGE) creates an Overview tool panel
%   associated with the image specified by the handle HIMAGE, called the target
%   image. HIMAGE must be contained in a scroll panel created by
%   IMSCROLLPANEL. HPARENT is a handle to the figure or uipanel object that will
%   contain the Overview tool panel. IMOVERVIEWPANEL returns HPANEL, a handle to
%   the Overview tool uipanel object.
%
%   The Overview tool is a navigation aid for images displayed in a scroll
%   panel. IMOVERVIEWPANEL creates the tool in a uipanel object that can be
%   embedded in a figure or uipanel object. The tool displays the target image
%   in its entirety, scaled to fit.  Over this scaled version of image, the tool
%   draws a rectangle, called the detail rectangle, that shows the portion of
%   the target image that is currently visible in the scroll panel. To view
%   portions of the image that are not currently visible in the scroll panel,
%   move the detail rectangle in the Overview tool.
%
%   Note
%   ----
%   To create an Overview tool in a separate figure, use IMOVERVIEW.
%
%   Example
%   -------
%
%       hFig = figure('Toolbar','none',...
%                     'Menubar','none');
%       hIm = imshow('tissue.png');
%       hSP = imscrollpanel(hFig,hIm);
%       set(hSP,'Units','normalized',...
%               'Position',[0 .5 1 .5])
%
%       hOvPanel = imoverviewpanel(hFig,hIm);
%       set(hOvPanel,'Units','Normalized',...
%                    'Position',[0 0 1 .5])
%
%   See also IMOVERVIEW, IMRECT, IMSCROLLPANEL.

%   Copyright 2004-2016 The MathWorks, Inc.

% validate input
narginchk(2, 2);
parent = varargin{1};
targetImage = varargin{2};

iptcheckhandle(parent,{'figure','uipanel','uicontainer'},mfilename,'HPARENT',1)
iptcheckhandle(targetImage,{'image'},mfilename,'HIMAGE',2)

hScrollpanel = checkimscrollpanel(targetImage,mfilename,'HIMAGE');
apiScrollpanel = iptgetapi(hScrollpanel);
hScrollpanelAx = findobj(hScrollpanel,'Type','Axes');

% create main panel
hOverviewPanel = uipanel(...
    'Parent',parent,...
    'Tag','imoverviewpanel',...
    'BorderType','none');

% initialize function scope variables
hFig = ancestor(targetImage,'figure');
hAx  = ancestor(targetImage,'axes');
hOverviewFig = ancestor(hOverviewPanel,'figure');
hOverviewAx = [];
hOverviewIm = [];
sp_callback = [];
sp_callback_mag = [];
apiDetailRect = [];

% populate the panel
initializePanel;

% create listeners and register tool handle
reactToImageChangesInFig(targetImage,hOverviewPanel,@reactDeleteFcn,...
    @reactRefreshFcn);
registerModularToolWithManager(hOverviewPanel,targetImage);

if (nargout==1)
    hout = hOverviewPanel;
end


    %-----------------------
    function initializePanel

        % create axes and image
        hOverviewAx = createAxesFromTargetAxes(hScrollpanelAx,hOverviewPanel);
        set(hOverviewAx,...
            'Units','normalized',...
            'Position',[0 0 1 1],...
            'DeleteFcn',@OverviewAxesDeleteFcn);
        hOverviewIm = createImageFromTargetImage(targetImage, hOverviewAx);
        
        % Workaround hittest weirdness that is not allowing us to click on
        % interior of detail rect.
        set(hOverviewIm,'hittest','off');

        if ismatrix(get(targetImage, 'CData'))
            set(hOverviewFig, 'Colormap', colormap(hAx));
        end

        % create detail rect
        hDetailRect = imrect(hOverviewAx, ...
            apiScrollpanel.getVisibleImageRect());
        hDetailRect.Deletable = false;

        % In extreme aspect ratio situations, the detail rect can be
        % difficult to drag.  This is because the rect's ButtonDownFcn is
        % not getting called, even though hittest thinks it should.  A
        % workaround is to turn off clipping on the HG objects that make up
        % the detail rect.  See g229481.
        set(findobj(hDetailRect), 'Clipping', 'off');

        apiDetailRect = iptgetapi(hDetailRect);
        apiDetailRect.addNewPositionCallback(@detailDragged);
        apiDetailRect.setPositionConstraintFcn(@constrainDetail);
        apiDetailRect.setResizable(false);

        % add scrollpanel callback to keep hDetailRect in sync
        sp_callback = apiScrollpanel.addNewLocationCallback(@updateDetail);
        sp_callback_mag = apiScrollpanel.addNewMagnificationCallback(@updateDetail);

        % link axes properties
        linkAxCLim = linkprop([hScrollpanelAx hOverviewAx],'CLim');
        setappdata(hOverviewAx,'linkAxCLimListener',linkAxCLim);
        linkAxXLim = linkprop([hScrollpanelAx hOverviewAx],'XLim');
        setappdata(hOverviewAx,'linkAxXLimListener',linkAxXLim);
        linkAxYLim = linkprop([hScrollpanelAx hOverviewAx],'YLim');
        setappdata(hOverviewAx,'linkAxYLimListener',linkAxYLim);
        
        % link image properties
        linkImageXData = linkprop([targetImage hOverviewIm],'XData');
        setappdata(hOverviewIm,'linkImageXDataListener',linkImageXData);
        linkImageYData = linkprop([targetImage hOverviewIm],'YData');
        setappdata(hOverviewIm,'linkImageYDataListener',linkImageYData);
        linkImageCDataMapping = linkprop([targetImage hOverviewIm],'CDataMapping');
        setappdata(hOverviewIm,'linkImageCDataMappingListener',linkImageCDataMapping);

    end


    %--------------------------------
    function reactDeleteFcn(obj,evt) %#ok<INUSD>

        if ishghandle(hOverviewPanel)
            delete(hOverviewPanel);
        end

    end


    %--------------------------------
    function reactRefreshFcn(obj,evt) %#ok<INUSD>

        % close tool if the target image cdata is empty
        if isempty(get(targetImage,'CData'))
            reactDeleteFcn();
            return;
        end
        
        % delete old axes and reinitialize panel
        if ishghandle(hOverviewAx)
            delete(hOverviewAx);
        end
        initializePanel;
       
    end


    %-------------------------------
    function detailDragged(varargin)

        if exist('apiDetailRect','var') % geck this to nested functions
            posDetail = apiDetailRect.getPosition();
            apiScrollpanel.setVisibleLocation(posDetail(1),posDetail(2));

            % force update, see: g295731, g301382, g303455
            % drawnow expose
        end

    end

    %------------------------------------------
    function new_pos = constrainDetail(pos)
        
        imW = size(get(hOverviewIm,'CData'),2);
        imH = size(get(hOverviewIm,'CData'),1);
        
        % get spatial span of data
        xdata = getXData(hOverviewIm);
        ydata = getYData(hOverviewIm);
        
        % compute pixel span in each direction
        dx = images.internal.getDeltaOnePixel(xdata,imW);
        dy = images.internal.getDeltaOnePixel(xdata,imH);
        
        left_edge   = xdata(1) - dx/2;
        right_edge  = xdata(2) + dx/2;
        top_edge    = ydata(1) - dy/2;
        bottom_edge = ydata(2) + dy/2;
        
        x_min = pos(1);
        y_min = pos(2);
        w     = pos(3);
        h     = pos(4);
        
        x_min = min( right_edge  - w, max(x_min, left_edge) );
        y_min = min( bottom_edge - h, max(y_min, top_edge) );
        
        new_pos = [x_min y_min w h];
 
    end

    %------------------------------
    function updateDetail(varargin)

        newpos = apiScrollpanel.getVisibleImageRect();
        apiDetailRect.setPosition(newpos);

    end

    %---------------------------------------
    function OverviewAxesDeleteFcn(varargin)

        apiScrollpanel.removeNewLocationCallback(sp_callback);
        apiScrollpanel.removeNewMagnificationCallback(sp_callback_mag);

    end

end

%--------------------------------
function xdata = getXData(handle)

xdata = get(handle,'XData');
if isscalar(xdata)
    xdata = [xdata xdata];
end

end

%--------------------------------
function ydata = getYData(handle)

ydata = get(handle,'YData');
if isscalar(ydata)
    ydata = [ydata ydata];
end

end
