classdef MLAPPDeserializer < handle
    % MLAPPDeserializer   A class that deserializes (loads the app)

    %
    % Copyright 2017 The MathWorks, Inc.
    %
    
    properties (Access = private)
        FileReader;
        Metadata;
        FullFileName;
    end
    
    methods
        
        function obj = MLAPPDeserializer(fullFileName)
            obj.FullFileName = fullFileName;
            obj.FileReader =  appdesigner.internal.serialization.FileReader(fullFileName);
        end
        
        function appData = getAppData(obj)
             % Get app data of an app file
             
            obj.Metadata = obj.getAppMetadata();
                         
            % check if this app is a supported app to open based on its
            % MinimumSupportedMATLABRelease
            import appdesigner.internal.serialization.util.ReleaseUtil;           
            if ( ~ReleaseUtil.isSupportedRelease(obj.Metadata.MinimumSupportedMATLABRelease))
                error(message('MATLAB:appdesigner:appdesigner:IncompatibleAppVersion'));
            end
                       
            % instantiate a factory to create the loader
            factory = appdesigner.internal.serialization.loader.AppLoaderFactory();
            loader = factory.createLoader(obj.FileReader, obj.Metadata.MATLABRelease, obj.Metadata.MLAPPVersion );
            
            % load the data
            appData = loader.load();
                        
            % store the UIfigure and children components so they can be
            % reused on load.  The key is its fullFilename, the data to be
            % stored is the UIFigure
            componentProvider = appdesigner.internal.serialization.util.ComponentProvider.instance();
            componentProvider.setUIFigure(obj.FullFileName,appData.components.UIFigure);
        end
        
        
        function appMetadata = getAppMetadata(obj)
            % Get app metadata of an app file
            
            if ( ~isempty(obj.Metadata ))
                appMetadata = obj.Metadata;
            else
                try                    
                    % Load data from the App file
                    appMetadata = readAppMetadata(obj.FileReader);
                catch me
                    % Rethrow the exception because FileReader provides appropriate error messages
                    rethrow(me);
                end
            end
        end
       
    end
end