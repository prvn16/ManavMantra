function wheelMove(ntx,ev)
% Mouse scroll wheel modified/moved

%   Copyright 2010 The MathWorks, Inc.

% Allow DialogPanel to handle wheel events in its area
handled = mouseScrollWheel(ntx.dp,ev);
if handled
    return % EARLY EXIT
end

% There are currently no other wheel event actions defined in NTX
