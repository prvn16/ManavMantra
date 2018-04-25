classdef CodeCoverageCollector < handle
    % CodeCoverageCollector - Interface for code coverage collectors.
    %   The CodeCoverageCollector class is an abstract interface for classes
    %   designed for collecting code coverage.
    %
    %   CodeCoverageCollector properties:
    %       Collecting - Boolean indicating whether the collector is active.
    %       Results    - Code coverage collection results.
    %
    %   CodeCoverageCollector methods:
    %       start        - Start collecting code coverage.
    %       stop         - Stop collecting code coverage.
    %       clearResults - Clear the code coverage collection results.
    
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    properties (Abstract, SetAccess=private)
        % Collecting - Boolean indicating whether the collector is active.
        %   The Collecting property is a Boolean indicating whether this instance
        %   is currently collecting coverage.
        Collecting
        
        % Results - Code coverage collection results.
        %   The Results property is a structure which contains the code coverage
        %   collection results data.
        Results
    end
    
    methods (Abstract)
        % start - Start collecting code coverage.
        start(collector)
        
        % stop - Stop collecting code coverage.
        stop(collector)
        
        % clearResults - Clear the code coverage collection results.
        clearResults(collector)
    end
end

