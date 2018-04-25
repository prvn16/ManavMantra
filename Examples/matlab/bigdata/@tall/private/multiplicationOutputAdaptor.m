function out = multiplicationOutputAdaptor(x, y)
%multiplicationOutputAdaptor calculate output adaptor for TIMES and MTIMES

% Copyright 2016 The MathWorks, Inc.

cX = tall.getClass(x);
cY = tall.getClass(y);

% Fix for g1372184 - the only 'strong' types that supports TIMES are
% categorical, duration, and calendarDuration. The result is always the strong
% type.
typeToPropagate = intersect({'categorical', 'duration', 'calendarDuration'}, {cX, cY});
if ~isempty(typeToPropagate)
    % If we get more than 1 type to propagate, trouble will ensue later
    cZ = typeToPropagate{1};
else
    % Preserve type, but logical/char -> double
    cZ = calculateArithmeticOutputType(cX, cY);
end
out = matlab.bigdata.internal.adaptors.getAdaptorForType(cZ);
end
