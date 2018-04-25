function [similarity,inter,union] = bwjaccard(A,B)
%BWJACCARD Jaccard similarity coefficient for binary image segmentation.
%
%   SIMILARITY = BWJACCARD(A,B) computes the intersection of binary images
%   A and B divided by the union of A and B, also known as the Jaccard
%   index.
%
%   Note
%   ----
%   This function does not do any input validation to maximize speed.
%   This is a private implementation meant for internal use. The public
%   function you should use is JACCARD.
%
%   See also JACCARD.

%   Copyright 2017 The MathWorks, Inc.

inter = nnz(A & B);
union = nnz(A | B);
similarity = inter / union;
