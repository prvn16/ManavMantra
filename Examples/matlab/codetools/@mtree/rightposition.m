function RP = rightposition(o)
%RIGHTPOSITION  pos = RIGHTPOSITION(obj)  return rightmost position
%   The rightmost position of any node in obj, including possible
%   closing symbols (right parens and brackets, comments, etc.)

% Copyright 2006-2014 The MathWorks, Inc.

    RP = max( endposition(o) );
    IXX = find( o.IX );
    IXX = IXX(o.PTval(o.T( IXX, 1 )));
    if ~isempty(IXX)
        RP = max( RP, max( o.T( IXX, 7 ) ) ); 
    end
end
