classdef ComponentProvider < handle
    % COMPONENTPROVIDER Singleton object to store the components so that
    % they can be reused on load of an app
    %
    % Copyright 2017 The MathWorks, Inc.
    %
    
    properties (Access = private)
        % A map to maintain the mapping relationship between full file
        % name of the app and the UIFigure
        LoadedAppData;
    end
    
    methods(Access = private)
        % Private constructor to prevent creating object externally
        function obj = ComponentProvider()
            obj.LoadedAppData = containers.Map();
        end
    end
    
    methods(Static)
        % Get singleton instance of the ComponentProvider
        function obj = instance()
            persistent localUniqueInstance;
            if isempty(localUniqueInstance) || ~isvalid(localUniqueInstance)
                obj = appdesigner.internal.serialization.util.ComponentProvider();
                localUniqueInstance = obj;
            else
                obj = localUniqueInstance;
            end
        end
    end
    
    methods
        function uifigure = getUIFigure(obj, fullFileName)
            % Get the UIFigure of the app, given its fullFileName

            uifigure = [];
            if obj.LoadedAppData.isKey(fullFileName)
                % App data is already loaded, just retrieve it
                uifigure = obj.LoadedAppData(fullFileName);
                
                % After retrieving, removing from the map because the app is
                % loaded into App Designer successfully. 
                obj.LoadedAppData.remove(fullFileName);
            end
        end
        
        function setUIFigure(obj,fullFileName,uifigure)
            % set the UIFigure
            obj.LoadedAppData(fullFileName) = uifigure;
        end
                
    end
end
