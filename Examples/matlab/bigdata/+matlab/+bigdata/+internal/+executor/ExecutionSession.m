%ExecutionSession
% Helper class that allows execution to span multiple calls to gather.
%
% This exists for iterative algorithms which require to gather in a loop in
% order to check for convergence.

%   Copyright 2016-2017 The MathWorks, Inc.

classdef ExecutionSession < handle
    properties (SetAccess = immutable)
        % The ProgressReporter object created for this session. This does
        % progress reporting that spans multiple gather statements.
        SessionProgressReporter = [];
        
        % The old value of the ProgressReporter override.
        OldProgressReporter;
    end
    
    methods
        % The main constructor.
        %
        % This has the same syntax as:
        %   matlab.bigdata.internal.startMultiExecution.
        function obj = ExecutionSession(varargin)
            import matlab.bigdata.internal.executor.ProgressReporter;
            import matlab.bigdata.internal.executor.MultiExecutionProgressReporter;
            import matlab.bigdata.internal.executor.OutputFunctionProgressReporter;
            
            p = inputParser;
            p.addParameter('OutputFunction', []);
            p.addParameter('PrintBasicInformation', true);
            p.addParameter('TotalNumTasks', NaN);
            p.addParameter('TotalNumPasses', NaN);
            p.addParameter('CombineMultiProgress', true);
            p.parse(varargin{:});
            
            obj.OldProgressReporter = ProgressReporter.override();
            if isa(obj.OldProgressReporter, 'matlab.bigdata.internal.executor.MultiExecutionProgressReporter')
                % This indicates another session is already open, this
                % should never be hit. We avoid overriding instances of
                % this class to avoid clashes with other sessions in stack
                % frames above ours.
                return;
            end
                
            if isempty(p.Results.OutputFunction)
                progressReporter = ProgressReporter.getCurrent();
            else
                progressReporter = OutputFunctionProgressReporter(p.Results.OutputFunction, p.Results.PrintBasicInformation);
            end
            
            if p.Results.CombineMultiProgress
                obj.SessionProgressReporter = MultiExecutionProgressReporter(progressReporter, ...
                    p.Results.TotalNumTasks, p.Results.TotalNumPasses);
            else
                obj.SessionProgressReporter = progressReporter;
            end
            ProgressReporter.override(obj.SessionProgressReporter);
        end
        
        % End this execution session, printing the final progress output.
        function endMultiExecution(obj)
            obj.doCleanup();
        end
        
        function delete(obj)
            obj.doCleanup();
        end
    end
    
    methods (Access = private)
        % Cleanup the side-effects of this class if this has not already
        % been done so.
        function doCleanup(obj)
            import matlab.bigdata.internal.executor.ProgressReporter;
            if ~isempty(obj.SessionProgressReporter)
                ProgressReporter.override(obj.OldProgressReporter);
            end
        end
    end
end
