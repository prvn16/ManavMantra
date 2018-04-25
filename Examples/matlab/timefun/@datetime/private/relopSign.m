function cSign = relopSign(aData,bData)
% Return the sign of the elementwise difference of two datetimes' data

%   Copyright 2015 The MathWorks, Inc.

% Actually, for finite values this just returns the difference, but comparing
% that to zero is equivalent to comparing the sign to zero.
cSign = matlab.internal.datetime.datetimeSubtract(aData,bData);

% The main purpose of this function, beyond just calling datetimeSubtract
% directly, is to fix up pairs of Infs that have same sign - these should be
% considered equal. Not all contexts care about that, so some just call
% datetimeSubtract.
nans = isnan(cSign);
if any(nans(:))
    if isscalar(aData)
        aSign = sign(aData);
    else
        aSign = sign(aData(nans));
    end
    if isscalar(bData)
        bSign = sign(bData);
    else
        bSign = sign(bData(nans));
    end
    cSign(nans) = aSign - bSign;
end
end
