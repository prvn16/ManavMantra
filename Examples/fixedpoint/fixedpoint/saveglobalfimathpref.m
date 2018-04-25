function saveglobalfimathpref
% SAVEGLOBALFIMATHPREF Save global fimath as a MATLAB preference
%
%    Do not save globalfimath as a MATLAB preference. 'saveglobalfimathpref' is 
%    obsolete and will be removed in a future release. If you have previously 
%    saved global fimath as a MATLAB preference, use 'removeglobalfimathpref' 
%    to remove it.
%
%
%    See also REMOVEGLOBALFIMATHPREF, GLOBALFIMATH, RESETGLOBALFIMATH

%   Copyright 2003-2012 The MathWorks, Inc.

%
error(message('fixed:fimath:unsupportedSaveGlobalfimathPref'));

