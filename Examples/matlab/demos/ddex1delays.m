function d = ddex1delays(t,y)
%DDEX1DELAYS  Delays for using with DDEX1DE.
%
%   See also DDESD.

%   Jacek Kierzenka, Lawrence F. Shampine and Skip Thompson
%   Copyright 1984-2014 The MathWorks, Inc.

d = [ t - 1
   t - 0.2];

