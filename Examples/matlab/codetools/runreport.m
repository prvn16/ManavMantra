function runreport(rptname)
%RUNREPORT  Run the specified report
%   This file functions as an error-catching wrapper for the directory
%   reports in the current directory browser.

% Copyright 1984-2011 The MathWorks, Inc.

try
    feval(rptname);
catch myException
    errMsg = ['<html><body><span style="color:#F00">', getString(message('MATLAB:codetools:reports:ErrorGeneratingReportMessage', myException.message)), '</span></body></html>'];
    web(['text://' errMsg],'-noaddressbox');
end
