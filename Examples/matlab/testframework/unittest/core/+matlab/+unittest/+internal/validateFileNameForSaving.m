function fileName = validateFileNameForSaving(fileName,expectedException)
% This function is undocumented and may change in a future release.

%  Copyright 2017 The MathWorks, Inc.

validateattributes(fileName,{'char','string'},{'scalartext'},'','fileName');
fileName = char(fileName);
validateattributes(fileName,{'char'},{'nonempty'},'','fileName');

[~, ~, extension] = fileparts(fileName);
if isempty(extension) && ~isempty(expectedException)
    error(message('MATLAB:unittest:FileIO:MissingFileExtension',expectedException))
elseif ~strcmpi(extension,expectedException)
    error(message('MATLAB:unittest:FileIO:WrongFileExtension',expectedException));
end
fileName = matlab.unittest.internal.parentFolderResolver(fileName);
end

% LocalWords:  scalartext unittest
