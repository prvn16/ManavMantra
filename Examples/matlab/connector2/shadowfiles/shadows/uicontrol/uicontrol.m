function out=uicontrol(varargin)
% Copyright 2010 The MathWorks, Inc.

    if length(dbstack)>1
       % store pwd, then cd to native publish
       originalDir = cd(fullfile(matlabroot, 'toolbox','matlab','graphics'));
       warningState = 1;

       % on function exit, run cleanup
       c = onCleanup(@()cleanup(originalDir, warningState));

       out=uicontrol(varargin{:});
    else
        nse = connector.internal.notSupportedError;
        nse.throwAsCaller;
    end
end

% cleanup the current directory and path
function cleanup(originalDir, warningState)
cd(originalDir);
%warning(warningState);
end
