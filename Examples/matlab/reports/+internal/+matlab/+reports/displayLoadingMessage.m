function displayLoadingMessage( reportName )
%
%   This function is unsupported and might change or be removed without
%   notice in a future version.

%DISPLAYLOADINGMESSAGE displays the loading... in the web browser for a
%directory report

% Copyright 2009-2016 The MathWorks, Inc.

header = ['<head><title>' reportName '</title></head>'];
currentMessage = ['text://<html>' header '<body>'...
    getString(message('MATLAB:codetools:reports:GeneratingReport', reportName))...
    '</body></html>'];
web(currentMessage,'-noaddressbox');

end

