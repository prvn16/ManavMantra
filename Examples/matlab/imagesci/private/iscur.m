function tf = iscur(filename)
%ISCUR Returns true for a CUR file.
%   TF = ISCUR(FILENAME)
  
%   Copyright 1984-2013 The MathWorks, Inc.

fid = fopen(filename, 'r', 'ieee-le');
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));
sig = fread(fid, 2, 'uint16');
tf = isequal(sig, [0; 2]);
    
% Might be a WK1 file.
if (tf)
    fseek(fid, 0, 'bof');
    sig = fread(fid, 6, 'uchar');
    tf = ~isequal(sig, [0 0 2 0 6 4]');  % WK1 BOF identifier.
end
    
fclose(fid);
