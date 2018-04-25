function model = getTopModelFromFPT
% GETTOPMODELFROMFPT Returns the top model currently opened in the FPT UI

% Copyright 2016 The MathWorks, Inc.

    model = '';
    if ~slfeature('FPTWeb')
        me = fxptui.getexplorer;
        if ~isempty(me)
            model = me.getTopNode.getDAObject.getFullName;
        end
    else
        fpt = fxptui.FixedPointTool.getExistingInstance;
        if ~isempty(fpt)
            model = fpt.getModel;
        end
    end
end
