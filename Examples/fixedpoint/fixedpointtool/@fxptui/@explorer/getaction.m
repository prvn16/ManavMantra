function action = getaction(h, key)
%GETACTION   get action at KEY (ie: 'FILE_NEW').

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.

if(isempty(h.actions))
    action = [];
	return;
end
action = h.actions.get(key);
action = handle(action);

% [EOF]