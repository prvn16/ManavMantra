function varargout = putdowntext(varargin)
%PUTDOWNTEXT  Plot Editor helper function
%
%   See also PLOTEDIT

%   Copyright 1984-2015 The MathWorks, Inc.

figInputArgPos = 0;
if ischar(varargin{1})
    fig = gcbf;
    if ~any(ishghandle(fig)), return, end
    action = varargin{1};
    
    toolButton = LGetToolButton(fig);
    
    if nargin>1
      if ~isempty(toolButton)  % aborting one operation and starting another
         if ishghandle(toolButton) ...
            && strcmp(get(toolButton,'Type'),'uitoggletool') ...
            && toolButton ~= gcbo ...  % not the same button
            && ancestor(toolButton,'Figure') == fig % Same Window
            set(toolButton,'State','off');
            drawnow update;
         end
      end
      if ~isempty(varargin{2})
          toolButton = varargin{2};
      end
   end
else
    fig = varargin{1}(1);
    if ~any(ishghandle(fig)), return, end
    if ~isempty(varargin{2})
        action = varargin{2};
    end
    toolButton = LGetToolButton(fig);
    figInputArgPos = 1;
end

if ~any(ishghandle(fig)), return, end
LSetToolButton(fig, toolButton);

stateData = getappdata(fig,'ScribeAddAnnotationStateData');
if isempty(stateData)
    stateData = LInitStateData(fig);
    setappdata(fig,'ScribeAddAnnotationStateData', stateData);
end


switch action

    case 'select'
        switch get(toolButton,'State')
            case 'off'
                plotedit(fig,'off');
            case 'on'
                plotedit(fig,'on');
        end

    case 'start'
        varargout{1} = 1;

        LSetSelect(fig,'off');  % plotedit off first

        LMaskAll(fig,'off');    % this saves windowXXXFcn settings
        set(toolButton,'State','on');

        set(fig,'Pointer',stateData.oldPointer);
        if any(ishghandle(stateData.myline))
            delete(stateData.myline);
        end
        stateData = LInitStateData(fig);
        setappdata(fig,'ScribeAddAnnotationStateData', stateData);

    case 'axesstart'
        if putdowntext('start')
            set(fig,'Pointer','crosshair',...
                'WindowButtonDownFcn',@(e,d) putdowntext('hitaxes','',fig,d));
        end
    case 'hitaxes'
        fig = varargin{3+figInputArgPos};
        evd = varargin{4+figInputArgPos};

        % Find the scribe layer for the hit uipanel/uitab/uicontainer or figure. This ensures
        % that the scribe object will be drawn in the same layer where the
        % gesture was initiated.
        hitobj = evd.HitObject;
        container = ancestor(hitobj,{'uipanel','uitab','uicontainer'});

        if isempty(container)
            container = fig;
        end

        rect = rbbox;  % returns a rectangle in figure units
        units = get(container,'Units');
        if all(rect(3:4) > 0)
            %jpropeditutils('jundo','start',fig);
            rect = hgconvertunits(fig,rect,fig.Units,units,container);
            newAx = axes('Parent',container,...
                'Units',units,...
                'Position',rect);
            set(newAx,'Units','normalized');
          
      
            %jpropeditutils('jundo','stop',fig);
            % Single click should open an axes at the bottom just like clicking
            % on the Axes icons in the FigurePalette (c.f. g367287)
        else
           newAx =  addsubplot(container,'Bottom','axes','Box','on','XGrid','off','YGrid','off','ZGrid','off');
        end
       
        putdowntext reset;
        % end add with plotedit on always
        LSetSelect(fig,'on'); % do this last
        selectobject(newAx,'replace');
        graph2dhelper('registerUndoInsertAxes',newAx);

    case 'reset'

        try
            if any(ishghandle(stateData.myline))
                delete(stateData.myline);
                stateData.myline = [];
            end

            if any(ishghandle(fig))
                if ~isempty(toolButton)
                    set(toolButton,'State','off');
                end

                stateData = LInitStateData(fig);
                setappdata(fig,'ScribeAddAnnotationStateData', stateData);

                LMaskAll(fig,'on');  % restore
            end
        catch err %#ok<NASGU>
            % state may have changed while we were finishing
            % up. e.g. window closed etc.
        end

    case 'zoomin'
        fixtoolbar(fig);
        onoff = get(toolButton,'State');
        if strcmp(onoff,'on')
            zoom(fig,'inmode');
        else
            zoom(fig,'off')
        end

    case 'zoomout'
        fixtoolbar(fig);
        onoff = get(toolButton,'State');
        if strcmp(onoff,'on')
            zoom(fig,'outmode');
        else
            zoom(fig,'off')
        end
        
    case 'zoomx'
        fixtoolbar(fig);
        onoff = get(toolButton,'State');
        if strcmp(onoff,'on')
            zoom(fig,'inmodex');
        else
            zoom(fig,'off');
        end

    case 'zoomy'
        fixtoolbar(fig);
        onoff = get(toolButton,'State');
        if strcmp(onoff,'on')
            zoom(fig,'inmodey');
        else
            zoom(fig,'off');
        end
        
    case 'pan'
        fixtoolbar(fig);
        if any(ishghandle(toolButton))
            if strcmpi(get(toolButton,'State'),'on')
                pan(fig,'onkeepstyle')
            else
                pan(fig,'off');
            end
        end

    case 'rotate3d'
        fixtoolbar(fig);
        if any(ishghandle(toolButton))
            rotate3d(fig,get(toolButton,'State'));
        else
            rotate3d;
        end

    case 'datatip'
        fixtoolbar(fig);
        if any(ishghandle(toolButton))
            datacursormode(fig,get(toolButton,'State'));
        end
    case 'brush'
        fixtoolbar(fig);
        if any(ishghandle(toolButton))
            if strcmpi(get(toolButton,'State'),'on')
                brush(fig,'on')
            else
                brush(fig,'off')
            end
        end
            
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function LMaskAll(fig,  setting)

        WindowFcnList = {...
            'Pointer',...
            'WindowButtonDownFcn', ...
            'WindowButtonMotionFcn',...
            'WindowButtonUpFcn'};

        savedSettings = getappdata(fig,'ScribeWindowMaskSettings');

        switch setting
            case 'on'  % restore
                if ~isempty(savedSettings) && isstruct(savedSettings)
                    set(fig, WindowFcnList, savedSettings.WindowFcns);
                    savedSettings = [];
                end
            case 'off' % save
                savedSettings.WindowFcns = get(fig, WindowFcnList);
                set(fig, WindowFcnList(2:4), {'' '' ''});
        end

        setappdata(fig,'ScribeWindowMaskSettings',savedSettings);

        function LSetSelect(fig,state)
            if any(ishghandle(fig))
                switch state
                    case 'off'
                        scribeclearmode(fig,'putdowntext',fig,'reset');
                    case 'on'
                        plotedit(fig,'on');
                end
            end

            function stateData = LInitStateData(fig)
                stateData = struct(...
                    'x',[], ...
                    'y', [], ...
                    'myline', [], ...
                    'isarrow', 0, ...
                    'oldPointer', get(fig,'Pointer'));

function toolButton = LGetToolButton(fig)
    if isprop(fig,'ScribeCurrentToolButton')
        toolButton = fig.ScribeCurrentToolButton;
    else
        toolButton = [];
    end

function LSetToolButton(fig, toolButton)
    if ~isprop(fig,'ScribeCurrentToolButton')
        p=addprop(fig,'ScribeCurrentToolButton');
        p.Transient = true;
        p.Hidden = true;
    end
    fig.ScribeCurrentToolButton = toolButton;
        





