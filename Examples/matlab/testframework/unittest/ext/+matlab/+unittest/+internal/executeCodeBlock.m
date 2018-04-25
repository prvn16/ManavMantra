function executeCodeBlock(scriptName,sectionStartIndex,sectionLength)
% This function is undocumented and may change in a future release.

% Note: Calls to this function are set by the TestScriptFileModel and
% placed on to the ScriptTestCaseProvider starting in R2017b. Since
% ScriptTestCaseProvider is serialized, this function is required to allow
% script based test suites from R2016b and after to be loaded from a MAT
% file.

%  Copyright 2017 The MathWorks, Inc.
builtin('_ExecuteCodeBlockInternal','caller',scriptName,sectionStartIndex,sectionLength);
end