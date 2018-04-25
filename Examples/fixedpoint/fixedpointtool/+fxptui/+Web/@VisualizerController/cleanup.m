function cleanup(this)
%% CLEANUP function clears all member properties and unsubscribes all 
% subscriptions

%   Copyright 2016 The MathWorks, Inc.

    % initialize data to empty, unsubscribe the message subscription &
    % initialize the subscription string to empty.
    this.Data = '';
    this.MetaData = '';
    for i = 1:numel(this.Subscriptions)
        message.unsubscribe(this.Subscriptions{i});
    end
    this.Subscriptions = '';
end
