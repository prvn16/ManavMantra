function updateSNRForNumericTypeChange(ntx, allowReset)
%UPDATESNRFORTYPECHANGE Reset SNR stats if the data type changes.

%   Copyright 2010 The MathWorks, Inc.


if nargin<2
    allowReset = true;
end

s = getNumericTypeStrs(ntx);

% Check if numerictype changed
ht = ntx.htTitle;
changed = ~strcmpi(get(ht,'String'),s.typeStr);
if changed
    if allowReset
        datatypeChanged(ntx);
    end

    % Update histogram title. Since we are using this text object to figure
    % out if the data type changed, it needs to be updated every time the
    % type changes.
    str = s.typeStr;
    tip = s.typeTip;
    set(ht,'String',str,'TooltipString',tip)
end


% [EOF]
