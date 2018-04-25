classdef (Abstract) helpviewFactory
    %HELPVIEWFACTORYPROVIDER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = protected)
        factory
    end
    
    methods
        
        function obj = helpviewFactory(factoryImpl)
            obj.factory = factoryImpl;
        end
        
        %% --------------------------------------------------------------------------
        function help_path = get_location_for_mapkey_and_topic(obj, map_key, topic_id)
            % Get the path from the search database using the map key and topic id.
            try
                retriever = obj.factory.buildGlobalRetriever(map_key); 
                help_path = obj.get_location_for_topic(retriever, topic_id);
            catch
                help_path = '';
            end
        end

        %% --------------------------------------------------------------------------

        function help_path = get_location_for_mapfile_and_topic(obj, map_filename, topic_id)
            % Get the path from the search database using the map file name and topic 
            % id.
            try
                retriever = obj.factory.buildMapFileRetriever(map_filename); 
                help_path = obj.get_location_for_topic(retriever, topic_id);
            catch
                help_path = '';
            end
        end

        %% --------------------------------------------------------------------------

        function help_path = get_location_for_shortname_and_topic(obj, short_name, topic_id)
            % Get the path from the search database using the short name and topic id.
            try
                retriever = obj.factory.buildDocSetItemRetriever(short_name); 
                help_path = obj.get_location_for_topic(retriever, topic_id);
            catch
                help_path = '';
            end
        end
        
        %% --------------------------------------------------------------------------
        function help_path = get_location_for_topic(~, retriever, topic_id)
            help_path = char(retriever.getLocationForTopic(topic_id));
        end
        
        %% --------------------------------------------------------------------------

        function file_path_exists = file_exists(~, file_path)
            try
                file_path_exists = com.mathworks.mlwidgets.help.HelpViewUtils.fileExists(file_path);
            catch
                file_path_exists = false;
            end
        end
        
        %% --------------------------------------------------------------------------
        
        function web_path = get_web_path(~, path)
            try
                web_path = char(com.mathworks.mlwidgets.help.HelpViewUtils.getWebPath(path));
            catch
                web_path = '';
            end
        end
    end
    
    methods(Abstract, Access=public)
        [help_path, mapkey] = checkForMapKey(help_path)
        help_path = checkForMapFile(mapfilename, topic_id)
        help_path = convertPath(help_path)
    end
    
end

