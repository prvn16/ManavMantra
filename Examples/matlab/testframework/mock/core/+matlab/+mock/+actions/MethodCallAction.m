classdef (Hidden) MethodCallAction < matlab.mock.actions.Action
    % This class is undocumented and may change in a future release.
    
    % MethodCallAction - Fundamental interface for mock object method behavior.
    %
    %   The MethodCallAction interface provides a means for specifying
    %   behaviors mock object methods should perform when called.
    %
    %   MethodCallAction methods:
    %       then       - Specify subsequent action
    %       repeat     - Perform the same action multiple times
    %       callMethod - Carry out the method call
    %
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods (Hidden, Abstract)
        % callMethod - Carry out the action for the method.
        %   The mocking framework calls the callMethod method to carry out the
        %   behavior the mock object should implement for the method.
        %
        varargout = callMethod(action, className, methodName, static, varargin);
    end
end

