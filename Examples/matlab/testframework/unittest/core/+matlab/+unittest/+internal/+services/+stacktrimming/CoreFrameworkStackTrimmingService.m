classdef CoreFrameworkStackTrimmingService < matlab.unittest.internal.services.stacktrimming.StackTrimmingService
    % This class is undocumented and will change in a future release.
    
    % CoreFrameworkStackTrimmingService - Trims core framework stack frames.
    %
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods (Access = protected)
        function trimStackStart(~, liaison)
            import matlab.unittest.internal.isQualifyingPluginInFrameworkFolder;
            
            files = {liaison.Stack.file};
            frameworkFolder = matlab.unittest.internal.getFrameworkFolder;
            testContentFrames = ~strncmp(files, frameworkFolder, numel(frameworkFolder)) | ...
                isQualifyingPluginInFrameworkFolder(files);
            firstTestContentFrame = find(testContentFrames,1);
            if isempty(firstTestContentFrame)
                liaison.Stack(:) = [];
            else
                liaison.Stack(1:firstTestContentFrame-1) = [];
            end
        end
        
        function trimStackEnd(~, liaison)
            import matlab.unittest.internal.isQualifyingPluginInFrameworkFolder;
            
            % Trim the end of the stack. This means trimming all stack frames that are
            % below the first call to TestRunner.evaluateMethodCore and any framework
            % stack frames immediately above that. The evaluateMethodCore contract is
            % that it will tightly wrap all test content. Then we simply need to remove
            % internal wrappers such as runTeardown and FunctionTestCase after the
            % first evaluateMethodCore call. Also, confirm that is it the framework's
            % TestRunner.evaluateMethodCore and not another class named TestRunner with
            % a method named evaluateMethodCore.
            names = {liaison.Stack.name};
            evaluateMethodIndices = find(strcmp(names, 'TestRunner.evaluateMethodCore'));
            
            frameworkFolder = matlab.unittest.internal.getFrameworkFolder;
            
            % Match a TestRunner file with any extension
            testRunnerLocation = fullfile(frameworkFolder,'unittest','core','+matlab','+unittest','TestRunner.');
            runnerLocationLength = numel(testRunnerLocation);
            
            for idx = fliplr(evaluateMethodIndices)
                if strncmp(liaison.Stack(idx).file, testRunnerLocation, runnerLocationLength)
                    liaison.Stack(idx:end) = [];
                    break;
                end
            end
            
            files = {liaison.Stack.file};
            testContentFrames = ~strncmp(files, frameworkFolder, numel(frameworkFolder)) | ...
                isQualifyingPluginInFrameworkFolder(files);
            lastTestContentFrame = find(testContentFrames,1,'last');
            if isempty(lastTestContentFrame)
                liaison.Stack(:) = [];
            else
                liaison.Stack(lastTestContentFrame+1:end) = [];
            end
            
            % Trim the stack for qualifications that occur inside of plugins. The
            % contract is that TestRunnerPlugin.invokeTestContentOperatorMethod_
            % tightly wraps all plugin method calls.
            names = {liaison.Stack.name};
            files = {liaison.Stack.file};
            idx = find(strcmp(names, 'TestRunnerPlugin.invokeTestContentOperatorMethod_') & ...
                strncmp(files, frameworkFolder, numel(frameworkFolder)), 1, 'first');
            if ~isempty(idx)
                liaison.Stack = liaison.Stack(1:idx-1);
            end
        end
    end
end