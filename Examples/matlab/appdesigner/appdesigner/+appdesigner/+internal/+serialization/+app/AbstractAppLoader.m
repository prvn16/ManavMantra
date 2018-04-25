classdef AbstractAppLoader < handle
    %ABSTRACTAPPLOADER Interface for getting a .mlapp file's app data
    %   
    % Copyright 2016 The MathWorks, Inc. 
    
    methods(Abstract)
        % Get a saved app's data
        appData = getAppData(obj, fullFileName)        
    end  
end

