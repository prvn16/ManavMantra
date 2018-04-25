function clearBreakpoint(filename, requestedBreakpoint)
%   clearBreakpoint clears a breakpoint in the given file
%
%   This function is unsupported and might change or be removed without
%   notice in a future version. 

%   This function tries to clear a breakpoint in MATLAB from the
%   information provided in the given Java breakpoint. 
%
%   clearbreakpoint(filename, requestedBreakpoint)
%     filename  is the MATLAB char array containing the file name to set the breakpoint in.
%     requestedBreakpoint the com.mathworks.mde.editor.breakpoints.MatlabBreakpoint
%                         from which to derive the inputs for the call to
%                         dbclear.

%   Copyright 2012 The MathWorks, Inc.

    doSetBreakpoint(filename, requestedBreakpoint, true);
end
