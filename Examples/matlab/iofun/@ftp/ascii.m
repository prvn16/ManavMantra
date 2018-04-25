function ascii(f)
%ASCII  Sets ASCII transfer type.
%   ASCII(F) sets ASCII transfer type for the FTP object F.

% Matthew J. Simoneau, 31-Jan-2002
% Copyright 1984-2005 The MathWorks, Inc.

% Make sure we're still connected.
connect(f)

% There isn't an easier way to set the value of a StringBuffer.
f.type.setLength(0);
f.type.append('ascii');