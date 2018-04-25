function [id, msg] = validateFormatString(fmt, varargin)
% This is an undocumented function and may be removed in a future release.

% Validate that a format string is valid for use in sprintf.

%   Copyright 2017 The MathWorks, Inc.

% Store and clear the last warning state, and restore after calling sprintf.
[lastmsg, lastid] = lastwarn('','');
c1 = onCleanup(@()lastwarn(lastmsg, lastid));

% Store the warning settings and restore after calling sprintf.
s = warning('query');
c2 = onCleanup(@()warning(s));

% Turn off all warnings.
warning('off','all');

% Call sprintf with the format string.
sprintf(fmt, varargin{:});

% Query whether any warnings were issued.
[msg, id] = lastwarn;

end
