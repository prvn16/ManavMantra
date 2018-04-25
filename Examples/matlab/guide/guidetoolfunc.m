function varargout = guidetoolfunc(action, varargin)
%GUIDETOOLFUNC Support function for GUIDE. Support add-on tools.

%   Copyright 1984-2013 The MathWorks, Inc.

narginchk(1,inf);

if isequal(char(com.mathworks.toolbox.matlab.guide.layouttool.LayoutToolHandler.GUIDE_TOOL_INTERFACE), action)
    varargout = guide2tool(varargin{:});
elseif isequal(char(com.mathworks.toolbox.matlab.guide.layouttool.LayoutToolHandler.TOOL_GUIDE_INTERFACE), action)
    varargout = tool2guide(varargin{:});
end

    function out = guide2tool(varargin)
        if nargin==0            
            % these are the actions that GUIDE will ask the tool to carry out
            apis = com.mathworks.toolbox.matlab.guide.layouttool.LayoutToolHandler.getExpectedToolActions;
            result = [];
            for i=1:2:length(apis)
                result.(char(apis(i))) = char(apis(i+1));
            end
            out{1} = result;                        
        else
            out{1} = {};
            actiontype = varargin{1};
            
            switch actiontype,
                case 'load'
                    load(varargin{2:end});

                case 'start'
                    start(varargin{2:end});

                otherwise
                    toolaction(varargin{2:end});
            end
        end

        function start(toolinfo, layout, fig, selection)
            location = char(toolinfo.getPath);
            command = char(toolinfo.getCommand);
          
            % IF this tool is already running, bring it forward
            isrunning = false;
            toolapi = getToolAPI(fig, command);
            if ~isempty(toolapi)
                isrunning = toolapi.toolinfo.isRunning;
                if isfield(toolapi,'figure')
                    isrunning = isrunning && ishandle(toolapi.figure);
                end            
            end
            
            if ~isrunning
                oldpath = addpath(location);
                try
                    % get the api that the tools can use to talk to GUIDE
                    api = guidetoolfunc(char(com.mathworks.toolbox.matlab.guide.layouttool.LayoutToolHandler.TOOL_GUIDE_INTERFACE));            
                    api.figure = fig;

                    % this is where the hand-shake between GUIDE and 
                    % individual tools happens   
                    toolapi = feval(command, 'caller','GUIDE','callerapi',api);
                    toolinfo.setRunning(true);        
                    toolapi.layout = layout;
                    toolapi.toolinfo = toolinfo;           
                    
                    if isfield(toolapi,'figure') && ishandle(toolapi.figure)
                        % set icon
                        if ~isempty(toolinfo.getIcon)
                            oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
                            jf = get(toolapi.figure,'javaframe');
                            warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

                            jf.setFigureIcon(toolinfo.getIcon);
                        end
                        
                        % add cleanup function when tools close
                        set(toolapi.figure, 'CloseRequestFcn',@closeTool);
                    end
                catch me
                    toolinfo.setRunning(false);        

                    guidefunc('showErrorDialog', me, 'Unhandled internal error in guidetoolfunc');
                end
                path(oldpath);

                % save the api for interacting with this tool and tool info
                setToolAPI(fig, command, toolapi);
            else
                if isfield(toolapi,'figure') && ishandle(toolapi.figure)
                    figure(toolapi.figure);
                end
            end


            function closeTool(h, eve)
               setToolAPI(fig, command, []);

               delete(h);
            end
            
        end

        function toolaction(toolinfo, layout, fig, selection)
            % retrieve the api for interacting with this tool
            if ishandle(fig)
                toolapi = getToolAPI(fig, char(toolinfo.getCommand));

                if strcmpi('stop',actiontype) || (isfield(toolapi, 'isRecognizable') && toolapi.isRecognizable(selection))
                    if isstruct(toolapi) && isfield(toolapi, actiontype)
                        try
                            toolapi.(actiontype)(layout, fig, selection);
                        catch me
                            guidefunc('showErrorDialog', me, 'Unhandled internal error in guidetoolfunc');
                        end
                    end
                end
            end
        end

        function toolapi = getToolAPI(fig, command)
            toolapi = [];
            if isappdata(fig, 'tools')
                tools = getappdata(fig, 'tools');
                if isfield(tools, command)
                    toolapi = tools.(command);
                end
            end                
        end

        function setToolAPI(fig, command, api)
            tools = [];
            if isappdata(fig, 'tools')
                tools = getappdata(fig, 'tools');
            end
            if ~isempty(api)
                tools.(command) = api;
            else
                if isfield(tools,command)
                    tools=rmfield(tools,command);
                end
            end
            setappdata(fig,'tools',tools);
        end
    end

    % these define the api by which the tool can talk to GUIDE
    function out = tool2guide(varargin)
        out{1} = struct(...
            'addObject',    @addObject ,...
            'removeObject', @removeObject,...
            'changeObject', @changeObject,...
            'selectObject', @selectObject,...
            'moveObject',   @moveObject,...
            'inspectObject',@inspectObject,...
            'editCallback', @editCallback);

        function addObject(h, iscontainer)
            if ishghandle(h)
                % add GUIDE specific information, such as Tag
                fig = ancestor(h,'figure');
                guidefunc('configNewGobject', h, fig,0);
                guidefunc('initLastValidTag',h);

                % ask GUIDE to take proper action
                layout = getappdata(fig, 'GUIDELayoutEditor');
                layout.getToolHandler.addObject(requestJavaAdapter(h), requestJavaAdapter(get(h,'parent')), iscontainer);
            end
        end

        function removeObject(h)
            if ishghandle(h)
                % ask GUIDE to take proper action
                layout = getappdata(ancestor(h,'figure'), 'GUIDELayoutEditor');
                layout.getToolHandler.removeObject(requestJavaAdapter(h));
            end
        end

        function selectObject(h)
            if ishghandle(h)
                % ask GUIDE to take proper action
                layout = getappdata(ancestor(h,'figure'), 'GUIDELayoutEditor');
                layout.getToolHandler.selectObject(requestJavaAdapter(h), true);
            end
        end

        function moveObject(h)
            if ishghandle(h)
                % ask GUIDE to take proper action
                layout = getappdata(ancestor(h,'figure'), 'GUIDELayoutEditor');
                parent = get(h,'Parent');
                show = get(0, 'showhiddenhandles');
                set(0, 'showhiddenhandles', 'on');
                children = get(parent,'Children');
                set(0, 'showhiddenhandles', show);
                index = find(flipud(children)==h);
                layout.getToolHandler.moveObject(requestJavaAdapter(h), requestJavaAdapter(parent), index);
            end
        end

        function inspectObject(h)
            if ishghandle(h)
                layout = getappdata(ancestor(h,'figure'), 'GUIDELayoutEditor');
                layout.getToolHandler.inspectObject(requestJavaAdapter(h));
            end
        end
        
        function changeObject(h, propertyname)
            if ishghandle(h)
                % if it is Tag, ask GUIDE to manage it
                if strcmpi(propertyname,'Tag')
                    guidefunc('updateTag',{h}, {get(h,'type')}, {''});
                end
                
                % ask GUIDE to take proper action
                layout = getappdata(ancestor(h,'figure'), 'GUIDELayoutEditor');
                layout.getToolHandler.changeObject(requestJavaAdapter(h));
            end
        end
        
        function editCallback(h, callbackname)
            if ishghandle(h)
                guidefunc('editCallback', ancestor(h,'figure'),{h}, callbackname);
            end
        end        
    end

%close to hide?
end

% ****************************************************************************
% utility for searching up the instance hierarchy for the figure ancestor
% ****************************************************************************
function fig = getParentFigure(h)

while ~isempty(h) && ~strcmp(get(h,'type'),'figure')
    h = get(h,'parent');
end
fig = h;

end