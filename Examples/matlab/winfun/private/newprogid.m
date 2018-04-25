function convertedProgID = newprogid(progID)
% Copyright 1984-2004 The MathWorks, Inc.

convertedProgID = regexprep(progID, '_', '__');
convertedProgID = regexprep(convertedProgID, '-', '___');
convertedProgID = regexprep(convertedProgID, '\.', '_');
convertedProgID = regexprep(convertedProgID, ' ', '____');
convertedProgID = regexprep(convertedProgID, '&', '_____');


