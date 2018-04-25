function icon = getDisplayIcon(this)
% GETDISPLAYICON Gets the icon to be displayed for the node in FPT

% Copyright 2013 MathWorks, Inc

    icon = '';
    if this.isValid
        icon = this.DAObject.getDisplayIcon;
    end
end
