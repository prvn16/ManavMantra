function bool = isInteractiveContext(stack)
% This function is undocumented.

% An interactive context is defined as any context where the TestRunner is
% not being used.

%  Copyright 2015-2016 MathWorks, Inc.

bool = ~any(strcmp({stack.file}, which('matlab.unittest.TestRunner')));
end

