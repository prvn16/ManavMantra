classdef NamingConventionLiaison < handle
    % This class is undocumented and will change in a future release.
    
    % NamingConventionLiaison - Class to handle communication between NamingConventionServices.
    %
    % See Also: NamingConventionService
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % SimpleParentName - Name of the test content without any package prefixes.
        SimpleParentName;
    end
    
    properties
        % MeetsConvention - Boolean indicating whether the naming convention is met.
        MeetsConvention = false;
    end
    
    methods
        function liaison = NamingConventionLiaison(simpleParentName)
            liaison.SimpleParentName = simpleParentName;
        end
    end
end

