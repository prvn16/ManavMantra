function csvwrite(filename, m, r, c)
%CSVWRITE Write a comma-separated value file.
%   CSVWRITE(FILENAME,M) writes matrix M into FILENAME as 
%   comma-separated values.
%
%   CSVWRITE(FILENAME,M,R,C) writes matrix M starting at offset 
%   row R, and column C in the file.  R and C are zero-based, so that
%   R=0 and C=0 specifies first number in the file.
%
%   Notes:
%   
%   * CSVWRITE terminates each line with a line feed character and no
%     carriage return.
%
%   * CSVWRITE writes a maximum of five significant digits.  For greater
%     precision, call DLMWRITE with a precision argument.
%
%   * CSVWRITE does not accept cell arrays for the input matrix M. To
%     export cell arrays to a text file, use low-level functions such as
%     FPRINTF.
%
%   See also CSVREAD, DLMREAD, DLMWRITE.

%   Copyright 1984-2011 The MathWorks, Inc.

%
% test for proper filename
%
if ~ischar(filename) && ~isstring(filename)
    error(message('MATLAB:csvwrite:FileNameMustBeString'));
end

%
% Call dlmwrite with a comma as the delimiter
%

if nargin < 3
    r = 0;
end
if nargin < 4
    c = 0;
end

try
    dlmwrite(filename, m, ',', r, c);
catch e
    throw(e)
end
%dlmwrite(filename, m, ',', r, c);
