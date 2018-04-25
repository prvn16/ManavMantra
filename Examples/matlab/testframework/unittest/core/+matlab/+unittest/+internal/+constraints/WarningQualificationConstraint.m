classdef(Hidden) WarningQualificationConstraint < matlab.unittest.internal.constraints.FunctionHandleConstraint & ...
                                                  matlab.unittest.internal.mixin.WhenNargoutIsMixin
    % This class is undocumented and may change in a future release.
    
    % Internal only class which interacts with the warning log in order to test
    % for expected warnings
    %
    
    % Copyright 2011-2017 The MathWorks, Inc.
    
    properties(SetAccess=private)
        % FunctionOutputs - Cell array of outputs produced when invoking the supplied function handle
        %
        %   The FunctionOutputs property contains a cell array of output
        %   arguments that are produced when the supplied function handle
        %   is invoked. The number of outputs is determined by the Nargout
        %   property.
        %
        %   This property is read only and is set when the function handle
        %   is invoked.
        FunctionOutputs = cell(1,0);
    end
    
    properties(Hidden, SetAccess=private,GetAccess=protected)
        HasIssuedSomeWarnings
    end
    
    methods(Abstract,Hidden, Access=protected)
        processWarnings(constraint, actualWarningsIssued)
    end
    
    methods(Hidden, Access=protected)
        function invoke(constraint, fcn)
            % Invoke the function in such a way as to capture issued warnings.
            
            import matlab.unittest.internal.constraints.WarningLogger;
            
            logger = WarningLogger;
            logger.start();
            [constraint.FunctionOutputs{1:constraint.Nargout}] = ...
                constraint.invoke@matlab.unittest.internal.constraints.FunctionHandleConstraint(fcn);
            logger.stop();
            
            actualWarningsIssued = logger.Warnings;
            constraint.HasIssuedSomeWarnings = ~isempty(actualWarningsIssued);
            constraint.processWarnings(actualWarningsIssued);
        end
    end
    
end

