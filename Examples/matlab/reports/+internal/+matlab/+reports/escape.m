function escapedAction = escape(action)
% Escape a string for use in POST with MATLAB Folder Reports
%   This function is unsupported and might change or be removed without
%   notice in a future version. 


% Copyright 2009-2016 The MathWorks, Inc.

    %escape quotes and slashes
    escapedAction = regexprep(action,'[\\'']','\\$0');
    %escape html-confusing elements
    char(com.mathworks.mlwidgets.html.HTMLUtils.encodeUrl(escapedAction));
end