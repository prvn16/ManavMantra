function str = opengl(~, ~)
%OPENGL Change OpenGL rendering method.
%   OPENGL INFO prints information with the Version and Vendor of the OpenGL
%   implementation of your system.  This command loads the OpenGL Library. 
%   H = OPENGL('INFO') returns 1 if OpenGL is available on your system and 0 otherwise.
%   D = OPENGL('DATA') returns a structure containing the same data printed
%   when OPENGL INFO is called.
%
%   OPENGL SOFTWARE uses the software version of OpenGL to render subsequent graphics.
%   Note: To use software OpenGL on Linux, you must start MATLAB with the softwareopengl
%   startup option. Macintosh systems do not support software OpenGL.
%
%   OPENGL HARDWARE uses the hardware-accelerated version of OpenGL to render subsequent
%   graphics.  If you do not have hardware-acceleration, MATLAB switches to software OpenGL
%   rendering.
%
%   OPENGL HARDWAREBASIC uses the basic hardware-accelerated version of OpenGL to render
%   subsequent graphics.  This disables hardware features that cause instability with certain
%   graphics drivers.  If you do not have hardware-acceleration, MATLAB switches to software
%   OpenGL rendering.
%
%   Note: Use OPENGL INFO to determine if software, hardware, or hardware basic rendering
%   is being used.
%
%   OPENGL SAVE SOFTWARE sets your preferences so that future sessions of MATLAB use
%   software OpenGL to render graphics. This command does not affect the current session.
%
%   OPENGL SAVE HARDWARE sets your preferences so that future sessions of MATLAB use
%   hardware-accelerated OpenGL to render graphics. This command does not affect the current
%   session.
%
%   OPENGL SAVE HARDWAREBASIC sets your preferences so that future sessions of MATLAB use
%   basic hardware-accelerated OpenGL to render graphics. This command does not affect the
%   current session.
%
%   OPENGL SAVE NONE resets your preferences so that future sessions of MATLAB use
%   the MATLAB default.  This command does not affect the current session.

%
%  OPENGL options removed in r2014b
%
%  OPENGL AUTOSELECT
%  OPENGL NEVERSELECT
%  OPENGL ADVISE
%  OPENGL VERBOSE
%  OPENGL QUIET
%  OPENGL('BUGNAME', 0)
%  OPENGL('BUGNAME', 1)
%
%   Copyright 1984-2017 The MathWorks, Inc.
