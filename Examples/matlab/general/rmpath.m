function oldpath = rmpath(varargin)
%RMPATH Remove folder from search path.
%   RMPATH FOLDERNAME removes the specified folder from the current
%   matlab path.  Surround the FOLDERNAME in quotes if the name contains a
%   space.  If FOLDERNAME is a set of multiple folders separated by path
%   separators, then each of the specified folders will be removed.
%
%   RMPATH FOLDER1 FOLDER2 FOLDER3 removes all the specified folders from
%   the path.
%
%   Use the functional form of RMPATH, such as 
%   RMPATH('folder1','folder2',...), when the folder specification is stored 
%   in a variable or string.
%
%   P = RMPATH(...) returns the path prior to removing the specified paths.
%
%   Examples
%       rmpath c:\matlab\work
%       rmpath /home/user/matlab
%       rmpath /home/user/matlab:/home/user/matlab/test:
%       rmpath /home/user/matlab /home/user/matlab/test
%
%   See also ADDPATH, PATHTOOL, PATH, SAVEPATH, USERPATH, GENPATH, REHASH.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

narginchk(1, Inf);

if nargout>0
    oldpath = path;
end

ps = pathsep;

% Make cell array of MATLABPATH directories
cmdirs = regexp([matlabpath ps],['.[^' ps ']*' ps],'match')';

% Check, trim, and concatenate the input strings
dirs = catdirs(mfilename, varargin{:});

% Convert to clean cells
cdirs = parsedirs(dirs);

% Absolutize input strings
for i=1:length(cdirs)
    try
    if feature('IsPM2.0')
        cdirs{i} = [builtin('_canonicalizepath', cdirs{i}(1:end-1)) pathsep];
    else
        cdirs{i} = [builtin('_canonicalizepath', cdirs{i}(1:end-1), false) pathsep];
    end
    catch
        % Could not absolutize a path and let later code issue a warning
    end
end
    
% Only do case sensitive search on UNIX
if ispc
    cdirsCased = lower(cdirs);
    cmdirsCased = lower(cmdirs);
else
    cdirsCased = cdirs;
    cmdirsCased = cmdirs;
end

% Loop through directories to find out where to remove them
pmatch = false(size(cmdirs));
for n=1:length(cdirsCased)
	pTemp = strcmp(cdirsCased{n},cmdirsCased);
        if ~any(pTemp)
            warning(message('MATLAB:rmpath:DirNotFound', cdirs{ n }( 1:end - 1 )));
        end
	pmatch = pmatch | pTemp;
end

% Remove the directories from the MATLABPATH string, and update the path
if any(pmatch)
	cmdirs(pmatch) = [];
	matlabpath([cmdirs{:}])
end



