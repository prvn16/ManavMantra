function lineLength = getLineLength(hStringBuffer)
% Returns the length of the last line entered

% Copyright 2006 The MathWorks, Inc.

if isempty(hStringBuffer.Text)
    lineLength = 0;
else
    lineLength = length(hStringBuffer.Text{end});
end