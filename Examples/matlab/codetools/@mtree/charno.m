function C = charno( o )
%CHARNO  C = charno( obj )   Character positions of nodes in obj

% Copyright 2006-2014 The MathWorks, Inc.

    C = o.T( o.IX, 5 ) - o.lnos(lineno(o));
end
