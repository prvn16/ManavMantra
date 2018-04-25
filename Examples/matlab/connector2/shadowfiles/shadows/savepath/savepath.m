function notsaved = savepath(outputfile)
%SAVEPATH Save the current MATLAB path in the pathdef.m file.
%   SAVEPATH saves the current MATLABPATH in the pathdef.m
%   which was read on startup.
%
%   SAVEPATH outputFile saves the current MATLABPATH in the
%   specified file.
%
%   SAVEPATH returns:
%     0 if the file was saved successfully
%     1 if the file could not be saved
% 
%   See also PATHDEF, ADDPATH, RMPATH, USERPATH, PATH, PATHTOOL.

%   Copyright 1984-2017 The MathWorks, Inc.

    % grab the default savepath
    persistent native_savepath;
    if ~isa(native_savepath, 'function_handle')
	    originalDir = cd(fullfile(matlabroot, 'toolbox','matlab','general'));
        native_savepath = @savepath;
        cd(originalDir);
    end

    % In MATLAB Online, we shadow savepath to make the default call 
    % use the prefdir as the default place to save, not the existing 
    % pathdef on the top of the path.
    if nargin == 0
        outputfile = fullfile(prefdir, 'pathdef.m');
    end

    % run the regular savepath command
    notsaved = native_savepath(outputfile);

end
    
