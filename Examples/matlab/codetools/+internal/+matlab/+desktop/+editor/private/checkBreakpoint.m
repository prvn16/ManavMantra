function checkBreakpoint(breakpoint)
%checkBreakpoint checks that the given variable is a com.mathworks.mde.editor.breakpoints.Breakpoint. 

% Copyright 2009-2011 The MathWorks, Inc.

    if (~isa(breakpoint, 'com.mathworks.mde.editor.breakpoints.MatlabBreakpoint'))
        error(message('MATLAB:Editor:NotABreakpoint'));
    end
end