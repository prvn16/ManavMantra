function deleteSDIEngineListeners(this)
%DELETESDIENGINELISTENERS Delete the SDI related listeners

% Copyright 2015-2016 The MathWorks, Inc.

% Add listener on the global SDI engine for time-series data.
    if ~isempty(this.SDIListeners)
        delete(this.SDIListeners);
        this.SDIListeners = [];
    end
    this.ReAttachSDIListeners = true;
end
