function res = base64encode(str)
% base64encode Perform Base 64 encoding of a string or vector of bytes
%   RES = base64encode(V) encodes a string, character vector, or numeric vector using
%   Base 64 encoding as documented in RFC 4648, <a href="http://tools.ietf.org/html/rfc4648#section-4">section 4</a> and returns the encoded 
%   characters as a string.  This encoding is used in a number of contexts in
%   Internet messages where data must be transmitted in a limited set of ASCII
%   characters.  It is often used to encode strings which may have special characters
%   that might be misinterpreted as control characters by the transmission protocol,
%   but it is also used to encode arbitrary binary data.
%
%   If the input is a string or character vector, it is first converted to bytes
%   using the user default encoding.  If you want to use a different character
%   encoding, use unicode2native to convert the string to a uint8 vector before
%   passing it into this function.
%
% See also base64decode, unicode2native

% Copyright 2016 The MathWorks, Inc.
    persistent chars
    if isempty(chars)
        chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
    end
    if isstring(str) || ischar(str)
        % if string or char, get scalar string and decode as bytes
        bytes = unicode2native(char(matlab.net.internal.getString(str, mfilename, 'string')));
    else
        % otherwise, must be vector of integers
        validateattributes(str, {'numeric', 'string'}, {'integer','vector'}, mfilename);
        bytes = uint8(str);
    end
    len = length(bytes);
    if isempty(bytes)
        res = char('');
    else
        res(floor(len*4/3)) = '=';
        bx = 1;
        % in this encoding, each set of 3 bytes is chopped up into 4 6-bit groups, and
        % each 6-bit group is used to index into chars to get the encoded characters
        for i = 1 : 3 : len
            if i+1 <= len
                b1 = bitshift(uint32(bytes(i+1)),8);
                if i+2 <= len
                    b2 = uint32(bytes(i+2));
                else
                    b2 = 0;
                end
            else
                b1 = 0;
                b2 = 0;
            end

            word = bitshift(uint32(bytes(i)),16) + b1 + b2;
            res(bx) = chars(bitshift(word, -18) +1 );
            res(bx+1) = chars(bitand(bitshift(word, -12), 63) + 1);
            if i+1 > len
                res(bx+2) = '=';
                res(bx+3) = '=';
            else
                res(bx+2) = chars(bitand(bitshift(word, -6), 63) + 1);
                if i+2 > len
                    res(bx+3) = '=';
                else
                    res(bx+3) = chars(bitand(word, 63) + 1);
                end
            end
            bx = bx + 4;
        end
    end
    if isstring(str)
        % return a string if input was a string; else return char vector
        res = string(res);
    end
end