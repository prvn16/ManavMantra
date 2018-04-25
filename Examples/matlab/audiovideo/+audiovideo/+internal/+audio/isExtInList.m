function tf = isExtInList(filename, extList)
% ISEXTINLIST Checks if the filename has one of the specified extensions.
% This is used for generating appropriate function signatures for
% AUDIOWRITE.

% Author: Dinesh Iyer
% Copyright 2017 MathWorks, Inc.

[~, ~, fileExt] = fileparts(filename);

tf = ismember(lower(fileExt), extList);
