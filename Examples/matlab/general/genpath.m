function p = genpath(d)
%GENPATH Generate recursive toolbox path.
%   P = GENPATH returns a character vector containing a path name 
%   that includes all the folders and subfolders below MATLABROOT/toolbox, 
%   including empty subfolders.
%
%   P = GENPATH(FOLDERNAME) returns a character vector containing a path 
%   name that includes FOLDERNAME and all subfolders of FOLDERNAME, 
%   including empty subfolders.
%   
%   NOTE 1: GENPATH will not exactly recreate the original MATLAB path.
%
%   NOTE 2: GENPATH only includes subfolders allowed on the MATLAB
%   path.
%
%   See also PATH, ADDPATH, RMPATH, SAVEPATH.

%   Copyright 1984-2017 The MathWorks, Inc.
%------------------------------------------------------------------------------

% String Adoption
if nargin > 0
    d = convertStringsToChars(d);
end

if nargin==0,
  p = genpath(fullfile(matlabroot,'toolbox'));
  if length(p) > 1, p(end) = []; end % Remove trailing pathsep
  return
end

% initialise variables
classsep = '@';  % qualifier for overloaded class directories
packagesep = '+';  % qualifier for overloaded package directories
p = '';           % path to be returned

% Generate path based on given root directory
files = dir(d);
if isempty(files)
  return
end

% Add d to the path even if it is empty.
p = [p d pathsep];

% set logical vector for subdirectory entries in d
isdir = logical(cat(1,files.isdir));
%
% Recursively descend through directories which are neither
% private nor "class" directories.
%
dirs = files(isdir); % select only directory entries from the current listing

for i=1:length(dirs)
   dirname = dirs(i).name;
   if    ~strcmp( dirname,'.')          && ...
         ~strcmp( dirname,'..')         && ...
         ~strncmp( dirname,classsep,1) && ...
         ~strncmp( dirname,packagesep,1) && ...
         ~strcmp( dirname,'private')
      p = [p genpath(fullfile(d,dirname))]; % recursive calling of this function.
   end
end

%------------------------------------------------------------------------------
