function tf = isdpx(filename)
%ISDPX   Check if file is DPX.
%    TF = ISDPX(FILENAME) checks whether a file contains DPX data,
%    returning TRUE in TF if it does and FALSE otherwise.
%
%    See also DPXINFO, DPXREAD.

% Copyright The MathWorks, Inc. 2015

[fid, msg] = fopen(filename, 'r');
if (fid < 0)
  error('MATLAB:images:isnitf:fileOpen', '%s', ...
      getString(message('MATLAB:images:isnitf:fileOpen', filename, msg)));
end
fileCloser = onCleanup(@() fclose(fid)); 

magicNumber = fread(fid, 4, 'uint8');
magicNumber = char(reshape(magicNumber, [1 4]));

expectedValue = 'SDPX';

switch (magicNumber)
case {expectedValue, fliplr(expectedValue)}
    tf = true;
otherwise
    tf = false;
end
