function [pixelIdxList,numObjects] = bwconncomp_2d(BW,mode)
%BWCONNCOMP_2D Label connected components in 2-D binary image.
%   BWCONNCOMP_2D(BW,mode) is called by bwconncomp to get the linear indices of
%   pixels in each region and the total number of regions (objects) in each
%   image.
%
%   No error checking.  Done by bwconncomp. BW must be 2-D.  mode can be 4 or 8.

%   Copyright 2008 The MathWorks, Inc.

[startRow,endRow,startCol,labelForEachRun,numObjects] = labelBinaryRuns(BW,mode);

runLengths = endRow - startRow + 1;

subs = [labelForEachRun(:), ones(numel(labelForEachRun), 1)]; 
objectSizes = accumarray(subs, runLengths);

pixelIdxList = pixelIdxLists(size(BW),numObjects,objectSizes,startRow,...
                             startCol,labelForEachRun,runLengths);

