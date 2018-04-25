classdef Version2Loader < appdesigner.internal.serialization.loader.interface.Loader
    %VERSION2LOADER  A class to load apps in the new format (18a and beyond)
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        FileReader
    end
    
    methods
        
        function obj = Version2Loader(fileReader)
            % constructor
            obj.FileReader = fileReader;
        end
        
        function appData = load(obj)
            % read the App Designer data
            appData = obj.FileReader.readAppDesignerData();
            
            if ( isfield(appData.code,'Callbacks'))
                % restore the ComponentData to each callback
                % (CodeName,CallbackPropertyName,ComponentType)                
                 appData.code.Callbacks = appdesigner.internal.serialization.util.restoreCallbackComponentData(appData.components.UIFigure,appData.code.Callbacks);                 
            end
        end     
    end
end

