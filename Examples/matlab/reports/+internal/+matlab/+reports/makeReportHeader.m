function htmlOut = makeReportHeader( reportName, help, docPage, rerunAction, runOnThisDirAction )
% MAKEREPORTHEADER  Add a head for HTML report file.
%   Use locale to determine the appropriate charset encoding.
%
% makeReportHeader( reportName, help, docPage, rerunAction, runOnThisDirAction )
%    reportName: the full name of the report
%    help: the report description
%    docpage: the html page in the matlab environment CSH book
%    rerunAction: the matlab command that would regenerate the report
%    runOnThisDirAction: the matlab command that generates the report for the cwd
%
%   Note: <html> and <head> tags have been opened but not closed. 
%   Be sure to close them in your HTML file.

%   Copyright 2009-2016 MathWorks, Inc.

import com.mathworks.matlab.api.explorer.MatlabPlatformUtil;

htmlOut = {};

%% XML information
h1 = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
h2 = '<html xmlns="http://www.w3.org/1999/xhtml">';

% Use charset=UTF-8, g589137 g589371
encoding = 'UTF-8';
h3 = sprintf('<head><meta http-equiv="Content-Type" content="text/html; charset=%s" />',encoding);

% CSS
h4 = internal.matlab.reports.createReportHeaderCss;

% JavaScript
h5 = internal.matlab.reports.createReportHeaderJs;

%% HTML header
htmlOut{1} = [h1 h2 h3 h4 h5];

htmlOut{2} = sprintf('<title>%s</title>', reportName);
htmlOut{3} = '</head>';
htmlOut{4} = '<body>';
htmlOut{5} = sprintf('<div class="report-head">%s</div><p>', reportName);

learnMoreTag = sprintf(['<a href="matlab:helpview([docroot ''/matlab/helptargets.map''], ''%s'')">' ...
    '%s</a>'],  docPage, getString(message('MATLAB:codetools:reports:LearnMore'))); 

% For now, include the "Learn More" help link only in MATLAB desktop
% TODO: add "Learn More" help link in MATLAB Online (g1564303)
if MatlabPlatformUtil.isMatlabOnline
    reportDescription = help;
else
    reportDescription = [help ' ' getString(message('MATLAB:codetools:reports:LearnMoreParen', learnMoreTag))];
end

%% Descriptive text
htmlOut{6} = ['<div class="report-desc">' reportDescription '</div>'];

%% Rerun report buttons 
% For now, include the "Rerun This Report" and "Run Report on Current Folder" buttons only in MATLAB desktop,
% since currently these buttons directly execute MATLAB report commands, which is not what we want in MATLAB Online.
% TODO: add these buttons in MATLAB Online (g1564302)
if ~MatlabPlatformUtil.isMatlabOnline
    htmlOut{end+1} = '<table border="0"><tr>';
    htmlOut{end+1} = '<td>';

    htmlOut{end+1} = sprintf('<input type="button" value="%s" id="rerunThisReport" onclick="runreport(''%s'');" />',...
        getString(message('MATLAB:codetools:reports:RerunReport')), internal.matlab.reports.escape(rerunAction));
    htmlOut{end+1} = '</td>';

    htmlOut{end+1} = '<td>';
    htmlOut{end+1} = sprintf('<input type="button" value="%s" id="runReportOnCurrent" onclick="runreport(''%s'');" />',...
        getString(message('MATLAB:codetools:reports:RunReport')), internal.matlab.reports.escape(runOnThisDirAction));
    htmlOut{end+1} = '</td>';

    htmlOut{end+1} = '</tr></table>';
end
end

