function dydt = ddex1de(t,y,Z)
%DDEX1DE  Example of delay differential equations for solving with DDE23.
%
%   See also DDE23.

%   Jacek Kierzenka, Lawrence F. Shampine and Skip Thompson
%   Copyright 1984-2014 The MathWorks, Inc.

ylag1 = Z(:,1);
ylag2 = Z(:,2);
dydt = [ ylag1(1)
   ylag1(1) + ylag2(2)
   y(2)               ];
