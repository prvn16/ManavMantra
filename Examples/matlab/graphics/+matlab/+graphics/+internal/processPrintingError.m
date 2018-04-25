function ex = processPrintingError(e, pj)
%PROCESSPRINTINGERROR Helper function for print

% Copyright 2013-2017 The MathWorks, Inc.

ex = [];
if ~isa(e, 'matlab.exception.JavaException')
    % This function only processes various Java-sourced exceptions
    return
end

if nargin < 2
    % if no printjob provided, assume we're not trying to use clipboard and
    % we're not interested in debug info 
    pj.DebugMode = false;
    goingToClipboard = false;
else
    % might be going to clipboard, and if there's an out of memory error
    % there are some things the user can try so we'll customize the message
    % for them...
    goingToClipboard = pj.DriverClipboard && isempty(pj.FileName);
end

je = e.ExceptionObject;
if isa(je, 'com.mathworks.hg.util.OutputHelperProcessingException')
    % Extract the underlying cause of the processing error - if one was provided
    if ~isempty(je.getCause)
        je = je.getCause();
    end
end
% Extract the message - it might be an error ID
msg = je.getMessage();

PrintMsgID = 'MATLAB:print:';
if isa(je, 'java.lang.OutOfMemoryError')
    if goingToClipboard 
        ex = MException(message('MATLAB:print:clipboardCopyFailed'));
    else
        ex = MException(message('MATLAB:print:JavaHeapSize'));    
    end
elseif isa(je, 'com.mathworks.hg.util.HGRasterOutputHelper$RasterSizeException')
    ex = MException(message('MATLAB:print:InvalidRasterOutputSize'));
elseif ~isempty(msg) && strncmp(msg, PrintMsgID, length(PrintMsgID))
    ex = MException(message(msg.toCharArray'));
end

if ~isempty(ex)
    if pj.DebugMode
        % Add the cause as extra debugging information.
        ex = ex.addCause(e);
    end
    
    ex.throwAsCaller()
end
end
