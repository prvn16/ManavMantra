function pathtool
%PATHTOOL Open Set Path dialog box to view and change search path
%   PATHTOOL opens the MATLAB Set Path tool, which allows you to view,
%   manipulate, and save the MATLAB search path.
%
%   See also PATH, ADDPATH, RMPATH, SAVEPATH.

%   Copyright 1984-2016 The MathWorks, Inc.

% Make sure that we can support the Path tool on this platform.
error(javachk('swing', mfilename));

try
    % Launch Java Path Browser
    com.mathworks.pathtool.PathToolLauncher.invoke;
catch
    error(message('MATLAB:pathtool:PathtoolFailed'));
end
