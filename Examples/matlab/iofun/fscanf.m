%FSCANF Read data from text file.
%   [A,COUNT] = FSCANF(FID,FORMAT) reads and converts data from a text file into
%   array A in column order. FID is a file identifier obtained from FOPEN. COUNT is
%   an optional output argument that returns the number of elements successfully
%   read.
%
%   FORMAT is a character vector containing ordinary characters and/or conversion
%   specifications, which include a % character, an optional asterisk for assignment
%   suppression, an optional width field, and a conversion character (such as d, i,
%   o, u, x, e, f, g, s, or c).
%
%   FSCANF reapplies the FORMAT throughout the entire file. If FSCANF cannot match
%   the FORMAT to the data, it reads only the portion that matches into A and then
%   stops processing. For more details on the FORMAT input, type "doc fscanf" at the
%   command prompt.
%
%   [A,COUNT] = FSCANF(FID,FORMAT,SIZEA) reads SIZEA elements into A. Valid forms for
%   SIZEA are:
%
%      inf    Read to the end of the file. (default)
%      N      Read at most N elements into a column vector.
%      [M,N]  Read at most M * N elements filling at least an M-by-N matrix in column
%             order. N can be inf, but M cannot.
%
%   Notes:
%
%   MATLAB reads characters using the encoding scheme associated with the file. See
%   FOPEN for more information. MATLAB converts characters in both the FORMAT argument and in
%   the file to the internal character representation before comparing.
%
%   Examples:
%
%   File count.dat contains three columns of integers. Read the values in column
%   order, and transpose to match the appearance of the file:
%
%       fid = fopen('count.dat');
%       A = fscanf(fid,'%d',[3,inf])';
%       fclose(fid);
%
%    Read the contents of plus.m into a character vector:
%
%       fid = fopen('plus.m');
%       S = fscanf(fid,'%s');
%       fclose(fid);
%
%   See also FOPEN, FPRINTF, SSCANF, TEXTSCAN, FGETL, FGETS, FREAD, INPUT.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.

