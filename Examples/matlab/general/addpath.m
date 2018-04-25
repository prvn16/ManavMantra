function oldpath = addpath(varargin)
%ADDPATH Add folder to search path.
%   ADDPATH FOLDERNAME prepends the specified folder to the current
%   matlabpath.  Surround FOLDERNAME in quotes if the name contains a
%   space.  If FOLDERNAME is a set of multiple folders separated by path
%   separators, then each of the specified folders will be added.
%
%   ADDPATH FOLDERNAME1 FOLDERNAME2 FOLDERNAME3 ...  prepends all the 
%   specified folders to the path.
%
%   ADDPATH ... -END    appends the specified folders.
%   ADDPATH ... -BEGIN  prepends the specified folders.
%   ADDPATH ... -FROZEN disables folder change detection for folders
%                       being added.
%
%   Use the functional form of ADDPATH, such as 
%   ADDPATH('folder1','folder2',...), when the folder specification is 
%   a variable or string.
%
%   P = ADDPATH(...) returns the path prior to adding the specified paths.
%
%   Examples
%       addpath c:\matlab\work
%       addpath /home/user/matlab
%       addpath /home/user/matlab:/home/user/matlab/test:
%       addpath /home/user/matlab /home/user/matlab/test
%
%   See also RMPATH, PATHTOOL, PATH, SAVEPATH, USERPATH, GENPATH, REHASH.

%   Copyright 1984-2017 The MathWorks, Inc.

% Number of  input arguments
n = nargin;
narginchk(1,Inf);
[varargin{:}] = convertStringsToChars(varargin{:});

if nargout>0
    oldpath = path;
end

append = -1;
freeze = 0;
args = varargin;

while (n > 1)   
    last = args{n};
    % Append or prepend to the existing path
    if isequal(last,1) || strcmpi(last,'-end')
        if (append < 0), append = 1; end; 
        n = n - 1;
    elseif isequal(last,0) || strcmpi(last,'-begin')
        if (append < 0), append = 0; end;
        n = n - 1;
    elseif strcmpi(last,'-frozen') 
        freeze = 1;
        n = n - 1;
    else
        break;
    end
end
if (append < 0), append = 0; end

% Check, trim, and concatenate the input strings
p = catdirs(mfilename, varargin{1:n});

% If p is empty then return
if isempty(p)
    return;
elseif ~isempty(strfind(p, char(0)))
    error(message('MATLAB:FileManip:NullCharacterInName'));
end

% See whether frozen is desired, where the state is not already set frozen
if freeze
    if feature('IsPM2.0')
        paths = strsplit(p,pathsep());
        for n = 1:size(paths,2)-1
            feature('DirectoryFreeze',paths{n});
        end
    else
        oldfreeze = system_dependent('DirsAddedFreeze');
        % Check whether old unfrozen state needs to be restored
        if ~isempty(strfind(oldfreeze,'unfrozen'))
            %Use the onCleanup object to automatically restore old state at
            %exit or error.
            cleanUp = onCleanup(@()system_dependent('DirsAddedUnfreeze'));
        end
    end
end

% Append or prepend the new path
mp = matlabpath;
if append
    path(mp, p);
else
    path(p, mp);
end    

