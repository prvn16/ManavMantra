function doclick(A)
%DOCLICK Processes ButtonDown on MATLAB objects.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   J.H. Roh & B.A. Jones 4-25-97.

ud = getscribeobjectdata(A);
p  = ud.HandleStore;

doclick(p)
