classdef helpviewMOFactory < helpUtils.csh.helpviewFactory
    %HELPVIEWMOFACTORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = helpviewMOFactory()
            obj = obj@helpUtils.csh.helpviewFactory(com.mathworks.mlwidgets.help.motw.csh.MotwHelpTopicUrlRetrieverFactory);
        end
        
        function help_path = checkForMapFile(obj, mapfilename, topic_id)
            % Get the page from the search database using the map file name and 
            % topic id.
            % Get the page from the search database using the map file name and 
                % topic id.
            help_path = obj.get_location_for_mapfile_and_topic(mapfilename, topic_id);
            if isempty(help_path)            
                error('MATLAB:helpview:TopicPathDoesNotExist', '%s',getString(message('MATLAB:helpview:MapFileDoesNotExist', mapfilename)));
            end
        end  
        
        function [help_path, mapkey] = checkForMapKey(~, help_path)
            %%
            help_path = '';
            mapkey = '';
        end
        
        function help_path = convertPath(obj, help_path)
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

