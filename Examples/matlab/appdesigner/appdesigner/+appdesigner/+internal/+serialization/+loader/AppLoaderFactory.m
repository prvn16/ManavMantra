classdef AppLoaderFactory < handle
    %APPLOADERFACTORY A factory to instantiate the correct loaders based on
    %the version of the app being loaded
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        
        function loader = createLoader(~,fileReader,matlabReleaseOfApp, mlappVersion)
            % matlabReleaseOfApp is R2016a, R2016b, etc
            % mlappVersion is 1 if the app is in the old serialization
            % format or 2 if its in the new format
            import appdesigner.internal.serialization.util.*;
            
            if (strcmp(mlappVersion,'1'))
                % the app is an MLAPP Version 1 app meaning its 16a-17b or
                % 18a apps that were created before the new format was
                % submitted
                
                % the Version1Loader will read the data in the old format
                % and upgrade the data to the new format
                loader = appdesigner.internal.serialization.loader.Version1Loader(fileReader);
                
                if ( ReleaseUtil.is16aRelease(matlabReleaseOfApp))
                    % remove the SerializationID property from the components if one exists
                    loader = appdesigner.internal.serialization.loader.SerializationIdRemover(loader);
                    
                    % add a pixel to the postion of each component
                    loader = appdesigner.internal.serialization.loader.PositionAdjuster(loader);
                    
                elseif ( ReleaseUtil.is16bRelease(matlabReleaseOfApp))
                    % The SerializationIDRemover will remove the
                    % SerializationId property from each component if it exists
                    loader = appdesigner.internal.serialization.loader.SerializationIdRemover(loader);
                end
                
            elseif (strcmp(mlappVersion,'2'))
                % mlapp Version 2 means its an 18a app or greater
                
                % the Version2Loader will read the data in the new format
                loader = appdesigner.internal.serialization.loader.Version2Loader(fileReader);
                
                if (ReleaseUtil.isLaterThanCurrentRelease(matlabReleaseOfApp))
                    % forwards compatibility
                    
                    % The UnsupportedComponentRemover will loop over the
                    % components and remove those that are unknown to the
                    % release
                    loader = appdesigner.internal.serialization.loader.UnsupportedComponentRemover(loader);
                    
                    % The UnsupportedCallbackRemover will make callbacks
                    % orphan if its component data points to unknown
                    % components or unknown callback property
                    loader = appdesigner.internal.serialization.loader.UnsupportedCallbackRemover(loader);
                end
            else
                error(message('MATLAB:appdesigner:appdesigner:IncompatibleAppVersion'));
            end
            
        end
    end
end
