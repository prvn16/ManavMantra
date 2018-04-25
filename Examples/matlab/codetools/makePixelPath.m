function pixelPath = makePixelPath()
%MAKEPIXELPATH Make the text of path to pixel images used in profiler

% Copyright 2016 The MathWorks, Inc.

fs = filesep;
pixelPath = ['file:///' matlabroot fs 'toolbox' fs 'matlab' fs 'codetools' fs 'private' fs];
end