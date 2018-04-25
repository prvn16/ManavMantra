function open(this, debugPort)
% OPEN Opens FPT window using the specified port.

% Copyright 2015 - 2016 The MathWorks, Inc.

    if isempty(this.WebWindow)
        if nargin < 2
            debugPort = 0;
        end
        this.createApplication(debugPort);
    else
        if nargin > 1
            if ~isequal(debugPort, this.WebWindow.getDebugPort)
                delete(this.WebWindow);
                this.createApplication(debugPort);
            end
        end
    end
    if isempty(this.Subscriptions)
        this.Subscriptions{1} = message.subscribe('/fpt/ready',@(data)this.initControllers(data));
    end
    this.WebWindow.openUI;
end
