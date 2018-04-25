classdef (Hidden) PropertyGetAction < matlab.mock.actions.Action
    % This class is undocumented and may change in a future release.
    
    % PropertyGetAction - Fundamental interface for mock object property access behavior.
    %
    %   The PropertyGetAction interface provides a means for specifying
    %   behaviors mock objects should perform in response to property accesses.
    %
    %   PropertyGetAction methods:
    %       then        - Specify subsequent action
    %       repeat      - Perform the same action multiple times
    %       getProperty - Carry out the property access
    %
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods (Abstract)
        % getProperty - Carry out the property access
        %   The mocking framework calls the getProperty method to carry out the
        %   behavior the mock object should implement for property access.
        %
        value = getProperty(action, className, propertyName, object);
    end
end

