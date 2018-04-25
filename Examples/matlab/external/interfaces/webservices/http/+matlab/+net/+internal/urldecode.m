function res = urldecode(str, plus2space)
% matlab.net.internal.urldecode Decode a vector of strings that were URL-encoded
%   res = urldecode(str)   Applies URL decoding rules to ASCII str and returns
%                          Unicode string res.
%   res = urldecode(str,plus2space)  If plus2space true, decodes + to space;
%                                    otherwise leaves it unchanged.  This only
%                                    converts a raw + to space.  A %2B is
%                                    converted to +.
%
% This function assumes the input is a properly encoded string containing
% only ASCII characters.  
%
% The process is to convert every character c in str to a byte using uint8(c),
% except that sequences of %xx become the byte hex2dec('xx').  Then convert the
% bytes to a MATLAB string using native2unicode(___,'UTF-8').
%
% If used for a URI, this function is best applied to components of a URI one
% at a time, not an entire URI.  It may return an ambiguous result that is not
% reversible if given more than one component or segment of a URI, as the
% decoded characters may look like URI punctuation.
%
% This function warns if it encounters a bad percent-encoding or characters in
% the input string outside of the ASCII range (0-127), but it does not warn if the
% string contains reserved ASCII characters that should not be in an encoded
% string.  These characters are passed through unchanged, but reversibility of
% such encodings is not guaranteed.
%
% Characters in str outside the range of 0-255 are (after a warning) converted
% to code point 255, which is most certainly not what the caller intended.
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented and
%   is intended for use only within the scope of functions and classes in
%   toolbox/matlab/external/interfaces/webservices. Its behavior may change,
%   or the function itself may be removed in a future release.

% Copyright 2016 The MathWorks, Inc.
    str = string(str);
    err = [];
    converted = false;
    myHex2Dec = @(x) doHex2Dec(x); %#ok<NASGU> used in regexprep
    if nargin > 1 && plus2space
        % Replace + with space first, and then %xx with the character equivalent
        % If we did it in reverse order, '%2B' would turn into ' ' instead of '+'.
        res = regexprep(str, {'+' '%..'}, {' ' '${myHex2Dec($&)}'});
    else
        res = regexprep(str, '%..', '${myHex2Dec($&)}');
    end
    if ~isempty(err)
        warning(message('MATLAB:http:BadPercentEncoding', err, char(str)));
    end
    if converted
        for i = 1 : length(res)
            chars = char(res(i));
            if any(chars > 255)
                warning(message('MATLAB:http:StringNotAscii', char(c), char(str)));
            end
            res(i) = string(native2unicode(uint8(chars),'UTF-8'));
        end
    end

    function res = doHex2Dec(s) 
        try 
            res = char(hex2dec(s(2:end)));
            converted = true;
        catch 
            err = s;
            res = s;
        end
    end
end        
