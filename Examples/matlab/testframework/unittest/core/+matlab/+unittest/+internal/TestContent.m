classdef(Hidden) TestContent < matlab.unittest.internal.Teardownable &  ...
                               matlab.unittest.internal.mixin.Subscribable
    
    %  Copyright 2012-2017 The MathWorks, Inc.
    
    events (NotifyAccess=private)
        % ExceptionThrown - Event triggered when an exception is thrown
        %   The ExceptionThrown event provides a means to observe and react
        %   to when an exception is thrown during test content execution.
        %   Callback functions listening to this event receive information
        %   about the unexpected exception caught in the form of
        %   ExceptionEventData. 
        %
        %   NOTE: The TestRunner must be used to execute the test content
        %   in order for the callback to be triggered.
        %
        %   See also: matlab.unittest.qualifications.ExceptionEventData
        ExceptionThrown
    end
    
    properties(Transient,Access = private)
        ExceptionThrownOnFailureTasks matlab.unittest.internal.Task;
    end
    
    methods (Hidden)          
       function onFailure(testContent, task)
            testContent.ExceptionThrownOnFailureTasks = [testContent.ExceptionThrownOnFailureTasks, task];
        end
    end
    
    methods (Access = ?matlab.unittest.TestRunner)
        function notifyExceptionThrownEvent_(testContent, exception, diagnosticData)
            import matlab.unittest.qualifications.ExceptionEventData;
             
            eventData = ExceptionEventData(exception,diagnosticData,...
                testContent.ExceptionThrownOnFailureTasks.getDefaultQualificationDiagnostics);
            
            % diagnose the onFailureDiagnostics immediately
            eventData.AdditionalDiagnosticResults;
            testContent.notify('ExceptionThrown',eventData);    
        end
    end   
end

% LocalWords:  Teardownable Subscribable
