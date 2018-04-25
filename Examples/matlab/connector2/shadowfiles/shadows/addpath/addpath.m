function varargout = addpath(varargin)
%ADDPATH Add directory to search path.
%   ADDPATH DIRNAME prepends the specified directory to the current
%   matlabpath.  Surround the DIRNAME in quotes if the name contains a
%   space.  If DIRNAME is a set of multiple directories separated by path
%   separators, then each of the specified directories will be added.
%
%   ADDPATH DIR1 DIR2 DIR3 ...  prepends all the specified directories to
%   the path.
%
%   ADDPATH ... -END    appends the specified directories.
%   ADDPATH ... -BEGIN  prepends the specified directories.
%   ADDPATH ... -FROZEN disables directory change detection for directories
%                       being added and thereby conserves Windows change
%                       notification resources (Windows only).
%
%   Use the functional form of ADDPATH, such as ADDPATH('dir1','dir2',...),
%   when the directory specification is stored in a string.
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

%   Copyright 1984-2011 The MathWorks, Inc.
%   $Revision: 1.29.4.12 $  $Date: 2011/09/03 22:39:34 $

% call native addpath
persistent native_addpath;
if ~isa(native_addpath, 'function_handle')
    originalDir = cd(fullfile(matlabroot, 'toolbox','matlab','general'));
    native_addpath = @addpath;
    cd(originalDir);
end


if nargout > 0
    [warnings, varargout] = evalc('{native_addpath(varargin{:})}');
else
    warnings = evalc('native_addpath(varargin{:})');
end

%get MATLAB server root
serverroot = getappdata(0, 'MATLAB_SERVER_ROOT');

%split into individual warnings and extract function names
[splitWarnings,func,uniqueFunc] = connector.internal.splitWarningsGetUniqueFunc(warnings);

%number of unique functions
size = length(uniqueFunc);

for i = 1 : size
    %get one function name
    funcName = uniqueFunc{i};
    
	%execute which -all on the function  name
	result = which(funcName,'-all');
    
    %modify the warnings according to which -all output
	[splitWarnings, func] =  connector.internal.getIndexServerRootAndModifyWarnings(...
        funcName, result, serverroot, splitWarnings, func);
end

%Join remaining warnings and display it
warningsJoined = strjoin(splitWarnings);
disp(warningsJoined);  
