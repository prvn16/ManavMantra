classdef (Hidden) PropertySetAction < matlab.mock.actions.Action
    % This class is undocumented and may change in a future release.
    
    % PropertySetAction - Fundamental interface for mock object property set behavior.
    %
    %   The PropertySetAction interface provides a means for specifying
    %   behaviors mock objects should perform in response to property sets.
    %
    %   PropertySetAction methods:
    %       then        - Specify subsequent action
    %       repeat      - Perform the same action multiple times
    %       setProperty - Carry out the property set
    %
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods (Abstract)
        % setProperty - Carry out the property set
        %   The mocking framework calls the setProperty method to carry out the
        %   behavior the mock object should implement for the property set.
        %
        setProperty(action, className, propertyName, object, value);
    end
end

