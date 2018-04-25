function addDDUXLogging(toolGroup,productName,appName)
% addDDUXLogging - Add Data Driven User Experience logging to MCOS
% Toolstrip app

% Copyright 2017 The MathWorks, Inc.

% Provide product name (e.g. 'Image Processing Toolbox')
toolGroup.Peer.getWrappedComponent.putGroupProperty( ...
    com.mathworks.widgets.desk.DTGroupProperty.USAGE_DATA_PRODUCT, productName);

% Provide app name (e.g. 'Image Segmenter')
toolGroup.Peer.getWrappedComponent.putGroupProperty( ...
    com.mathworks.widgets.desk.DTGroupProperty.USAGE_DATA_SCOPE, appName);

end