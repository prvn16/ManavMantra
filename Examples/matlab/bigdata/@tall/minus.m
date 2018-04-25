function out = minus(ta, tb)
%-  Minus.

% Copyright 2016-2017 The MathWorks, Inc.

% Note we do not support "datetime() - '2016-01-27'" syntax since we don't have
% strong types for char/string/cellstr.
[ta, tb] = tall.validateType(ta, tb, mfilename, ...
    {'numeric', 'logical', 'duration', 'datetime', 'calendarDuration', 'char'}, ...
    1:2);

% Work out the output adaptor by copying one of the input adaptors (so that
% format etc is copied).
adap_a = matlab.bigdata.internal.adaptors.getAdaptor(ta);
adap_b = matlab.bigdata.internal.adaptors.getAdaptor(tb);
outAdaptor = iDetermineOutputAdaptor(adap_a, adap_b);

out = elementfun(@minus, ta, tb);
out.Adaptor = copySizeInformation(outAdaptor, out.Adaptor);
end


function outAdaptor = iDetermineOutputAdaptor(adap_a, adap_b)
% Helper to try and determine the correct output type given two input
% adaptors.

ca = adap_a.Class;
cb = adap_b.Class;

% Superiority goes: datetime > calendarDuration > duration
% Empty types are presumed numeric.
if strcmp(ca, 'datetime')
    if strcmp(cb, 'datetime')
        outAdaptor = matlab.bigdata.internal.adaptors.getAdaptorForType('duration');
    else
        outAdaptor = resetSizeInformation(adap_a);
    end
else
    if strcmp(cb, 'datetime')
        msg = message('MATLAB:bigdata:array:SubstractDatetimeFrom');
        throwAsCaller(MException(msg.Identifier, '%s', getString(msg)));
    end
    
    % Check for calendarDuration first as it is dominant.
    if strcmp(ca, 'calendarDuration')
        % Careful with Format if both calendarDurations
        if strcmp(cb, 'calendarDuration')
            fmt = calendarDuration.combineFormats(adap_a.Format, adap_b.Format);
            outAdaptor = matlab.bigdata.internal.adaptors.DatetimeFamilyAdaptor('calendarDuration', fmt);
        else
            outAdaptor = resetSizeInformation(adap_a);
        end
    elseif strcmp(cb, 'calendarDuration')
        outAdaptor = resetSizeInformation(adap_b);
    elseif strcmp(ca, 'duration')
        outAdaptor = resetSizeInformation(adap_a);
    elseif strcmp(cb, 'duration')
        outAdaptor = resetSizeInformation(adap_b);
    else
        cc = calculateArithmeticOutputType(ca, cb);
        outAdaptor = matlab.bigdata.internal.adaptors.getAdaptorForType(cc);
    end
end
end