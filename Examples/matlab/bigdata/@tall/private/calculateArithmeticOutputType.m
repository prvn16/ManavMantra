function outClz = calculateArithmeticOutputType(arg1Clz, arg2Clz)
% calculateArithmeticOutputType Calculate type resulting from arithmetic operation
%   Neither arg1Clz nor arg2Clz may be a 'strong' type.

% Copyright 2016 The MathWorks, Inc.

% This is similar to the GPU implementation, but must handle the fact that the
% classes might not be known, and the scalar-ness is also unknown.

% To get here, strong types *must* have already been dealt with. This method is
% intended only for numeric-ish types.
assert(isempty(intersect({arg1Clz, arg2Clz}, ...
                         matlab.bigdata.internal.adaptors.getStrongTypes())));

% If we've got a combination involving an unknown type, return the unknown type.
if isempty(arg1Clz) || isempty(arg2Clz)
    outClz = '';
else
    % Both types are known, use whichever is dominant.
    outClz = iCalculateDominantType(arg1Clz, arg2Clz);
end

% Convert logical/char -> double
if ismember(outClz, {'logical', 'char'})
    outClz = 'double';
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outClz = iCalculateDominantType(arg1Clz, arg2Clz)

if isequal(arg1Clz, arg2Clz)
    outClz = arg1Clz;
    return
end

% Check, in this order, 'logical', 'char', 'double', 'single' - 'logical' and
% 'char' lose to everything, 'double' loses to everything but 'logical'/'char', and
% 'single' loses to everything but the preceding types.
for type = {'logical', 'char', 'double', 'single'}
    if strcmp(arg1Clz, type{1})
        outClz = arg2Clz;
        return
    elseif strcmp(arg2Clz, type{1})
        outClz = arg1Clz;
        return
    end
end

% We end up here for combinations of integer types for example. These are going
% to throw a run-time error in any case, so simply return one of the types.
outClz = arg1Clz;
end
