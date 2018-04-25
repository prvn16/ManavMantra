classdef MlappUtils
    %MLAPPUTILS Support for working with .mlapp files in Toolbox Packaging.
    
    properties
    end
    
    methods(Static)
        function java_hash_map = getMlappMetaData(mlappFile)
            if( exist( mlappFile, 'file' ) == 0 )
                java_hash_map = java.util.HashMap();
            else
                try
                    deserializer = appdesigner.internal.serialization.MLAPPDeserializer(mlappFile);
                    appData = deserializer.getAppMetadata(); 
                    java_hash_map = matlab.ui.internal.toolstrip.base.Utility.convertFromStructureToHashmap(appData);
                catch
                    % Swallow any errors thrown from reading the mlapp
                    % metadata and instead exclude it
                    java_hash_map = java.util.HashMap();
                end
            end
        end
    end
    
end

