classdef AppVersion < handle
    % This class contains a property for version info
    
    % Copyright 2015-2016 The MathWorks, Inc.
    
    properties
        ToolboxVer = version('-release');
        FullVersion = version;
        MinimumSupportedVersion = 'R2016a';
    end
    
end
