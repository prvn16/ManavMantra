function encodedStr = encodeURIForJS(str)
%ENCODEURIFORJS Method to encode string equivalently with Javascript
% encoding.
%
%    Copyright 2015 The MathWorks, Inc

    % urlencode() in MATLAB just wraps the Java URLEncoder, and
    % it's not exact the same as Javascript side
    encodedStr = urlencode(str);

    % For Javascript, the following characters
    % are needed to be handled differently, otherwise the client
    % side would fail to decode the string
    encodedStr = strrep(encodedStr, '%28', '(');
    encodedStr = strrep(encodedStr, '%29', ')');
    encodedStr = strrep(encodedStr, '+', '%20');
    encodedStr = strrep(encodedStr, '%21', '!');
    encodedStr = strrep(encodedStr, '%7E', '~');
end

