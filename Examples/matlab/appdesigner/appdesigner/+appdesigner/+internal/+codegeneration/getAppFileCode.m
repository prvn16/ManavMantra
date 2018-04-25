function code = getAppFileCode(filePath)
% reads app code from a mlapp file specified by filePath which is the full
% fule path to a mlapp file

% Copyright 2016 The MathWorks, Inc.

import appdesigner.internal.serialization.FileReader;

if exist(filePath, 'file')
    fileReader = FileReader(filePath);
    code = fileReader.readMATLABCodeText();
else 
    code = '';
end