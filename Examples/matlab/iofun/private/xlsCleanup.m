function xlsCleanup(Excel, filePath, alertState)
    % xlsCleanup helps clean up after the xlsread COM implementation.
    %
    %   See also XLSREAD, XLSWRITE, XLSFINFO.
        
    %   Copyright 1984-2015 The MathWorks, Inc.
    
    % Suppress all exceptions
    try                                                                        %#ok<TRYNC> No catch block
        % Explicitly close the file just in case.  The Excel API expects just the
        % filename and not the path.  This is safe because Excel also does not
        % allow opening two files with the same name in different folders at the
        % same time.
        [~, name, ext] = fileparts(filePath);
        fileName = [name ext];
        Excel.Workbooks.Item(fileName).Close(false);
        Excel.DisplayAlerts = alertState;
    end
end