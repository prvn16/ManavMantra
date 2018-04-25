function checkSyntacticWarnings(varargin)
%checkSyntacticWarnings Check MATLAB files for compile errors.
%   Check all MATLAB files in the directories specified by the argument
%   list for errors that MATLAB generates when reading the files into
%   memory. All @class and private directories contained by the argument
%   list directories will also be processed; class and private directories
%   need not and should not be supplied as explicit arguments to this
%   function.
%
%   If no argument list is specified, all files on the MATLAB path 
%   (excluding toolboxes) and in the current working directory will be 
%   checked.
%
%   If the argument list is exactly '-toolboxes', all files on the MATLAB 
%   path and in the current working directory will be checked, including 
%   those in toolboxes.
%
%   See also PRECEDENCE.

%   Copyright 1984-2016 The MathWorks, Inc.

args = varargin;
for i = 1:nargin
    currArg = varargin{i};
    if ischar(currArg) && isrow(currArg) && ~isempty(currArg)
        args{i} = string(currArg);
    elseif ~isstring(currArg) || ~isscalar(currArg) || strlength(currArg) == 0
        error(message('MATLAB:checkSyntacticWarnings:MustBeStringScalarOrCharacterVector'));
    elseif ismissing(currArg)
        error(message('MATLAB:checkSyntacticWarnings:MissingArgument', ...
                      getString(message('MATLAB:string:MissingDisplayText'))));
    end
end

% Gather up the list of directories and MATLAB files.
[w, wc, wp] = checkDirlist(args{:});

% Process MATLAB files on the path.
checkPrecedence(w, true);

% Process methods.
checkPrecedence(wc, false);

% Process private MATLAB files and private methods.
checkPrecedence(wp, false);

disp(getString(message('MATLAB:checkSyntacticWarnings:Finished')));

end
%---------------------------------------------
function [wm, wcm, wpm] = checkDirlist(varargin)

if ~isempty(varargin) && (numel(varargin) > 1 || varargin{1} ~= "-toolboxes")
    % Use supplied argument list.
    dirList = vertcat(varargin{:});
    
    % Get rid of leading and trailing cruft.
    dirList = strip(dirList);
    dirList = replace(dirList, '/', filesep);
    dirList = strip(dirList, 'right', filesep);
else
    dirList = [pwd; split(matlabpath, pathsep)];
    if isempty(varargin)
        % Do not check toolbox folders.
        toolboxRoot = string(toolboxdir(filesep));
        dirList(dirList.startsWith(toolboxRoot)) = [];
    end
end

% Collect and normalize path directory contents.
w = [];
for i = 1:numel(dirList)
  w = [w; what(dirList{i})]; %#ok<AGROW>
end
[~, keep] = unique({w.path}, 'stable');
w = w(keep);

% Add classes and private directories.
wc = [];
wp = [];
for i = 1:numel(w)
    for j = 1:numel(w(i).classes)
        wc = [wc; what(fullfile(w(i).path,['@',w(i).classes{j}]))]; %#ok<AGROW>
    end
    wp = [wp; what(fullfile(w(i).path, 'private'))]; %#ok<AGROW>
end

% Add private method directories.
for i = 1:numel(wc)
    wp = [wp; what(fullfile(wc(i).path, 'private'))]; %#ok<AGROW>
end

% Release information concerned only with mex, models,
% mat files, etc., and generate output values.
wm = extractPathAndFiles(w);
wcm = extractPathAndFiles(wc);
wpm = extractPathAndFiles(wp);

end
%---------------------------------------------
function s = extractPathAndFiles(w)

if isempty(w)
    s = [];
else
    s.path = string({w.path}');
    s.m = cellfun(@string, {w.m}', 'UniformOutput', false);
end

end
%---------------------------------------------
function checkPrecedence(w, isPath)

if isempty(w)
    return;
end

for i = 1:numel(w.path)
    disp([getString(message('MATLAB:checkSyntacticWarnings:Checking', char(w.path(i)))), newline]);
    mlist = w.m{i};
    
    if isPath
        pathCleanup = putOnPath(w.path(i)); %#ok<NASGU>
    end
    
    for j = 1:numel(mlist)
        checkFilePrecedence(w.path(i) + filesep + mlist(j));
    end
end

end
%---------------------------------------------
function cleanupObj = putOnPath(pathname)

if contains([pathsep, matlabpath, pathsep], pathsep + pathname + pathsep)
    cleanupObj = onCleanup.empty;
else
    origPath = addpath(char(pathname), '-begin');
    cleanupObj = onCleanup(@()path(origPath));
end

end
%---------------------------------------------
function checkFilePrecedence(filename)

clear(char(filename));
try
    builtin('_mcheck', filename);
catch
    disp(['*** ', getString(message('MATLAB:checkSyntacticWarnings:FailedToCompile', char(filename)))]);
end

end
