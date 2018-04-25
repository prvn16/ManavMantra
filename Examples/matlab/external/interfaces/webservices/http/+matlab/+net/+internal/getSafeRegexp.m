function str = getSafeRegexp(str)
% Convert str to a regexp that matches the exact characters in str, so that
% str can be used as or in a portion of a regexp or replacement string in
% regexprep.  To do this we backslash-escape all the regexp or regexprep special
% characters. This should work whether str appears alone or between () or [],
% but not within {}.

% Copyright 2016 The MathWorks, Inc.
    
    % Even though characters like -)] have no special meaning at the top level of
    % a regexp, we need to escape them in case str is used inside [] or ().
    % Special characters that only have meaning after other characters like $ or (
    % that we are already escaping don't need to be escaped.
    str = regexprep(str, '[-&?.+*\[\\|(^$\]){]', '\\$&');
end