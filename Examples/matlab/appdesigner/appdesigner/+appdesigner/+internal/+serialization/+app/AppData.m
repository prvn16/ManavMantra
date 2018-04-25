classdef AppData < handle...
        & appdesigner.internal.serialization.app.AppVersion
   % This class is the object that will be serialized to the mlapp file.
  % It's properties are objects required to load the app back in App
  % Designer
    
  % Copyright 2015 The MathWorks, Inc.
  
    properties
        % the UIFigure component and all its children
        UIFigure
        
        % the code data that includes callbacks, the editable section,
        % class name and startup function
        CodeData
        
        % the metada for the app
        Metadata
    end
    
     methods
        function obj = AppData(uifigure, codedata, metadata)
            % constructor            
            obj.UIFigure = uifigure;
            obj.CodeData = codedata;
            obj.Metadata = metadata;
        end
    end   
    
end

