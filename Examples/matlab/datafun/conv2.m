%CONV2 Two dimensional convolution.
%   C = CONV2(A, B) performs the 2-D convolution of matrices A and B.
%   If [ma,na] = size(A), [mb,nb] = size(B), and [mc,nc] = size(C), then
%   mc = max([ma+mb-1,ma,mb]) and nc = max([na+nb-1,na,nb]).
%
%   C = CONV2(H1, H2, A) first convolves each column of A with the vector
%   H1 and then convolves each row of the result with the vector H2.  If
%   n1 = length(H1), n2 = length(H2), and [mc,nc] = size(C) then
%   mc = max([ma+n1-1,ma,n1]) and nc = max([na+n2-1,na,n2]).
%   CONV2(H1, H2, A) is equivalent to CONV2(H1(:)*H2(:).', A) up to
%   round-off.
%
%   C = CONV2(..., SHAPE) returns a subsection of the 2-D
%   convolution with size specified by SHAPE:
%     'full'  - (default) returns the full 2-D convolution,
%     'same'  - returns the central part of the convolution
%               that is the same size as A.
%     'valid' - returns only those parts of the convolution
%               that are computed without the zero-padded edges.
%               size(C) = max([ma-max(0,mb-1),na-max(0,nb-1)],0).
%
%   See also CONV, CONVN, FILTER2, XCORR2.
%
%   Note: XCORR2 is in the Signal Processing Toolbox.

%   Copyright 1984-2011 The MathWorks, Inc.
%   Built-in function.
