classdef AppMetadata < handle
   % This class holds metadata for the app.  It is serialized as part of the
  % AppData object
  
  % Copyright 2015 The MathWorks, Inc.
    
    properties
        % the GroupHierarchy structure
        GroupHierarchy
    end
    
     methods
        function obj = AppMetadata(groupHierarchy)
            % constructor            
            obj.GroupHierarchy = groupHierarchy;
        end
    end   
    
end