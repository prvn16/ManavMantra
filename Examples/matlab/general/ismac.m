function result = ismac
%ISMAC True for the Mac OS X version of MATLAB.
%   ISMAC returns 1 for MAC (Macintosh) versions of MATLAB and 0 otherwise.
%
%   See also COMPUTER, ISUNIX.

%   Copyright 1984-2006 The MathWorks, Inc. 

result = strncmp(computer,'MAC',3);
