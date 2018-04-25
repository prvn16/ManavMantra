%UNICODE2NATIVE	Convert Unicode characters to bytes
%   BYTES = UNICODE2NATIVE(UNICODESTR) converts a character vector or string scalar 
%   of Unicode character representations, UNICODESTR, to the user default encoding,
%   and returns the bytes as a uint8 vector BYTES. The output vector, BYTES, 
%   has the same general array shape as UNICODESTR. You can save the output 
%   of UNICODE2NATIVE in a file using FWRITE.
%
%   BYTES = UNICODE2NATIVE(UNICODESTR,ENCODING) converts UNICODESTR to the
%   character encoding scheme specified by ENCODING. The input argument 
%   ENCODING must be an empty character vector, string scalar containing 
%   no characters, name, or alias for an encoding scheme. Some examples 
%   are 'UTF-8','latin1', 'US-ASCII', and 'Shift_JIS'. If ENCODING is 
%   unspecified or is empty, MATLAB's default encoding scheme is used.
%
%   For example,
%
%       fid = fopen('japanese_in.txt');
%       b = fread(fid,'*uint8')';
%       fclose(fid);	
%       str = native2unicode(b,'Shift_JIS');
%
%       disp(str);
%
%       b = unicode2native(str,'Shift_JIS');
%       fid = fopen('japanese_out.txt','w');
%       fwrite(fid,b);		 
%       fclose(fid);
%
%   reads, displays, and writes some Japanese text. The disp(str)
%   command requires that str consist entirely of Unicode characters to
%   display correctly. The example calls FWRITE to save the text to a
%   file 'japanese_out.txt'. To write this file using the original
%   character set, call UNICODE2NATIVE first to convert the Unicode
%   characters back to 'Shift_JIS'.
%
%   Here is an equivalent way to read, display, and write Japanese text, 
%   again assuming that the computer is configured to display Japanese: 
%
%       fid = fopen('japanese.txt', 'r', 'n', 'Shift_JIS');
%       str = fread(fid, '*char')';
%       fclose(fid);
%
%       disp(str);
%
%       fid = fopen('japanese_out.txt', 'w', 'n', 'Shift_JIS');
%       fwrite(fid, str, 'char');
%       fclose(fid);
%
%   See also NATIVE2UNICODE.

%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.


