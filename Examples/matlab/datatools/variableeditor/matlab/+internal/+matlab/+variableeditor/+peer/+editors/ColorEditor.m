

classdef ColorEditor < ...
        internal.matlab.variableeditor.peer.editors.EditorConverter
    
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Color EditorConverter class.  This class is used to provide a way
    % to convert from server-side color representation of RGB color, where
    % RGB are 0:1, and client-side, which is represented in hex, where each
    % color is between 1:255.
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties
        color = [1,1,1,1];
        dataType;
    end
    
    properties(Constant = true)
        COLOR_ENUMS = ["auto", "none", "flat", "interp", "texturemap"];
    end
    
    methods
        function setServerValue(this, value, dataType, ~)
            % Color property is always stored as the RGB value, where R,G,
            % and B are between 0:1.
            if (~isempty(value))
                this.color = value;
            else
                this.color = [1,1,1,1];
            end
            this.dataType = dataType;
        end
        
        function setClientValue(this, value)
            if isequal(value(1), '#')
                % Converts from a client value to the server value.  Client
                % value is a hex color, ie #12ab5f
                red = hex2dec(value(2:3))/255;
                green = hex2dec(value(4:5))/255;
                blue = hex2dec(value(6:7))/255;
                alpha = 1;
                if (length(value)>=9)
                    alpha = hex2dec(value(8:9))/255;
                end
                this.color = [red green blue alpha];
            elseif strncmpi(value, 'rgba', 4)
                vals = sscanf(value,'rgba(%d,%d,%d,%f)');
                r=vals(1);
                g=vals(2);
                b=vals(3);
                a=vals(4);
                this.color = [r/255 g/255 b/255 a];
            elseif strncmpi(value, 'rgb', 3)
                vals = sscanf(value,'rgb(%d,%d,%d)');
                r=vals(1);
                g=vals(2);
                b=vals(3);
                a = 1;
                this.color = [r/255 g/255 b/255 a];
            else
                this.color = value;
            end
        end
        
        function value = getServerValue(this)
            % Returns the server value
            if ischar(this.color)
                value = this.color;
            else
                value = this.color(1:3);
            end
        end
        
        function value = getClientValue(this)
            try
                colorSize = size(this.color);
                colorCount = colorSize(1);
            catch
                colorCount = 1;
            end            
            
            if this.isColorKeyword
                value = this.color;
            elseif colorCount>1
                value = [num2str(colorCount) matlab.internal.display.getDimensionSpecifier '3 double'];
            else
                % Returns the client value.  Takes the RGB server values,
                % converts them to 1:255, and then converts to a hex string.
                red = round(this.color(1)*255);
                green = round(this.color(2)*255);
                blue = round(this.color(3)*255);
                alpha = 1.0;
                if (length(this.color) >= 4)
                    alpha = this.color(4);
                end
                value = sprintf('rgba(%d, %d, %d, %1.2f)', red, green, blue, alpha);
            end
        end
        
        function props = getEditorState(this)
            props = struct;
            
            if isa(this.dataType, 'meta.EnumeratedType') && ...
                    ~isempty(this.dataType.PossibleValues)
                props.showStyle = true;
                props.styleOptions = this.dataType.PossibleValues;
                
                if ischar(this.color)
                    props.styleValue = this.color;
                else
                    props.styleValue = '';
                end
            else
                props.showStyle = false;
            end
            
            %Adding "none" style for RGBAColor type
            if strcmp(this.dataType.Name, 'matlab.graphics.datatype.RGBAColor')
                props.showStyle = true;
                props.styleOptions = {'none'};
            end
            
            props.showRGB = true;
            props.showPalette = true;
            
            % TODO: For now there is no easy way to determine the alpha
            % value from the color property itself.  HG Objects that have
            % alpha allow you to specify the alpha value as a fourth
            % element in the array but they do not allow you to retrieve
            % that fourth value back.  In order to get this value you often
            % have to go to another hidden property to retrieve it.  For
            % example for line there is a hidden property Edge that has
            % another property ColorData that contains the fourth element.
            % For these use cases a proxy object will need to be used.
            % For now we will not show alpha values.
            props.showAlpha = false;
            %             props.showAlpha = strcmp(this.dataType.Name, ...
            %                 'matlab.graphics.datatype.RGBAColor');
        end
        
        function setEditorState(this, props)
        end
    end
    
    methods(Access = private)
        function b = isColorKeyword(this)
            b = ischar(this.color) && any(this.color == internal.matlab.variableeditor.peer.editors.ColorEditor.COLOR_ENUMS);
        end
    end
end
