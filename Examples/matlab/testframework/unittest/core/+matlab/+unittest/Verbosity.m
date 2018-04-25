classdef Verbosity < double
    % Verbosity - Specification of verbosity level.
    %   The matlab.unittest.Verbosity enumeration provides a means to specify
    %   the level of detail related to running tests.
    
    % Copyright 2013-2014 The MathWorks, Inc.
    
    enumeration
        % Terse - A minimal amount of information
        Terse (1)
        
        % Concise - Typical information.
        Concise (2)
        
        % Detailed - Supplemental information.
        Detailed (3)
        
        % Verbose - A surplus of information.
        Verbose (4)
    end
end

