function code = getfourcc(fourcc)

code = [char(bitand(bitshift(fourcc,0,'uint32'),255)) ...
        char(bitand(bitshift(fourcc,-8,'uint32'),255)) ...
        char(bitand(bitshift(fourcc,-16,'uint32'),255)) ...
        char(bitand(bitshift(fourcc,-24,'uint32'),255)) ];


%   Copyright 1984-2013 The MathWorks, Inc.

