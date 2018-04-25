function warnfiguredialog(functionName)

%   Copyright 2006-2013 The MathWorks, Inc.

% Shows the warning in -nodisplay and -noFigureWindows mode
% Shows the error in -nojvm mode

% (usejava('jvm') will return true in -nodisplay and -noFigureWindows mode,
% but false in -nojvm mode)

% @HACK HACK alert: if you are modifying the warning message, 
% please also modify the same message in the following files:
%  * matlab/toolbox/matlab/uitools/private/warnfiguredialog.m

if ~usejava('jvm')
    error(message('MATLAB:HandleGraphics:noJVM'));
end

% @TODO When we are ready to deprecate dialogs in NoFigureWindows modes
% other than nojvm, use this check to throw errors:
% if feature('NoFigureWindows')


if ~feature('ShowFigureWindows')
    warning(message('MATLAB:hg:NoDisplayNoFigureSupportSeeReleaseNotes', functionName));
end