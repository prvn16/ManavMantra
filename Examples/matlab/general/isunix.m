function result = isunix()
%ISUNIX True for the UNIX version of MATLAB.
%   ISUNIX returns 1 for UNIX versions of MATLAB and 0 otherwise.
%
%   See also COMPUTER, ISPC, ISMAC.

%   Copyright 1984-2006 The MathWorks, Inc.

%  The only non-Unix platform is the PC
result = ~strncmp(computer,'PC',2);
