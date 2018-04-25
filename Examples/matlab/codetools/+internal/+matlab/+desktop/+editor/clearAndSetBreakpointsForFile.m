function result = clearAndSetBreakpointsForFile(filename, requestedBreakpoints)
%syncbreakpoints is a bridge between the Java breakpoints display and MATLAB
%   This function clears the breakpoints for the given file, and then
%   installs the given breakpoints, which should all be breakpoints for the
%   given file.
%
%   If errors occur during the clearing of breakpoints, they will be
%   quietly ignored.
%
%   If the following errors occur during the breakpoint installation
%   process, they will be quietly ignored:
%
%       * MATLAB:lineBeyondFileEnd
%       * MATLAB:no_anonymous_function_on_line
%       * MATLAB:not_enough_anonymous_functions_on_line
%
%   All other errors will result in a dialog with the exception message
%   being shown, and that exception message will be returned to the caller
%   to indicate a failure.
%
%   This function is unsupported and might change or be removed without
%   notice in a future version. 

%   result = clearAndSetBreakpointsForFile(filename, requestedBreakpoints)
%     filename is the MATLAB char array containing the file name to sync the 
%              given breakpoints for.
%     requestedBreakpoints is a java.util.Collection of
%                          com.mathworks.mde.editor.breakpoints.MatlabBreakpoints that the MATLAB Editor
%                          currently thinks are the given file's breakpoints.
%     result the BreakpointInstallationResult of setting the breakpoints.

%   Copyright 2009-2010 The MathWorks, Inc.

    % ensure that the input arguments are of the expected Java types.
    checkFilename(filename);
    checkCollection(requestedBreakpoints);

    % clear what MATLAB currently thinks the given files breakpoints are.
    quietlyClearBreakpoints(filename);
    
    % WORKAROUND: calling drawnow flushes the interest registry, which
    % ensures that  the Java code gets the breakpoint remove events 
    % *before* the breakpoint add events. <add geck here>
    drawnow;
    
    % set the given breakpoints in MATLAB. capture any errors that occur
    % during this process.
    result = quietlySetBreakpoints(filename, requestedBreakpoints);
    
end

% Utility functions. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = quietlySetBreakpoints(filename, requestedBreakpoints)
    
    import com.mathworks.mde.editor.breakpoints.BreakpointInstallationResult;
    import java.io.File;
    
    % start off with a successful result. if an exception occurs, we'll
    % change this value.
    result = BreakpointInstallationResult.createSuccessfulResult( ...
        File(filename));
    
    cellArrayOfBreakpoints = matlab.desktop.editor.EditorUtils.javaCollectionToArray(requestedBreakpoints);
    for i=1:length(cellArrayOfBreakpoints)
        % try to install current Java breakpoint, catching all errors that
        % may occur.
        try
            doSetBreakpoint(filename, cellArrayOfBreakpoints{i});
        catch exception
            result = handleDbStopException(exception, filename);
        end
        
        % if the exception that occurred was one that cannot be ignored,
        % then stop trying to install breakpoints and return.
        if result.errorOccurred
            break;
        end
    end
end

function result = handleDbStopException(exception, filename)
%handleDbStopException handles exceptions that may be thrown when calling dbstop.
    import com.mathworks.mde.editor.breakpoints.BreakpointDialogs;
    import com.mathworks.mde.editor.breakpoints.BreakpointInstallationResult;
    import com.mathworks.mde.editor.breakpoints.DbStopStatus;
    import com.mathworks.mde.editor.breakpoints.MatlabBreakpointUtils;
    import java.io.File;
    
    message = '';
    status = DbStopStatus.SUCCESS;
    
    switch exception.identifier
        case 'MATLAB:lineBeyondFileEnd'
            % quietly ignore this case.
        case 'MATLAB:lang:BreakpointInAnonymousFunctionInScript'
            % quietly ignore this case.
        case 'MATLAB:not_enough_anonymous_functions_on_line'
            % quietly ignore this case.
        case 'MATLAB:class:NotOnPath'
            message = exception.message;
            status = DbStopStatus.CLASS_NOT_ON_PATH;
        otherwise
            message = exception.message;
            status = DbStopStatus.OTHER_EXCEPTION;
    end
    result = BreakpointInstallationResult(File(filename), message, status);
end

function quietlyClearBreakpoints(filename)
%quietlyClearBreakpoints calls dbclear on the given file and swallows resultant errors.
    try
        doSetBreakpoint(filename, [], true);
    catch exception %#ok<NASGU>
        % quietly ignore.
    end
end
