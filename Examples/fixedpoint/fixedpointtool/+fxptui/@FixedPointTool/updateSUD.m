function updateSUD(this, ~, eventData)
% UPDATESUD Sends an event when the SUD is updated on the UI

% Copyright 2015-2017 The MathWorks, Inc.

data = eventData.getData;
this.setSystemForConversion(data.SUD, data.ObjectClass);
this.setTitle(this.constructTitle);
notify(this, 'UpdateSUDEvent');
end
