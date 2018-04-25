function onNewData(this, source)
%ONNEWDATA React to the new data event.

%   Copyright 2010-2017 The MathWorks, Inc.

rawData = getRawData(source, 1);
if this.InputNeedsValidation
    validateVisual(this.Application);
    this.InputNeedsValidation = ~this.IsSourceValid;
end

dataTypeString = getDataTypes(this.Application.DataSource,1);
try
    dataTypeObject = fixdt(dataTypeString);
catch e
    dataTypeObject = [];
end
% Defer the task to the NTX object
updateBar(this.NTExplorerObj, rawData, dataTypeObject);

% [EOF]
