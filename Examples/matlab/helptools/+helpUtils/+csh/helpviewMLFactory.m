classdef helpviewMLFactory < helpUtils.csh.helpviewFactory
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    %   Copyright 2017 The MathWorks, Inc.
    
    properties
    end
    
    methods
        function obj = helpviewMLFactory()
            obj = obj@helpUtils.csh.helpviewFactory(com.mathworks.mlwidgets.help.MLHelpTopicUrlRetrieverFactory);
        end
        
        function help_path = checkForMapFile(obj, mapfilename, topic_id)
            import com.mathworks.mlwidgets.help.CSHelpTopicMap;
            % Get topic map.
            topicMap = CSHelpTopicMap(mapfilename);
            
            if (topicMap.exists())  
                % Look up topic or collection path in the map file.
                help_path = char(topicMap.mapID(topic_id));  
            else
                % Get the page from the search database using the map file name and 
                % topic id.
                help_path = obj.get_location_for_mapfile_and_topic(mapfilename, topic_id);
                if isempty(help_path)            
                    error('MATLAB:helpview:TopicPathDoesNotExist', '%s',getString(message('MATLAB:helpview:MapFileDoesNotExist', mapfilename)));
                end
            end

            % Make sure the topic_id exists.
            if isempty(help_path)
                error('MATLAB:helpview:TopicPathDoesNotExist', '%s', getString(message('MATLAB:helpview:TopicIdDoesNotExist',topic_id, mapfilename)));
            end
        end
        
        function [help_path, mapkey] = checkForMapKey(~, help_path)
            import com.mathworks.mlwidgets.help.TopicMapLocator;
            mapkey = help_path(8:length(help_path));
            help_path = char(TopicMapLocator.getMapPath(mapkey));
        end    
        
        function help_path = convertPath(obj, help_path)
            import com.mathworks.mlwidgets.help.HelpPrefs;
            docLocation = HelpPrefs.getDocCenterLocationSilently();
            if (strcmp(docLocation, 'INSTALLED'))
                % We're viewing installed documentation.
                % Verify that the file exists and is not a directory.
                if (~obj.file_exists(help_path))
                    error(message('MATLAB:helpview:InvalidPathArg'));
                end
            elseif (strcmp(docLocation, 'WEB'))
                % We're viewing web documentation. 
                % Convert the file to a web location and verify that it was 
                % converted to something.
                web_path = obj.get_web_path(help_path);
                if (isempty(web_path))
                    error(message('MATLAB:helpview:FileCouldNotBeConverted',help_path));
                else
                    help_path = web_path;
                end
            end
        end        
    end
    
end

