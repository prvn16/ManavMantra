function  varargout = toolpalette(varargin)
% TOOLPALETTE Helper GUI for ICONEDITOR
%       TOOLPALETTE is a helper GUI for the ICONEDITOR. It provides editing
%       tools for creating icons.TOOLPALETTE populate a tool palette into a
%       given figure or panel provided as an input parameter through custom
%       property 'parent'. If user does not provide parent, GCF will be
%       used. 
%
%       TOOLPALETTE('Property','Value',...) runs the GUI. This GUI
%       accepts property value pairs from the input arguments. Only the
%       following custom properties are supported that can be used to
%       initialize this GUI. The names are not case sensitive:  
%         'parent'  the parent figure or panel that holds the color palette
%       Other unrecognized property name or invalid value is ignored.
%
%   Examples:
%
%   fhandle = toolpalette;
%   color = fhandle();
%
%   panel = uipanel('title', 'Palette');    
%   fhandle = toolpalette('parent', panel);

%   Copyright 1984-2007 The MathWorks, Inc.

% Declare non-UI data so that they can be used in any functions in this GUI
% file, including functions triggered by creating the GUI layout below
mInputArgs      = varargin; % Command line arguments when invoking the GUI
mOutputArgs     = {};       % Variable for storing output when GUI returns
% Variables for supporting custom property/value pairs
mPropertyDefs   = {...      % The supported custom property/value pairs of this GUI
                   'parent',        @localValidateInput, 'mPaletteParent';
                   'iconeditorapi', @localValidateInput, 'mIconEditorAPI' };
mPaletteParent  = [];       % Use input property 'parent' to initialize
mIconEditorAPI  = struct;   % Use input property 'iconeditorapi' to initialize

% Process the command line input arguments supplied when the GUI is
% invoked
processUserInputs();                            

% Declare and create all the UI objects in this GUI here so that they can
% be used in any functions
hDefaultTool =[];   % default selected tool in palette
hPalettePanel       =   uibuttongroup('Parent',mPaletteParent, ...
                            'Units', 'normalized',...
                            'Position',[0 0 1 1],...
                            'Title',{''},...
                            'BorderType', 'none',...
                            'SelectionChangeFcn', @hPalettePanelSelectionChanged);
% Dynamically create the color cells and palette tools and layout component
layoutComponent();

% Return user defined output if it is requested
mOutputArgs{1} = [];
if nargout>0
    [varargout{1:nargout}] = mOutputArgs{:};
end
    

    %----------------------------------------------------------------------
    function hPalettePanelSelectionChanged(hObject, eventdata)
        % update the selected tool of iconeditor
        notifyToolChange();        
    end

    function notifyToolChange()        
        % if work as part of iconeditor
        api = 'setCurrentTool';
        if ~isempty(mIconEditorAPI) && isfield(mIconEditorAPI, api)
            % move focus to this tool
            tool = get(hPalettePanel,'SelectedObject');
            uicontrol(tool);

            tool = struct(...
                'type','tool',...
                'tool', tool,...
                'action',@dispatchToolAction);
            mIconEditorAPI.(api)(tool);
        end
    end

    function cdata =dispatchToolAction(toolstruct, cdata, point, overicon, mousedown)

        if ~isempty(toolstruct) && isfield(toolstruct, 'tool')
            tool = toolstruct.tool; 

            % update cursor of the figure
            updatePointerToThis(tool, overicon);

            if ishandle(tool) && overicon && mousedown
                rows = size(cdata,1);
                cols = size(cdata,2);
                x = ceil(point(1,1));
                y = ceil(point(1,2));
                if (x>0 && x<=cols) && (y>0 && y<=rows)
                    def = get(tool, 'UserData');
                    if ~isempty(def) && isfield(def,'Callback')
                        cdata = def.Callback(toolstruct, cdata, point);
                    end
                end
            end
        end
    end

    %----------------------------------------------------------------------
    function cdata = pencilToolCallback(toolstruct, cdata, point)
    % Callback called when the eraser palette tool button is pressed
        x = ceil(point(1,1));
        y = ceil(point(1,2));

        % update color of the selected block
        api = 'getColor';
        if ~isempty(mIconEditorAPI) && isfield(mIconEditorAPI, api)
            color = mIconEditorAPI.(api)();
            cdata(y, x,:) = color;
        end
    end

    %----------------------------------------------------------------------
    function cdata = eraserToolCallback(toolstruct, cdata, point)
    % Callback called when the eraser palette tool button is pressed
        x = ceil(point(1,1));
        y = ceil(point(1,2));
        cdata(y, x,:) = [NaN, NaN, NaN];
    end

    %----------------------------------------------------------------------
    function cdata = bucketToolCallback(toolstruct, cdata, point)
    % Callback called when the bucket palette tool button is pressed
        x = ceil(point(1,1));
        y = ceil(point(1,2));

        rows = size(cdata,1);
        cols = size(cdata,2);
        color =[];
        
        api = 'getColor';
        if ~isempty(mIconEditorAPI) && isfield(mIconEditorAPI, api)
            color = mIconEditorAPI.(api)();
            if ~isempty(color) && ~isequal(color, reshape(cdata(y,x,:), size(color)))
                fillWithColor(x,y,cdata(y,x,:));
            end
        end
        
        function fillWithColor(row, col, seedcolor)
            % fill this color first
            cdata(col,row,:) =color;
            
            % look for for four neighbors
            match = [];
            neighbors =[row, col-1;
                        row, col+1;
                        row-1, col;
                        row+1, col];
            for i=1:length(neighbors)
                if (neighbors(i,2)>0 && neighbors(i,2)<=rows) && (neighbors(i,1)>0 && neighbors(i,1)<=cols) 
                    thiscolor = cdata(neighbors(i,2), neighbors(i,1),:);                        
                    if isequal(thiscolor, seedcolor) || ...
                        ((isnan(thiscolor(1)) && isnan(seedcolor(1))) ...
                        || (isnan(thiscolor(2)) && isnan(seedcolor(2))) ...                            
                        || (isnan(thiscolor(3)) && isnan(seedcolor(3))))

                        match(end+1) = i;
                    end
                end
            end
            
            % if we have match, go to the matched locations
            if ~isempty(match)
                for i=1:length(match)
                    fillWithColor(neighbors(match(i),1), neighbors(match(i),2), seedcolor);
                end
            end
        end

    end

    %----------------------------------------------------------------------
    function cdata = colorpickerToolCallback(toolstruct, cdata, point)
    % Callback called when the color picker palette tool button is pressed
        x = ceil(point(1,1));
        y = ceil(point(1,2));

        if ~isempty(mIconEditorAPI) && isfield(mIconEditorAPI,'setColor')
            color = cdata(y, x,:);
            if isempty(find(isnan(color), 1))
                mIconEditorAPI.setColor(color);

%                 set(hPalettePanel, 'SelectedObject',hDefaultTool); 
%                 % reset focus
%                 updatePointerToThis(hDefaultTool, true);
% 
%                 notifyToolChange();        
            end
        end        
    end

    %----------------------------------------------------------------------
    function updatePointerToThis(hTool, overicon)
        fig = get(hTool,'parent');
        while(~ishghandle(fig,'figure'))
            fig = get(fig,'Parent');
        end
        if ~overicon
            set(fig,'pointer','arrow');   
        else
            cdata = round(mean(get(hTool, 'cdata'),3))+1;
            if ~isempty(cdata)
                set(fig,'pointer','custom','PointerShapeCData',cdata(1:16, 1:16),'PointerShapeHotSpot',[9 9]);                        
            end
        end
    end

    %----------------------------------------------------------------------
    function layoutComponent
    % helper function that dynamically creats all the tools and color cells
    % in the palette. It also positions all other UI objects properly. 
        % get the definision of the layout
        [mLayout, mToolEntries] = localDefineLayout();
        
        % change the size of the color palette to the desired size, place
        % the components, and then change size back.
        setpixelposition(hPalettePanel, [0, 0, mLayout.preferredWidth, mLayout.preferredHeight+(2*mLayout.vgap)]);
        
        % create tools
        startY = mLayout.preferredHeight;
        for i=1:mLayout.toolRowNumber
            for j=1:mLayout.toolPerRow
                if ((i-1)*mLayout.toolPerRow + j)>length(mToolEntries)
                    break;
                end
                tool = mToolEntries{(i-1)*mLayout.toolPerRow + j};
                control = uicontrol('Style','ToggleButton',...
                            'Parent',hPalettePanel, ...
                            'TooltipString', tool.Name,...
                            'UserData', tool,...
                            'Units','pixels',...
                            'Position',[mLayout.hgap+(j-1)*(mLayout.toolSize+mLayout.hgap),...
                                        startY- i*(mLayout.toolSize+mLayout.hgap),...
                                        mLayout.toolSize, mLayout.toolSize]);            
                if isfield(tool,'Icon')
                    set(control,'CData',iconread(tool.Icon));
                end
                if isfield(tool,'Visible')
                    set(control,'Visible',tool.Visible);
                end
                set(control,'units','normalized');
                
                if tool.DefaultTool
                    hDefaultTool = control;
                end
            end
        end

        % restore palette to the full size                               
        set(hPalettePanel, 'units', 'normalized', 'Position', [0 0 1 1]);
        
        % notify initial selection
        notifyToolChange();

        %----------------------------------------------------------------------
        function [layout, tools]=localDefineLayout
        % helper functions that provides the data defining the color palette    
            tools = localDefineTools();

            pos = getpixelposition(hPalettePanel);
            
            layout.hgap = 3;
            layout.vgap = 5;
            layout.toolSize = 25;
            layout.toolPerRow = floor(pos(3)/layout.toolSize);
            
            % calculate the preferred width and height
            width  =  (layout.toolSize+layout.hgap)*layout.toolPerRow;
            layout.toolPerRow =  ceil(width/(layout.toolSize+layout.vgap));
            layout.toolRowNumber =  ceil(length(tools)/ceil(width/(layout.toolSize+layout.vgap)));
            height =  layout.toolRowNumber*(layout.toolSize+layout.vgap);
            layout.preferredWidth = layout.hgap+width;
            if layout.preferredWidth < pos(3)
               layout.preferredWidth = pos(3); 
            end
            layout.preferredHeight = 2*layout.vgap+height;
            if layout.preferredHeight < pos(4)
               layout.preferredHeight = pos(4); 
            end
        end

        %--------------------------------------------------------------------------
        function tools = localDefineTools
        % helper function that defines the tools shown in this color
        % palette. The 'name' is used to show a tooltip of the tool. The
        % 'callback' is used to provide the function called when the
        % corresponding tool is selected. You can change the tools in the
        % palette by adding/removing entries.
        tools = {struct('Name',getUserString('TooltipPencil'), ...
                         'Icon', 'pencil.png',...
                         'DefaultTool', true,...
                         'Callback', @pencilToolCallback)...
                 struct('Name',getUserString('ErasecolorTooltip'), ...
                         'DefaultTool', false,...
                         'Icon', 'eraser.png',...
                         'Callback', @eraserToolCallback)...
                 struct('Name',getUserString('FillwithcolorTooltip'), ...
                         'DefaultTool', false,...
                         'Icon', 'bucket.png',...
                         'Callback', @bucketToolCallback),...
                 struct('Name',getUserString('PickcolorTooltip'), ...
                         'DefaultTool', false,...
                         'Icon', 'eyedropper.png',...
                         'Callback', @colorpickerToolCallback)};
        end
    end


    %----------------------------------------------------------------------
    function processUserInputs
    % helper function that processes the input property/value pairs 
        % Apply recognizable custom parameter/value pairs
        for index=1:2:length(mInputArgs)
            if length(mInputArgs) < index+1
                break;
            end
            match = find(ismember({mPropertyDefs{:,1}},mInputArgs{index}));
            if ~isempty(match)  
               % Validate input and assign it to a variable if given
               if ~isempty(mPropertyDefs{match,3}) && mPropertyDefs{match,2}(mPropertyDefs{match,1}, mInputArgs{index+1})
                   assignin('caller', mPropertyDefs{match,3}, mInputArgs{index+1}) 
               end
            end
        end        

        if isempty(mPaletteParent)
            mPaletteParent =gcf;
        end
    end

    %----------------------------------------------------------------------
    function isValid = localValidateInput(property, value)
    % helper function that validates the user provided input property/value
    % pairs. You can choose to show warnings or errors here.
        isValid = false;
        switch lower(property)
            case 'parent'
                if ishandle(value) 
                    isValid =true;
                end
            case 'iconeditorapi'
                if isstruct(value) 
                    isValid =true;
                end
        end
    end

    %------------------------------------------------------------------
    function string = getUserString(key)
        string = getString(message(sprintf('%s%s','MATLAB:guide:toolpalette:',key)));
    end

end % end of iconPalette

