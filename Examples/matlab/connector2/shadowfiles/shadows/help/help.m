function varargout = help(varargin)

% Copyright 2010-2016 The MathWorks, Inc.
% disable shadow warnings
warningState = warning('off', 'MATLAB:dispatcher:nameConflict');

% store path, then add the current directory
originalPath = addpath(pwd);

% store pwd, then cd to native help
originalDir = cd(fullfile(matlabroot, 'toolbox','matlab','helptools'));

% call native help
if nargout > 0
    [varargout{1}, varargout{2}] = help(varargin{:});
else
    help(varargin{:});
end

% resotre the original path
path(originalPath);

% cd back, reinstate warning state
cd(originalDir);
warning(warningState);

