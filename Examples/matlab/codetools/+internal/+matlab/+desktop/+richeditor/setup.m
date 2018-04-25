function port = setup()
%Set up and configure the MATLAB Connector in support of Rich Scripts. 
%
%   This function is unsupported and might change or be removed without
%   notice in a future version.

%   Copyright 2014 The MathWorks, Inc.

import com.mathworks.services.editordataservice.EditorDataServiceManager;
import com.mathworks.services.clipboardservice.ConnectorClipboardService;

connectorInfo = connector.ensureServiceOn;

connector.isRunning;

port = connectorInfo.port;

% Initialize Editor Data Service in support of Editor features.
editorDataServiceManager = EditorDataServiceManager.getInstance();
editorDataServiceManager.initialize();

% Initialize ConnectorClipboardService for the ConnctorClipboard.
ConnectorClipboardService.getInstance();
end

