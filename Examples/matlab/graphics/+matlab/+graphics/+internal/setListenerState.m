function setListenerState(hList,state)
%SETLISTENERSTATE Helper function to set the Enabled property of listeners
%
%   Copyright 2011-2014 The MathWorks, Inc.

if strcmp(state,'off')
    if isa(hList, 'handle.listener')
        set(hList,'Enabled','off');
    else
        offVal = repmat({false},size(hList));
        [hList.Enabled] = deal(offVal{:});
    end
elseif strcmp(state,'on')
    if isa(hList, 'handle.listener')
        set(hList,'Enabled','on');
    else
        onVal = repmat({true},size(hList));
        [hList.Enabled] = deal(onVal{:});
    end
else 
    error(message('MATLAB:hg:InvalidListenerState'));
end