function C = convertToCellOfLogicals(A,classes)
%convertToCellOfLogicals Convert array to cell array of logical arrays
%
%   C = convertToCellOfLogicals(A,CLASSES) converts the array A into
%   the cell array C, where each cell, C{k}, contains a logical array
%   the same size as A which is true in pixel locations belonging to
%   CLASSES(k).
%
%   Note
%   ----
%   This function is meant for internal use only.

%   Copyright 2017 The MathWorks, Inc.

num_class = numel(classes);
C = cell(num_class,1);
for k = 1:num_class
    C{k} = (A == classes(k));
end
