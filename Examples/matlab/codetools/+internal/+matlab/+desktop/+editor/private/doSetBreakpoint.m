function doSetBreakpoint(filename, requestedBreakpoint, clearFlag)
%   setBreakpoint sets or clears a breakpoint in the given file based on the contents of the given Java breakpoint.
%
%   This class is unsupported and might change or be removed without
%   notice in a future version. 

%   doSetBreakpoint(filename, requestedBreakpoint, clearFlag)
%     filename  is the MATLAB char array containing the file name to set the breakpoint in.
%     requestedBreakpoint the com.mathworks.mde.editor.breakpoints.Breakpoint
%                         from which to derive the inputs for the call to
%                         dbstop.  If empty and clearFlag is set, clear all
%                         breakpoints in the specified file.
%     clearFlag indicates that the breakpoint is to be cleared rather than set

%   Copyright 2009-2017 The MathWorks, Inc.

    import com.mathworks.mde.editor.breakpoints.MatlabBreakpoint;

    % ensure that the input arguments are of the expeted Java types.
    checkFilename(filename);

    % reverse any mapping that might have been applied to filename
    filename = unmapFile(filename);

    if (isempty(requestedBreakpoint) && (nargin == 3) && clearFlag)
        dbclear('-completenames', filename);
        return;
    end

    checkBreakpoint(requestedBreakpoint);

    lineNumberString = int2str(requestedBreakpoint.getOneBasedLineNumber);
    
    if (requestedBreakpoint.isAnonymous)
        anonymousFunctionIndexString = int2str(requestedBreakpoint.getAnonymousIndex);
        lineNumberString = [lineNumberString '@' anonymousFunctionIndexString];
    end
    if ((nargin < 3) || (clearFlag == false))
        expressionString = char(requestedBreakpoint.getWrappedExpression);
        dbstop('-completenames', filename, lineNumberString, 'if', expressionString);
    else
        dbclear('-completenames', filename, lineNumberString);
    end
end
