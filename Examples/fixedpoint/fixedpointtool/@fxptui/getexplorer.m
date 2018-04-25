function me = getexplorer(~)
%GETEXPLORER   Get the explorer.

%   Author(s): G. Taillefer
%   Copyright 2006-2016 The MathWorks, Inc.

if ~usejava('jvm')
    % Loading the fxptui.explorer class throws an error if the JVM isn't
    % running.
    me = [];
    return;
end

persistent daRoot;

if isempty(daRoot)
    daRoot = DAStudio.Root;
end

me = daRoot.find('-isa', 'fxptui.explorer');
if ~isa(me, 'fxptui.explorer')
    me = [];
end

end

% [EOF]
