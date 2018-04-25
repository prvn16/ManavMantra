function [startRow,endRow,startCol,labelForEachRun,numComponents] = labelBinaryRuns(BW,mode)
%labelBinaryRuns is used by bwlabel and bwconncomp_2d. 
%   The inputs are a 2D binary image BW and the connectivity MODE. There is no
%   error checking in this code.  BW must be a 2D binary image and MODE must be
%   4 or 8.
%
%   The outputs are:
%   startRow        - starting Row subscript of the run.
%   endRow          - last Row subscript of the run.
%   startCol        - starting Col of the run.
%   labelForEachRun - label associated with each run.
%   numComponents   - number of Connected Components in BW.
%
%   startRow, endRow, startCol, and labels are vectors of the same size.

% Copyright 2008 The MathWorks, Inc.

% Reference - See the "Connected Components" category in Steve Eddins' blog.
% http://blogs.mathworks.com/steve/2007/03/20/connected-component-labeling-part-3/


% The variable labelForEachRun is the initial labels for each run. However, some labels may be
% equivalent to one another. The variables, i & j indicate which pairs of labels
% are equivalent.  For example, i(k) and j(k) tell you that those labels (and in
% turn those runs) point to different pieces of the same object.

[startRow,endRow,startCol,labelForEachRun,i,j] = bwlabel1(BW,mode);
if (isempty(labelForEachRun))
    numInitialLabels = 0;
else
    numInitialLabels = max(labelForEachRun);
end

% Create a sparse matrix representing the equivalence graph.
tmp = (1:numInitialLabels)';
A = sparse([i;j;tmp], [j;i;tmp], 1, numInitialLabels, numInitialLabels);

% Determine the connected components of the equivalence graph
% and compute a new label vector.

% Find the strongly connected components of the adjacency graph
% of A.  dmperm finds row and column permutations that transform
% A into upper block triangular form.  Each block corresponds to
% a connected component; the original source rows in each block
% correspond to the members of the corresponding connected
% component.  The first two output% arguments (row and column
% permutations, respectively) are the same in this case because A
% is symmetric.  The vector r contains the locations of the
% blocks; the k-th block as indices r(k):r(k+1)-1.
[tmp,p,r] = dmperm(A);

% Compute vector containing the number of elements in each
% component.
sizes = diff(r);

% Number of connected components after equivalence class resolution.
numComponents = length(sizes);  

blocks = zeros(1,numInitialLabels);
blocks(r(1:numComponents)) = 1;
blocks = cumsum(blocks);
blocks(p) = blocks;
labelForEachRun = blocks(labelForEachRun);

