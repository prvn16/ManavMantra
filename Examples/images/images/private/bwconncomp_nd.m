function [pixelIdxList, numObjects] = bwconncomp_nd(A, conn)
%BWCONNCOMP_ND utility function for bwconncomp
%   BWCONNCOMP_ND is called by bwconncomp and returns two outputs: pixelIdxList
%   and numObjects.  pixelIdxLists is a cell array of each connected component's
%   linear indices.
%
%   No error checking.  Done by bwconncomp. This function is called for 2-D
%   images with a connectivity other than 4 and 8 and any ND (N>2) binary image.

%   Copyright 2008-2015 The MathWorks, Inc.

conn = images.internal.getBinaryConnectivityMatrix(conn);
pixelIdxList = pixelIdxListsn(A,conn);
numObjects = numel(pixelIdxList);

for k = 1 : numObjects
    pixelIdxList{k} = sort(pixelIdxList{k});
end

