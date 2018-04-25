function wrapped = wrapHeader(str)
% This function is undocumented.

%  Copyright 2012-2015 MathWorks, Inc.

import matlab.internal.display.wrappedLength;

dashes = repmat('-', 1, ceil(wrappedLength(str)));
wrapped = sprintf('%s\n%s\n%s', dashes, str, dashes);
end
