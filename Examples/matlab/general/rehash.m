%REHASH  Refresh function and file system caches.
%   REHASH with no inputs performs the same refresh operations that are done
%   each time the MATLAB prompt is displayed. In other words, for any folder 
%   on the search path that is not in matlabroot, MATLAB updates the list 
%   of known files, revises the list of known classes, and checks the 
%   timestamps of loaded functions against the timestamps of the files on disk.
%   The only time one should need to use this form is when writing out files 
%   programmatically and expecting MATLAB to find them before reaching the 
%   next MATLAB prompt.
% 
%   REHASH PATH is the same as REHASH except that it unconditionally updates
%   the list of known files and classes for all folders on the search path 
%   that are not in matlabroot. Use this form only if you receive a warning 
%   during MATLAB startup notifying you that MATLAB could not tell if a folder 
%   has changed, and you encounter problems with MATLAB not using the most
%   current versions of your program files. 
%
%   REHASH TOOLBOX is the same as REHASH PATH except it updates the list of 
%   known files and classes for all folders on the search path, including 
%   those in matlabroot. Use this form when you change, add, or remove files
%   in matlabroot during a session. Typically, you should not make changes
%   to files and folders in matlabroot.
%
%   REHASH TOOLBOXCACHE is the same as REHASH TOOLBOX, and also updates the
%   cache file on disk.
%
%   See also PATH, ADDPATH, RMPATH, SAVEPATH, MATLABROOT.

%   Copyright 1984-2018 The MathWorks, Inc.

%   Built-in function.
