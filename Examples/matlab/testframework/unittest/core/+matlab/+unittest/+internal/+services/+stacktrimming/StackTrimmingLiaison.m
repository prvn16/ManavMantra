classdef StackTrimmingLiaison < handle    
    % This class is undocumented and will change in a future release.
    
    % StackTrimmingLiaison - Class to handle communication between StackTrimmingServices.
    %
    % See Also: StackTrimmingService, Service, ServiceLocator
    
    % Copyright 2016 The MathWorks, Inc.    
    
    properties
        Stack;
    end
    
    methods
        function liaison = StackTrimmingLiaison(stack)
            liaison.Stack = stack;
        end
        
    end
   
end

