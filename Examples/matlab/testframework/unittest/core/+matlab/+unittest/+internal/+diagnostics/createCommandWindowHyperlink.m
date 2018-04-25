function link = createCommandWindowHyperlink(content, title)
% createCommandWindowHyperlink - Format a string as a hyperlink.
%   LINK = createCommandWindowHyperlink(CONTENT, TITLE) returns a string
%   that is displayed as a hyperlink in the Command Window. Initially, only
%   the text in TITLE is displayed. When this link is clicked, the
%   hyperlink prints out the text in CONTENT. CONTENT can have any
%   arbitrary ASCII characters in it. TITLE should have only alphanumeric
%   characters.

% Copyright 2012 The MathWorks, Inc.

link = sprintf('<a href="matlab:matlab.unittest.internal.diagnostics.displayToCommandWindowAsText(%s);">%s</a>', ...
    mat2str(double(content)), title);
end