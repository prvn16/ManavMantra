function javaBreakpoints = breakpointsForAllFiles
%breakpointsforallfiles gets a list of all breakpoints currently set in MATLAB.
%
%   This function is unsupported and might change or be removed without
%   notice in a future version. 

%   javaBreakpoints = breakpointsforallfiles
%     javaBreakpoints is a java.util.List of
%                     com.mathworks.mde.editor.breakpoints.MatlabBreakpoints 
%                     that are currently set in MATLAB.

%   Copyright 2009 The MathWorks, Inc.
    
    matlabBreakpoints = dbstatus('-completenames');  
    javaBreakpoints = createJavaBreakpointsFromDbstatus(matlabBreakpoints);
end