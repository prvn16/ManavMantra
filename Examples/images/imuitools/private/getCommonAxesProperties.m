function s = getCommonAxesProperties
%getCommonAxesProperties returns common axes properties for proper image display.
%   S = getCommonAxesProperties returns a structure containing the common
%   axes properties for image display.  This is used by IMPIXELREGIONPANEL and
%   IMOVERVIEWPANEL.
  
%   Copyright 2005 The MathWorks, Inc.

s.YDir                   = 'reverse';
s.TickDir                = 'out';
s.XGrid                  = 'off';
s.YGrid                  = 'off';
s.DataAspectRatio        = [1 1 1];
s.PlotBoxAspectRatioMode = 'auto';
