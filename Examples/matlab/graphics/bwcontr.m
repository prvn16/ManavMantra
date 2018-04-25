function newcolor = bwcontr(cc)
%BWCONTR Contrasting black or white color.
%   NEW = BWCONTR(COLOR) produces a black or white depending on which
%   one would contrast the most.  Used by NODITHER.
 
%   Copyright 1984-2010 The MathWorks, Inc. 

if (ischar(cc))
    warning(message('MATLAB:bwcontr:PassingAString', mfilename))
    newcolor = [0 0 0];
else
    if ((cc * [.3; .59; .11]) > .75)
        newcolor = [0 0 0];
    else
        newcolor = [1 1 1];
    end
end
