classdef GraderPlugin < connector.internal.academy.plugins.TestIndexPlugin
    
    properties  
        submissionCode
        solutionCode
        
        exceptionObject
        postExerciseVariables  
        codeOutput
        hint
    end
    
    methods(Access=public)
        
        function obj = GraderPlugin(submissionCode,solutionCode)
            obj.submissionCode = submissionCode;
            obj.solutionCode = solutionCode;
        end
        
        function obj = reset(obj)          
            obj.exceptionObject = MException('','');
            obj.postExerciseVariables = [];
            obj.hint = '';
        end
        
        function [yesNo,numCalls] = codeCalls(obj,fcnName)
            import connector.internal.academy.graders.*;
            [yesNo,numCalls] = GraderUtils.codeCalls(obj.submissionCode,fcnName);
        end
        
        function yesNo = someVarEquals(obj,var)
            import connector.internal.academy.graders.*;
            yesNo = GraderUtils.isVariableInWorkspace(obj.postExerciseVariables,var);
        end
        
        function fcnNames = getUserDefinedFunctionNames(obj)
            import connector.internal.academy.graders.*;
            fcnNames = GraderUtils.getNamesOfDefinedFunctions(obj.submissionCode);
        end
        
        function setAutomaticHint(obj,hint)
            obj.hint = hint;
        end
        
    end
    
    methods(Access=protected)
                
        function tc = createTestClassInstance(plugin, pluginData)
            plugin.reset;
            tc = createTestClassInstance@connector.internal.academy.plugins.TestIndexPlugin(plugin, pluginData);
            
            %tc.addlistener('ExceptionThrown', @plugin.captureException);
        end
        
        function tc = createTestMethodInstance(plugin, pluginData)              
            tc = createTestMethodInstance@connector.internal.academy.plugins.TestIndexPlugin(plugin, pluginData);
            plugin.postExerciseVariables = tc.TestData.sharedVariables;
            plugin.codeOutput = tc.TestData.codeOutput;
            plugin.exceptionObject = tc.TestData.exceptionObject;
            tc.TestData.sharedVariables.grader = plugin;
            
            %TODO: work with unit test framework to capture exception object more
            %gracefully
        end
        
    end
    
    methods(Access=private)
        
        function captureException(plugin, ~, eventData)
            %This currently is not supported :-(  The tests just stop if an
            %exception is thrown during test class setup.
            %plugin.exceptionObject = eventData.Exception;
        end
        
    end
    
end

