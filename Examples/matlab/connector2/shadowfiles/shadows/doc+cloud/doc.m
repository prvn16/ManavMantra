function doc(varargin)
% Copyright 2010-2016 The MathWorks, Inc.
% disable shadow warnings
    warningState = warning('off', 'MATLAB:dispatcher:nameConflict');
    
    % store path, then add the current directory
    originalPath = addpath(pwd);

    % store pwd, then cd to native help
    originalDir = cd(fullfile(matlabroot, 'toolbox','matlab','helptools'));

    % call native doc
    doc(varargin{:});

    % resotre the original path
    path(originalPath);

    % cd back, reinstate warning state
    cd(originalDir);
    warning(warningState);
end