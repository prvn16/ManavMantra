function pos = lc2pos( o, l, c )
%LC2POS  pos = LC2POS( obj, L, C )   Convert line/char to position

% Copyright 2006-2014 The MathWorks, Inc.

    pos = reshape( o.lnos(l), size(l) ) + c;
end
