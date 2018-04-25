%NATIVE2UNICODE	Convert bytes to Unicode characters
%   UNICODESTR = NATIVE2UNICODE(BYTES) converts text containing 
%   numeric values in the range [0,255] to a Unicode character 
%   representation and returns UNICODESTR as a character vector.
%   NATIVE2UNICODE treats BYTES as a vector of 8-bit bytes. BYTES is 
%   assumed to be in MATLAB's default character encoding scheme. The 
%   output vector, UNICODESTR, has the same general array shape as BYTES.
%   You can use the function FREAD to generate input to this function.
%
%   UNICODESTR = NATIVE2UNICODE(BYTES,ENCODING) does the conversion
%   with the assumption that BYTES is in the character encoding
%   scheme specified by ENCODING. ENCODING must be an empty character 
%   vector, string scalar containing 
%   no characters, name, or alias for an encoding scheme. 
%   Some examples are 'UTF-8', 'latin1', 'US-ASCII', and 'Shift_JIS'. 
%   If ENCODING is unspecified or is empty, MATLAB's default encoding scheme is used.
%
%   If BYTES is a character vector or string scalar, it is returned unchanged.
%
%   Example:
%
%       fid = fopen('japanese.txt');
%       b = fread(fid,'*uint8')';
%       fclose(fid);
%       str = native2unicode(b,'Shift_JIS');
%       disp(str);
%  
%   reads and displays some Japanese text. For the final command,
%   disp(str), to display this text correctly, the contents of str
%   must consist entirely of Unicode characters. The call to
%   NATIVE2UNICODE converts text read from the file to Unicode and
%   returns it in str. The Shift_JIS argument ensures that str
%   contains the same string on any computer, regardless of how it
%   is configured for language. Note that the computer must be
%   configured to display Japanese (e.g. a Japanese Windows machine)
%   for the output of disp(str) to be correct.
%
%   Here is an equivalent way to read and display Japanese text, again 
%   assuming that the computer is configured to display Japanese: 
%
%       fid = fopen('japanese.txt', 'r', 'n', 'Shift_JIS');
%       str = fread(fid, '*char')';
%       fclose(fid);
%       disp(str);
%
%   See also UNICODE2NATIVE.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.


