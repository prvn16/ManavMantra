function result = setBreakpoint(filename, requestedBreakpoint)
%setbreakpointandreturnerror sets a breakpoint in the given file and
%
%   This function is unsupported and might change or be removed without
%   notice in a future version. 

%   This function tries to install a breakpoint in MATLAB from the
%   information provided in the given Java breakpoint. 
%
%   If a 'MATLAB:class:NotOnPath' error is encountered during breakpoint
%   installation, an appropriate dialog will be shown. If a 
%   'MATLAB:lineBeyondFileEnd' is encountered, the error will be silently
%   ignored. If any other error occurs, a dialog with that message will be
%   shown.
% 
%   result = setbreakpoint(filename, requestedBreakpoint)
%     filename  is the MATLAB char array containg the file name to set the breakpoint in.
%     requestedBreakpoint the com.mathworks.mde.editor.breakpoints.MatlabBreakpoint
%                         from which to derive the inputs for the call to
%                         dbstop.
%    result a BreakpointInstallationResult with the status of the operation.

%   Copyright 2009 The MathWorks, Inc.

    import com.mathworks.mde.editor.breakpoints.BreakpointInstallationResult;
    import java.io.File;

    try
        doSetBreakpoint(filename, requestedBreakpoint);
        result = BreakpointInstallationResult.createSuccessfulResult(File(filename));
    catch exception
        result = handleDbStopException(exception, filename);
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
            % silently ignore this error.
        case 'MATLAB:class:NotOnPath'
            message = exception.message;
            status = DbStopStatus.CLASS_NOT_ON_PATH;
        otherwise
            message = exception.message;
            status = DbStopStatus.OTHER_EXCEPTION;
    end
    
    result = BreakpointInstallationResult(File(filename), message, status);
end