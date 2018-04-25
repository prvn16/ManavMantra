function delete(A)
%ARROWLINE/DELETE Delete arrowline
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

delete(A.arrowhead);
delete(A.line);

delete(A.editline);
