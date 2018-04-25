function delete(A)
%EDITRECT/DELETE Delete editrect object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

delete(A.Objects);
delete(A.editline);
