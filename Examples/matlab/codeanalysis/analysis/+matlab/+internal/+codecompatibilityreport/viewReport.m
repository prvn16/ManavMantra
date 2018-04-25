function viewReport(analysisResults)
%viewReport Display the JavaScript report
%   viewReport launches the report in a MATLAB web browser and displays the
%   data from the CodeCompatiblityAnalysis input object

%   Copyright 2017 The MathWorks, Inc.

    [~, clientId] = fileparts(tempname);
    import matlab.internal.codecompatibilityreport.getPackagedResults;
    formattedResults = getPackagedResults(analysisResults);
    matlab.internal.codecompatibilityreport.PublishData(clientId, formattedResults);

    hostInfo = connector.ensureServiceOn;
    if hostInfo.running == 1
        url = matlab.internal.codecompatibilityreport.getConnectorUrl(clientId);
        web(url,'-new','-notoolbar');
    end
end
