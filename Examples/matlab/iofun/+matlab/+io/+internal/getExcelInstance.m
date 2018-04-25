function app = getExcelInstance
%   Copyright 2015 The MathWorks, Inc.

    persistent excelApplication;
    if isempty(excelApplication) || ~isactive || excelApplication.Visible
        % If Excel is not available, this will throw an exception.  If
        % Excel has been made visible, we assume the user opened the
        % worksheet outside MATLAB using the same Excel process, and so we
        % should start a new process.
        excelApplication = actxserver('Excel.Application');
    end
    app = excelApplication;
    
    function tf = isactive
        % Try accessing a readonly property of the COM server to see if it is
        % active.
        try
            get(excelApplication, 'Version');
            tf = true;
        catch
            excelApplication.delete;
            excelApplication = [];
            tf = false;
        end
    end
end
