classdef ColorChooser < matlab.ui.internal.dialog.Dialog
% This function is undocumented and will change in a future release

%   Copyright 2008-2014 The MathWorks, Inc.

    properties
        InitialColor = [1 1 1];
        Title = getString(message('MATLAB:uistring:uisetcolor:TitleColor'));
    end
    
    properties(SetAccess='private',GetAccess='public')
        SelectedColor;
    end

    methods
        function set.InitialColor(obj, v)
            %We are not going to allow values like [true false false]
            %as valid colors
            if ~isnumeric(v)
                error(message('MATLAB:UiColorChooser:InvalidColorType'));
            end
            %if multidimensional or column wise vector is given, extract color values
            obj.InitialColor = convert(obj,v);
        end      
       
        function set.Title(obj,v)
            if ~ischar(v) 
                    error(message('MATLAB:UiColorChooser:InvalidTitle'));
            end
            if ~isempty(v)
                obj.Title = v;
            end
        end
        
    end
    
    methods
        function obj = ColorChooser()
            createPeer(obj);
        end    
                
        function createPeer(obj)
            if ~isempty(obj.Peer)
                delete(obj.Peer);
            end
            obj.Peer = handle(javaObjectEDT('com.mathworks.mlwidgets.graphics.ColorDialog',obj.Title),'callbackproperties');
        end
        
              
        function setPeerInitialColor(obj,v)
            jColor = java.awt.Color(v(1),v(2),v(3));
            obj.Peer.setInitialColor(jColor);
        end
        
        
        function show(obj)
            setPeerTitle(obj,obj.Title);
            setPeerInitialColor(obj,obj.InitialColor);
            jSelectedColor = obj.Peer.showDialog(obj.getParentFrame);
            if ~isempty(jSelectedColor)
                obj.SelectedColor = [jSelectedColor.getRed  jSelectedColor.getGreen jSelectedColor.getBlue] / 255;
            else
                obj.SelectedColor = [];
            end
        end       

    end
    
    methods(Access = 'protected')
        function setPeerTitle(obj,v)
            obj.Peer.setTitle(v);            
        end
    end
    
    methods(Access='private')
        function bool = isvalidmultidimensional(~,v)
            sizeofv = size(v);
            occurrencesofthree = find(sizeofv==3);
            if (length(occurrencesofthree)~=1  && prod(sizeofv)~=3)
                bool =false;
            else
                bool = true;
            end
        end
        function color = convert(obj,v)
            if isvalidmultidimensional(obj,v)
                color = [v(1) v(2) v(3)];
            else
                error(message('MATLAB:UiColorChooser:InvalidColorDimension'));
            end
            %Checking range of rgb values
            if ismember(0,((color(:)<=1) & (color(:)>=0)))
                error(message('MATLAB:UiColorChooser:InvalidRGBRange'));
            end
        end
        
    end
end
