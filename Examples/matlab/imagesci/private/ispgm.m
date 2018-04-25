function tf = ispgm(filename)
%ISPGM Returns true for a PGM file.
%   TF = ISPGM(FILENAME)

%   Copyright 1984-2013 The MathWorks, Inc.

fid = fopen(filename, 'r', 'ieee-le');
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));
[sig,count] = fread(fid, 3, 'uint8');
fclose(fid);
if ( count ~= 3 )
    tf = false;
    return
end
tf = (isequal(sig(1:2), [80;50]) || isequal(sig(1:2), [80;53])) && ...
         (isequal(sig(3), 10) || ...  % \n
          isequal(sig(3), 13) || ...  % \r
          isequal(sig(3), 35) || ...  % "#"
          isequal(sig(3), 9)  || ...  % \t
          isequal(sig(3), 32));       % space
