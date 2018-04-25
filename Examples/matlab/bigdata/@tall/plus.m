function out = plus(ta, tb)
%+   Plus.

% Copyright 2016-2017 The MathWorks, Inc.

[ta, tb] = tall.validateType(ta, tb, mfilename, ...
    {'numeric', 'logical', 'char', ...
    'duration', 'datetime', 'calendarDuration', ...
    'string', 'cellstr'}, ...
    1:2);

ca = tall.getClass(ta);
cb = tall.getClass(tb);

import matlab.bigdata.internal.adaptors.DatetimeFamilyAdaptor;
import matlab.bigdata.internal.adaptors.GenericAdaptor;
import matlab.bigdata.internal.adaptors.StringAdaptor;

% If either is datetime, then output is datetime (unless both are datetime)
% Else, if either is calendarDuration, output is calendarDuration
% Else, if either is duration, output is duration
% Else, output unknown
if any(strcmp({ca, cb}, 'datetime'))
    if all(strcmp({ca, cb}, 'datetime'))
        error(message('MATLAB:datetime:DatetimeAdditionNotDefined'));
    end
    outAdaptor = DatetimeFamilyAdaptor('datetime');
elseif any(strcmp({ca, cb}, 'calendarDuration'))
    outAdaptor = DatetimeFamilyAdaptor('calendarDuration');
elseif any(strcmp({ca, cb}, 'duration'))
    outAdaptor = DatetimeFamilyAdaptor('duration');
elseif any(strcmp({ca, cb}, 'string'))
    % PLUS on strings is special in that chars get converted to strings,
    % thus changing their size. Output is guaranteed to be string.
    outAdaptor = StringAdaptor();
    % Convert any non-string input to string to ensure the resulting
    % operation is still elementwise.
    if ~strcmp(ca,'string')
        ta = string(ta);
    end
    if ~strcmp(cb,'string')
        tb = string(tb);
    end
else
    cc = calculateArithmeticOutputType(ca, cb);
    outAdaptor = matlab.bigdata.internal.adaptors.getAdaptorForType(cc);
end
out = elementfun(@plus, ta, tb);
out.Adaptor = copySizeInformation(outAdaptor, out.Adaptor);
end
