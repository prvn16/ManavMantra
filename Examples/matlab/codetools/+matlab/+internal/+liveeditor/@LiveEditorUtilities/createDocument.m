function [javaRichDocument, webWindow] = createDocument()

% Create the rich document object
javaRichDocument = com.mathworks.mde.liveeditor.widget.rtc.RichDocument();

% Set up the web window
webpath = char(javaRichDocument.getWebPath());
url = connector.getUrl(webpath);
webWindow = matlab.internal.webwindow(url);

try
    com.mathworks.mde.liveeditor.widget.rtc.RichDocumentFactory.waitForDocumentToBeReady(javaRichDocument);
catch TimeOutException
    % Get some diagnostic information 
    handleTimeOutException(webWindow);
    rethrow(TimeOutException)
end

end

function handleTimeOutException(webWindow)
% Handle java exception thrown while waiting for the document to initialize
    
    timeout = 60; % 1 minute
    
    % Determine if the java script console is working/busy
    result = webWindow.executeJS('true', timeout);
    if ~strcmp(result, 'true')
        warning('matlab:internal:liveeditor:jsnotworking', 'Unable to run javascript in the console.');
    end
    
    % Check if rtcInstance exists
    result = webWindow.executeJS('if (window.rtcInstance) {true}', timeout);
    if ~strcmp(result, 'true')
        warning('matlab:internal:liveeditor:nonexistentrtc', 'RTC was not created.');
    end    
end

