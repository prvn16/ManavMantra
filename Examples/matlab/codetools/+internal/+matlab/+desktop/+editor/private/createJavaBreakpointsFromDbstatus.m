function javaBreakpoints = createJavaBreakpointsFromDbstatus(matlabBreakpoints)
%createjavabreakpointsfromdbstatus creates Java breakpoints from the given MATLAB breakpoints.
%
%   This function is unsupported and might change or be removed without
%   notice in a future version. 

%   javaBreakpoints = createjavabreakpointsfromdbstatus(matlabBreakpoints)
%     matlabBreakpoints the output of dbstatus.
%     javaBreakpoints is a java.util.List of
%                     com.mathworks.mde.editor.breakpoints.Breakpoints 
%                     extracted from the given dbstatus entries.

%   Copyright 2009 The MathWorks, Inc.
    
    import java.util.ArrayList;

    javaBreakpoints = ArrayList;
    
    % iterate over all the entries in dbstatus and extract the breakpoints
    % from each entry. note that a given entry my contain multiple
    % breakpoints.
    for i=1:length(matlabBreakpoints)
        dbStatusEntry = matlabBreakpoints(i);
        javaBreakpointsForDbStatusEntry = extractFilesBreakpoints(dbStatusEntry);
        javaBreakpoints.addAll(javaBreakpointsForDbStatusEntry);
    end
    
end

function javaBreakpoints = extractFilesBreakpoints(dbStatusEntry)
% extractFilesBreakpoints extracts a java.util.List of com.mathworks.mde.editor.MatlabBreakpoints 
%                         from the given dbstatus entry.
    import com.mathworks.mde.editor.breakpoints.MatlabBreakpoint;
    import com.mathworks.mde.editor.breakpoints.MatlabBreakpointUtils;
    import java.io.File;
    import java.util.ArrayList;
    
    javaBreakpoints = ArrayList;
    
    numBreakpoints = length(dbStatusEntry.line);
    file = File(dbStatusEntry.file);
    
    for i=1:numBreakpoints
        zeroBasedLineNumber = dbStatusEntry.line(i) - 1;
        anonymousFunctionIndex = dbStatusEntry.anonymous(i);
        expression = dbStatusEntry.expression{i};
        
        if MatlabBreakpoint.isLineBreakpoint(anonymousFunctionIndex)
            breakpoint = MatlabBreakpoint.create(zeroBasedLineNumber, expression, file);
        else
            breakpoint = MatlabBreakpoint.createAnonymous(zeroBasedLineNumber, anonymousFunctionIndex, expression, file);
        end
        
        javaBreakpoints.add(breakpoint);
    end
    
end