function emph = emphasizeText(varargin)
%emphasizeText - wrap text with <strong></strong> if supported

% Copyright 2015 The MathWorks, Inc.

str = sprintf(varargin{:});
if matlab.internal.display.isHot
    emph = sprintf('<strong>%s</strong>', str);
else
    emph = sprintf('%s', str);
end
end
