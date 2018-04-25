function setPanelVisibility(this, bShow, selectedNode)
%SETPANELVISIBILITY Show (or hide) the panel.
%   This function will show or hide the default node panel.
%   Classes which inherit from FILEPANEL should override this
%   method to customize the panel appearance.
%
%   Function arguments
%   ------------------
%   THIS: The filePanel object instance.
%   BSHOW: true if the panel is being displayed, otherwise false.
%   SELECTEDNODE: This will correspond to the selected node in the tree if
%       the panel is being displayed.  For the default implementation, it
%       is not used.

%   Copyright 2005-2013 The MathWorks, Inc.

    if bShow
        set(this.mainpanel, 'Visible','on');
    else
        set(this.mainpanel, 'Visible','off');
    end

end