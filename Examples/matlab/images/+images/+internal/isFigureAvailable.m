function tf = isFigureAvailable
% This undocumented function may be removed in a future release.

% ISFIGUREAVAILABLE determines if figure windows can be created in the
% running instance of MATLAB.

%   Copyright 2010-2014 The MathWorks, Inc.

if feature('showFigureWindows')
    tf = true;
else
    tf = false;
end
