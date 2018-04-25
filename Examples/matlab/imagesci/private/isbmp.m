function tf = isbmp(filename)
%ISBMP Returns true for a BMP file.
%   TF = ISBMP(FILENAME)

%   Copyright 1984-2013 The MathWorks, Inc.

fid = fopen(filename, 'r', 'ieee-le');
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));
sig = fread(fid, 2, 'uint8');
fclose(fid);
tf = isequal(sig, double('BM')');
