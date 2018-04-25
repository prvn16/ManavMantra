function INLINE_OUT_ = subsref(INLINE_OBJ_, INLINE_SUBS_)
%SUBSREF Evaluate INLINE object.

%   Copyright 1984-2011 The MathWorks, Inc.

if (INLINE_OBJ_.isEmpty)
    error(message('MATLAB:Inline:subsref:emptyInline'));
end

INLINE_INPUTS_ = INLINE_SUBS_.subs;
if (length(INLINE_INPUTS_) < INLINE_OBJ_.numArgs)
    error(message('MATLAB:Inline:subsref:tooFewInputs'));
elseif (length(INLINE_INPUTS_) > INLINE_OBJ_.numArgs)
    error(message('MATLAB:Inline:subsref:tooManyInputs'));
end

if (isempty(INLINE_OBJ_.expr))
    INLINE_OUT_ = [];
else
    % Need to evaluate expression in a function outside the @inline directory
    % so that f(x), where f is an inline in the expression, will call the
    % overloaded subsref.
    INLINE_OUT_ = inlineeval(INLINE_INPUTS_, INLINE_OBJ_.inputExpr, INLINE_OBJ_.expr);
end

