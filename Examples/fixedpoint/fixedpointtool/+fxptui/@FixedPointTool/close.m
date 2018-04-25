function close(this)
% CLOSE Closes the FPT and cleans up references to the model.

% Copyright 2015-2017 The MathWorks, Inc.

    this.deleteControllers;
    this.deleteListeners;
    this.deleteBlockDiagramCallbacks;
    this.deleteShortcutEditor;
    delete(this.WebWindow);
    delete(this.GoalSpecifier);
    this.GoalSpecifier = [];
    this.WebWindow = [];
    this.ShortcutManager = [];
    this.Model = '';
    this.ModelObject = '';
    delete(this.ExternalViewer);
    for i = 1:numel(this.Subscriptions)
        message.unsubscribe(this.Subscriptions{i});
    end
    this.Subscriptions = [];
    delete(this.ModelHierarchy);
    this.ModelHierarchy = [];
    notify(this, 'FPTCloseEvent');
end
