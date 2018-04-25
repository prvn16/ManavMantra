function buttondownCallback(this, hDivider, eventData)
%BUTTONDOWNCALLBACK When a button is pressed, react.
%   Specifically, we wish to update the positions of our divider and
%   our children in repsonse to mouse drags from the user.
%
%   Function arguments
%   ------------------
%   THIS: the splitPane object instance.
%   HDIVIDER: The handle of the divider.
%   EVENTDATA: The event data.

%   Copyright 2005-2013 The MathWorks, Inc.

    hFig = this.hFig;
    if isempty(get(hDivider, 'UserData'))
        set(hDivider, 'UserData', get(hFig, {'WindowButtonMotionFcn', 'WindowButtonUpFcn', 'Pointer'}));
    end

    % Theoretically the panel's position cannot change until after the buttonup
    % function is fired.  Get the position here and pass it as an input.
    pos = getPanelPos(this);

    if strcmpi(this.LayoutDirection, 'vertical')
        ptr = 'top';
    else
        ptr = 'left';
    end

    set(hFig, ...
        'WindowButtonMotionFcn', {@windowButtonMotionCallback, this, pos}, ...
        'WindowButtonUpFcn',     {@windowButtonUpCallback,     this}, ...
        'Pointer',               ptr);

	update(this);

    % -------------------------------------------------------------------------
    function windowButtonMotionCallback(hFig, eventData, this, pos)
        % This function is called during mouse drag operations
        % on the divider.
        cp = get(hFig, 'CurrentPoint');
        domLim    = this.MinDominantExtent;
        nondomLim = this.MinNonDominantExtent;

        if strcmpi(this.LayoutDirection, 'vertical')
            maxwidth = pos(4)-nondomLim;
            if strcmpi(this.Dominant, 'northwest')
                cp = cp+ceil(this.DividerWidth/2);
                width = pos(4)-cp(2);
            else
                cp = cp-ceil(this.DividerWidth/2);
                width = cp(2);
            end
        else
            maxwidth = pos(3)-nondomLim;
            if strcmpi(this.Dominant, 'northwest')
                cp = cp-ceil(this.DividerWidth/2);
                width = cp(1);
            else
                cp = cp+ceil(this.DividerWidth/2);
                width = pos(3)-cp(1);
            end
        end

        newDomWid = min(maxwidth, max(domLim, width));
        if this.DominantExtent ~= newDomWid
            set(this, 'DominantExtent', newDomWid);
        end
    end

    % -------------------------------------------------------------------------
    function windowButtonUpCallback(hFig, eventData, this)
        % This method is called to terminate the drag operation on the divider 
        set(hFig, {'WindowButtonMotionFcn', 'WindowButtonUpFcn', 'Pointer'}, ...
            get(this.DividerHandle, 'UserData'));
        set(this.DividerHandle, 'UserData', []);

        set(this, 'Invalid', true);
        update(this);
    end

end

function pos = getPanelPos(this)
    % Get the panel position in charater uints.
    hp = get(this, 'Panel');
    pos = hgconvertunits(this.hFig, get(hp, 'Position'), ...
        get(hp,'Units'), 'characters', hp);
end
