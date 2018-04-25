%FPRINTF Write formatted data to text file.
%   FPRINTF(FID, FORMAT, A, ...) applies the FORMAT to all elements of array A and
%   any additional array arguments in column order, and writes the data to a text
%   file.  FID is an integer file identifier.  Obtain FID from FOPEN, or set it to 1
%   (for standard output, the screen) or 2 (standard error). FPRINTF uses the
%   encoding scheme specified in the call to FOPEN.
%
%   FPRINTF(FORMAT, A, ...) formats data and displays the results on the screen.
%
%   COUNT = FPRINTF(...) returns the number of bytes that FPRINTF writes.
%
%   FORMAT is a character vector that describes the format of the output fields, and
%   can include combinations of the following:
%
%      * Conversion specifications, which include a % character, a
%        conversion character (such as d, i, o, u, x, f, e, g, c, or s), and optional
%        flags, width, and precision fields.  For more details, type "doc fprintf" at
%        the command prompt.
%
%      * Literal text to print.
%
%      * Escape characters, including:
%            \b     Backspace            ''   Single quotation mark
%            \f     Form feed            %%   Percent character
%            \n     New line             \\   Backslash
%            \r     Carriage return      \xN  Hexadecimal number N
%            \t     Horizontal tab       \N   Octal number N
%        For most cases, \n is sufficient for a single line break. However, if you
%        are creating a file for use with Microsoft Notepad, specify a combination of
%        \r\n to move to a new line.
%
%   Notes:
%
%   If you apply an integer or text conversion to a numeric value that contains a
%   fraction, MATLAB overrides the specified conversion, and uses %e.
%
%   Numeric conversions print only the real component of complex numbers.
%
%   Example: Create a text file called exp.txt containing a short table of the
%   exponential function.
%
%       x = 0:.1:1;
%       y = [x; exp(x)];
%       fid = fopen('exp.txt','w');
%       fprintf(fid,'%6.2f  %12.8f\n',y);
%       fclose(fid);
%
%   Examine the contents of exp.txt:
%
%       type exp.txt
%
%   MATLAB returns:
%          0.00    1.00000000
%          0.10    1.10517092
%               ...
%          1.00    2.71828183
%
%   See also FOPEN, FCLOSE, FSCANF, FREAD, FWRITE, SPRINTF, DISP.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.

