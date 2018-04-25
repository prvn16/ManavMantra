function frameflag = isframe(h)
%ISFRAME
%
%   Copyright 1986-2006 The MathWorks, Inc.

% Checks the timeInfo class to see if it defined frames
frameflag = isa(h.TimeInfo,'Simulink.FrameInfo');
