function tf = isras(filename)
%ISRAS Returns true for a RAS file.
%   TF = ISRAS(FILENAME)

%   Copyright 1984-2013 The MathWorks, Inc.

fid = fopen(filename, 'r', 'ieee-be' );
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));
sig = fread(fid, 1, 'uint32');
fclose(fid);
tf = isequal(sig, 1504078485);      % 0x59a66a95
