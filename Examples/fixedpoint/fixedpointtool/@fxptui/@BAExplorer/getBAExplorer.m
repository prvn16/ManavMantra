function BAExplorer = getBAExplorer
%GETBAEXPLORER Get the bAExplorer.
%   OUT = GETBAEXPLORER(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.

daRoot = DAStudio.Root;
BAExplorer = daRoot.find('-isa', 'fxptui.BAExplorer');
if(~isa(BAExplorer, 'fxptui.BAExplorer'));
	BAExplorer = [];
end

% [EOF]
