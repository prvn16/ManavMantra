function [format,workbook,workbookState] = openExcelWorkbook(Excel, filename, readOnly)
    % Opens an Excel Workbook and checks for the correct format.
    %
    % NOTE: The third output 'cleanup' is an onCleanup object that must be 
    % available for the lifetime of the returned 'workbook' variable.
    %
    % Copyright 1984-2015 The MathWorks, Inc.
    
    % Ensure function is called with three output arguments
    nargoutchk(3,3);
    
    % Remember the original Alerts state
    workbookState = Excel.DisplayAlerts;
    
    % Disable DisplayAlerts to Excel won't prompt the user
    Excel.DisplayAlerts = false;
    
    function WorkbookActivateHandler(varargin)
        workbook = varargin{3};
    end

    % It is necessary to wait for the workbook to actually be opened, as
    % the call to Open with an output argument is asynchronous. Using a
    % handler ensures that the handler is called before the call to Open
    % returns, thus ensuring that the interface is the right interface.
    registerevent(Excel,{'WorkbookActivate', @WorkbookActivateHandler});
    Excel.workbooks.Open(filename, 0, readOnly);
    
    [actIncr, actTimeout] = matlab.io.internal.getExcelWorkbookActivationTimeout();

    actStart = tic;
    foundWorkbook = false;
    while toc(actStart) < actTimeout
        if exist('workbook', 'var')
            foundWorkbook = true;
            break;
        end
        pause(actIncr);
    end
    
    if ~foundWorkbook
        throwAsCaller(MException(...
            message('MATLAB:xlsread:WorksheetNotActivated')));
    end
    
    % Activation done %

    format =  waitForValidWorkbook(workbook);
    if strcmpi(format, 'xlCurrentPlatformText')
       throwAsCaller(MException(...
           message('MATLAB:xlsread:FileFormat', filename)));
    end
end

function format = waitForValidWorkbook(ExcelWorkbook)
    % After the event is complete, it may take time to have the workbook be ready.
    % When it is not ready, errors will occur in getting the values of any properties,
    % such as format.
    format = [];
    for i = 1:500
        try
            format = ExcelWorkbook.FileFormat;
            break;
        catch exception %#ok<NASGU>
            pause(0.01);
        end
    end
    % If we still have no format, try one last time, and let the error
    % propagate.
    if isempty(format)
        format = ExcelWorkbook.FileFormat;
    end
end
