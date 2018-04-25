function descr = getdescription(filename,suppressFnameFlag)
%GETDESCRIPTION  Return the description (or H-1) line for a MATLAB file
%   descr = GETDESCRIPTION(filename)
%   descr = GETDESCRIPTION(filename, suppressFnameFlag)
%   The suppressFnameFlag will stop the filename from appearing in the
%   description line if it is the first word in the description and it is
%   in all upper case.

% Copyright 1984-2017 The MathWorks, Inc.
if nargin > 0
    filename = convertStringsToChars(filename);
end

if nargin < 2
    suppressFnameFlag = getpref('dirtools','suppressFnameFlag',1);
end

helpStr = helpfunc(filename);

% Remove any leading spaces and percent signs
% Grab all the text up to the first carriage return
tokens = regexp(helpStr,'^\s*%*\s*([^\n]*)\n','tokens','once');
if isempty(tokens)
    descr = '';
else
    descr = tokens{1};
end

if suppressFnameFlag
    [pth,shortFilename,ext] = fileparts(filename);
    pattern = ['^' upper(shortFilename) '\s+'];
    descr = regexprep(descr,pattern,'');
end
