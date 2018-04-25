function result = ispc
%ISPC True for the PC (Windows) version of MATLAB.
%   ISPC returns 1 for PC (Windows) versions of MATLAB and 0 otherwise.
%
%   See also COMPUTER, ISUNIX, ISMAC.

%   Copyright 1984-2006 The MathWorks, Inc. 

result = strncmp(computer,'PC',2);
