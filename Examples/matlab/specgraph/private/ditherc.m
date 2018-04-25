function im=ditherc( r, g, b, map, qm, qe )
%DITHERC Floyd-Steinberg image dithering (MEX function).
%   DITHERC implements the dithering algorithm for the function
%   DITHER.  It has the same syntax as DITHER.
%
%   Don't use this function directly, use DITHER instead.

%   Copyright 1993-2008 The MathWorks, Inc.  

%#mex

eid = sprintf('Images:%s:missingMexFile', mfilename);
error(eid, sprintf('Missing MEX-file: %s', mfilename));
