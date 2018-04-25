classdef ColormapEditor < ...
        internal.matlab.variableeditor.peer.editors.EditorConverter
    
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Colormap EditorConverter class.  This class is used to provide a way
    % to convert from a server-side colormap, an Nx3 matrix of RGB
    % values, and client-side, where built-in colormaps are referred to by
    % name
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        builtInsMap
        colormap
    end
    
    properties(Constant = true)
        COLORMAP_DEFAULT = 'parula'
    end
    
    methods
        function obj = ColormapEditor()
            builtInsNames = {
                'parula'
                'jet'
                'hsv'
                'hot'
                'cool'
                'spring'
                'summer'
                'autumn'
                'winter'
                'gray'
                'bone'
                'copper'
                'pink'
                'lines'
                'colorcube'
                'prism'
                'flag'
                'white'
            };
            
            % the default length of buitl-ins, 64, needs to be specified or
            % else the length of the current colormap will be used
            builtInsValues = cellfun(@(n) feval(n, 64), builtInsNames, 'UniformOutput', false);
            
            obj.builtInsMap = containers.Map(builtInsNames, builtInsValues);
        end
        
        % Called to get the client-side representation of the value
		function value = getClientValue(this)
            if isempty(this.colormap)
                value = this.COLORMAP_DEFAULT;
            else
                name = this.getName(this.colormap);

                if ~isempty(name)
                    value = name;
                else
                    value = this.colormap;
                end
            end
        end
        
        % Called to get the server-side representation of the value
		function value = getServerValue(this)
            if isempty(this.colormap)
                value = this.builtInsMap(this.COLORMAP_DEFAULT);
            elseif ischar(this.colormap)
                value = this.builtInsMap(this.colormap);
            else
                value = cell2mat( cell(this.colormap) );
            end
		end
        
		% Called to set the client-side value
		function setClientValue(this, value)
            this.colormap = value;
        end
        
        % Called to set the server-side value
        function setServerValue(this, value, ~, ~)
            this.colormap = value;
		end
		
		% Called to get the editor state, which contains properties
		% specific to the editor
		function props = getEditorState(this)
            props = [];
		end
		
		% Called to set the editor state.  Unused.
		function setEditorState(~, ~)
		end
    end
    
    methods(Access = private)
        function value = getName(this, cmap)
            for key = keys(this.builtInsMap)
                name = char(key);
                builtIn = this.builtInsMap(name);
                
                % checks if colormap is a built-in, uses a threshold for
                % comparison to deal with floating point precision
                if isequal(size(cmap), size(builtIn)) && all(abs(cmap(:) - builtIn(:)) <= 1e-5)
                    value = name;
                    return;
                end
            end
            
            value = [];
        end
    end
end