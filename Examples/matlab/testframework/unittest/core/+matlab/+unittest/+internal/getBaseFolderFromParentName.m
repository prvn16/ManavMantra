function baseFolder = getBaseFolderFromParentName(testParentName)

% Copyright 2016 The MathWorks, Inc.

import matlab.unittest.internal.whichFile;

baseFolder = fileparts(whichFile(testParentName));

% Remove package and class folders
baseFolder = regexprep(baseFolder,['\' filesep '(+|@).*$'],'');
end

