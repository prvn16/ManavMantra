%COMPUTER Computer type.
%   C = COMPUTER returns character vector C denoting the type of computer
%   on which MATLAB is executing. Possibilities are:
%
%                                             ISPC ISUNIX ISMAC ARCHSTR    
%   64-Bit Platforms
%     PCWIN64  - Microsoft Windows on x64       1     0     0   win64
%     GLNXA64  - Linux on x86_64                0     1     0   glnxa64
%     MACI64   - Apple Mac OS X on x86_64       0     1     1   maci64
% 
%   ARCHSTR = COMPUTER('arch') returns character vector ARCHSTR which is
%   used by the MEX command -arch switch.
%
%   [C,MAXSIZE] = COMPUTER returns integer MAXSIZE which 
%   contains the maximum number of elements allowed in a matrix
%   on this version of MATLAB.
%
%   [C,MAXSIZE,ENDIAN] = COMPUTER returns either 'L' for
%   little endian byte ordering or 'B' for big endian byte ordering.
%
%   See also ISPC, ISUNIX, ISMAC.

%   Copyright 1984-2015 The MathWorks, Inc.
%   Built-in function.

