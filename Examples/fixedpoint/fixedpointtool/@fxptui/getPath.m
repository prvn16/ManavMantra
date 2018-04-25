function path = getPath(p)
%GETPATH   Get the path.

%   Copyright 2012 MathWorks, Inc.

%the space affs a space to some paths but it puts a space where one is
%needed in others the latter case takes precedent
path = strrep(p, sprintf('\n'), ' ');
