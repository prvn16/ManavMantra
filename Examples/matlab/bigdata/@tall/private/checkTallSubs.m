function S = checkTallSubs(S, method, invalidTallErrId)
%checkTallSubs Check tall subscripts for SUBSREF and SUBSASGN
%   S = checkTallSubs(S, method, errId) checks only the first level of indexing,
%   and ensures that if the first subscript is tall, that it is logical. An
%   error is thrown if any subsequent subscript is tall.

% Copyright 2016-2017 The MathWorks, Inc.

isParenOrBrace = ismember(S(1).type, {'{}', '()'});

if isParenOrBrace && iscell(S(1).subs)
    isSubTall = cellfun(@istall, S(1).subs);
    if ~isempty(isSubTall) && isSubTall(1)
        S.subs{1} = tall.validateType(S(1).subs{1}, method, {'logical', 'numeric'}, 1);
    end
    if any(isSubTall(2:end))
        error(message(invalidTallErrId));
    end
end
end
