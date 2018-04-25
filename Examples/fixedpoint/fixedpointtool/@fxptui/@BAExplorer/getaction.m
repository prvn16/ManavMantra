function action = getaction(h, key)
%GETACTION   get action at KEY (ie: 'FILE_NEW').

%   Copyright 2011 The MathWorks, Inc.

if(isempty(h.actions))
    action = [];
	return;
end
action = h.actions.get(key);
action = handle(action);

% [EOF]
