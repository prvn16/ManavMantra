function [ln,ch] = lastone( o )
%LASTONE  [L,C] = lastone( o )  line/char of end of nodes
%   This returns the positions of the matching paren, bracket, or
%   END of the nodes in o.

% Copyright 2006-2014 The MathWorks, Inc.

    Pos = o.T( o.IX, 7 ); % these are positions
    ln = zeros(length(Pos),1);
    for i=1:length(Pos)
        ln(i) = linelookup( o, Pos(i) );
    end
    ch = Pos - o.lnos(ln);
end
