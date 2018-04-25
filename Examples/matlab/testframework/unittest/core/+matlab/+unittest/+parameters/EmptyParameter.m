classdef EmptyParameter < matlab.unittest.parameters.Parameter
    % EmptyParameter - A concrete Parameter implementation.
    %
    %   The matlab.unittest.parameters.EmptyParameter class is a Parameter
    %   implementation which provides no parameter information. There is no
    %   need for users to interact with this Parameter directly.
    
    % Copyright 2013 The MathWorks, Inc.
    
    
    methods (Hidden, Static)
        function params = getParameters(~)
            params = {};
        end
        
        function param = fromName(~,~,~)
            param = matlab.unittest.parameters.EmptyParameter;
        end
    end
end