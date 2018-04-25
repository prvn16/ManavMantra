function out = durationToggleSharedFcn(durationType, fcn, in)
%durationToggleFcn Toggle between numeric and duration
%   Shared implementation for hours, minutes, seconds etc.

% Copyright 2016-2017 The MathWorks, Inc.

assert(istall(in)); % Should only get here with tall input
adaptor = in.Adaptor;
if strcmp(adaptor.Class, durationType)
    outAdap = matlab.bigdata.internal.adaptors.GenericAdaptor('double');
else
    in = tall.validateType(in, func2str(fcn), {'numeric', 'logical', durationType}, 1);
    % Call the in-memory version to obtain the default format
    tmp = fcn(1);
    outAdap = matlab.bigdata.internal.adaptors.DatetimeFamilyAdaptor(durationType, tmp.Format);
end
out = elementfun(fcn, in);
out.Adaptor = copySizeInformation(outAdap, out.Adaptor);
end
