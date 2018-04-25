function TF = isRSetImage(hIm)
%isRSetImage returns true if hIm is an RSet image.
%
% TF = isRSetImage(hIm) returns TF, which is true if hIm is an R-Set.

%   Copyright 2008-2014 The MathWorks, Inc.

TF = strcmp(get(hIm,'tag'),'rset overview');
