function deleteListeners(this)
% DELETELISTENERS Deleted the listeners on the instance.

% Copyright 2015-2016 The MathWorks, Inc.

    delete(this.Listener);
    delete(this.CloseModelListener);
    this.Listener = [];
    this.SimStartListener = [];
    this.SimFailedListener = [];
    this.CloseModelListener = [];
end
