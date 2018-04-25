% Returns a single string containing the report HTML
function htmlStringOut = createReportHtmlString(reportID)
    htmlStringOut = eval(reportID);
    % contentsrpt, deprpt, coveragerpt, and mlintrptCurrentFolder return a cell array of strings, so need to be converted to a single string
    % The other reports (dofixrpt, helprpt) already return a single string
    if strcmp(reportID, 'contentsrpt') || strcmp(reportID, 'deprpt') || strcmp(reportID, 'coveragerpt') || strcmp(reportID, 'internal.matlab.reports.mlintrptCurrentFolder')
        htmlStringOut = [htmlStringOut{:}];
    end
end