function varargout = subsref(obj, S)
%SUBSREF Subscripted reference for tall
%   B = SUBSREF(A, S) is the functional form of subscripted reference.
%
%   Supported forms of indexing for tall array A:
%   B = A(L, ...)
%   where: - L is a logical array (tall or non-tall) selecting slices of A.
%          - If L is a tall logical array, it must have the same height as A.
%
%   B = A(:, ...)
%   where: - The subscript in the tall dimension is ':'
%
%   B = A(IDX, ...)
%   where: - IDX is a tall numeric column vector or a non-tall numeric
%            vector.
%
%   B = A(P:D:Q, ...)
%   B = A(P:Q, ...)
%   where: - P:Q or P:D:Q are any valid colon-indexing expressions.
%
%   All of the above indexing expressions allow zero or more non-tall
%   trailing subscripts.
%
%   When indexing with a single subscript, A must be a tall vector, and the
%   subscript must be a vector.
%
%   When indexing a tall matrix or multi-dimensional array, you must
%   provide two or more subscripts.
%
%   See also subsref, tall.

%   Copyright 2015-2017 The MathWorks, Inc.

try
    numOut = max(1, nargout);
    [varargout{1:numOut}] = iSubsref(obj, S);
catch E
    throwAsCaller(E);
end
end

function varargout = iSubsref(obj, S)
% Internal implementation of tall/subsref.

% This prevents this frame and anything below it being added to the gather
% error stack.
markerFrame = matlab.bigdata.internal.InternalStackFrame(); %#ok<NASGU>

S = checkTallSubs(S, mfilename, 'MATLAB:bigdata:array:SubsrefInvalidTallSubscript');

switch S(1).type
    case '()'
        method = @subsrefParens;
    case '{}'
        method = @subsrefBraces;
    case '.'
        method = @subsrefDot;
end
% Some methods need the full size of the array, so extract that.
sz = size(obj);
[varargout{1:nargout}] = method(obj.Adaptor, obj.ValueImpl, sz.ValueImpl, S);
end
