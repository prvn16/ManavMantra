function o = operands( o )
%OPERANDS  o = OPERANDS( obj )  Return the (raw) operands of obj

% Copyright 2006-2014 The MathWorks, Inc.

    o = ops(o);
    o = mtpath( o, 'L' ) | mtpath( o, 'R' );
end
