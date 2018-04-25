function stripanchors
%STRIPANCHORS Remove anchors that evaluate MATLAB code from Profiler HTML
%   This function is unsupported and might change or be removed without
%   notice in a future version.
%
%   STRIPANCHORS displays stripped-down HTML from the Profiler in a new
%   HTML window, thereby allowing users to compare two profiling runs
%   without causing problems with stale file information.
%
%   See also PROFVIEW.

%   Copyright 1984-2011 The MathWorks, Inc.

%   Ned Gulley, Mar 2002

str = char(com.mathworks.mde.profiler.Profiler.getHtmlText);

% The question mark makes the .* wildcard non-greedy
str = regexprep(str,'<a.*?>','');
str = regexprep(str,'</a>','');
str = regexprep(str,'<form.*?</form>','');
disabledLinkText = message('MATLAB:profiler:LinksDisabled'); 
str = strrep(str,'<body>',['<body bgcolor="#F8F8F8"><strong>', disabledLinkText.getString(), '</strong><p>']);

web('-new', '-noaddressbox', ['text://' str]);