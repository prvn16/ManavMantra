function tf = ispcx(filename)
%ISPCX Returns true for a PCX file.
%   TF = ISPCX(FILENAME)

%   Copyright 1984-2013 The MathWorks, Inc.

fid = fopen(filename, 'r', 'ieee-le');
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));
header = fread(fid, 128, 'uint8');
fclose(fid);
if (length(header) < 128)
    tf = false;
else
    tf = (header(1) == 10) && ...
             (ismember(header(2), [0 2 3 4 5])) && ...
             (header(3) == 1);
end
