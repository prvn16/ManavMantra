function out = openslx(filename)
%OPENSLX   Open *.SLX model in Simulink.  Helper function for OPEN.
%
%   See OPEN.

%   Copyright 2011 The MathWorks, Inc.

% Handle SLX files in exactly the same way as MDL files.
out = openmdl(filename);
