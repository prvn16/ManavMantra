function meAction = createAction(this, action)
% CREATEACTION creates an action on the ME instance.

% Copyright 2013 MathWorks, Inc


    am = DAStudio.ActionManager;
    meAction = am.createAction(this,'Text',action.Label,...
                               'Tag',action.UniqueTag,...
                               'Callback',action.Callback...
                               );
    if ~isempty(action.Icon)
        meAction.icon = action.Icon;
    end
    this.actions.put(action.UniqueTag, meAction);
    
end
