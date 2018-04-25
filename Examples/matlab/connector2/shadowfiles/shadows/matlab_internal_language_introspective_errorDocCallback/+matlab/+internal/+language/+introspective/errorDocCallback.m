function errorDocCallback(topic, varargin)
if ~isempty(help(topic, '-noDefault'))
    help(topic);
else
    edit(topic)
end
end

%   Copyright 2011 The MathWorks, Inc.
