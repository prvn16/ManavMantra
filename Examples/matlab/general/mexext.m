function [varargout] = mexext(varargin)
%MEXEXT MEX filename extension for this platform, or all platforms. 
%   EXT = MEXEXT returns the MEX-file name extension for the current
%   platform. 
%
%   ALLEXT = MEXEXT('all') returns a struct with fields 'arch' and 'ext' 
%   describing MEX-file name extensions for all platforms.
%
%   There is a script named mexext.bat on Windows and mexext.sh on UNIX
%   that is intended to be used outside MATLAB in makefiles or scripts. Use
%   that script instead of explicitly specifying the MEX-file extension in
%   a makefile or script. The script is located in $MATLAB\bin.
%
%   See also MEX, MEXDEBUG.

%   Copyright 1984-2005 The MathWorks, Inc. 
%   Built-in function.

