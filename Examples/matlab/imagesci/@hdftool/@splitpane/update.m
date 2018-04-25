function update(this)
%UPDATE Update the splitPane layout.
%
%   Function arguments
%   ------------------
%   THIS: The SPLITPANE object instance

%   Copyright 2005-2013 The MathWorks, Inc.

    % When UPDATE is called, we assume the layout is dirty.
    if this.Invalid && any(this.Active)
        % Nothing to do if the panel is invisible, to avoid multiple updates.
        if strcmpi(get(this.Panel, 'Visible'), 'Off')
            return
        end
        layout(this);
        this.Invalid = false;
    end
end

function layout(this)
    %LAYOUT   Layout the container.

    pos = getPanelPos(this);
    divwidth = get(this, 'DividerWidth');
    domwidth = get(this, 'DominantExtent');

    switch lower(this.LayoutDirection)
        case 'vertical'
            isvertical = true;
        case 'horizontal'
            isvertical = false;
    end

    domLim    = this.MinDominantExtent;
    nondomLim = this.MinNonDominantExtent;
    if isvertical
        nonDomLimTooSmall = pos(4)-domwidth < nondomLim;
        if nonDomLimTooSmall
            domwidth = max(domLim, pos(4)-nondomLim);
        end
    else
        nonDomLimTooSmall = pos(3)-domwidth < nondomLim;
        if nonDomLimTooSmall
            domwidth = max(domLim, pos(3)-nondomLim);
        end
    end

    if strcmpi(this.Dominant, 'northwest')
        if isvertical
            northwest = min(domwidth, pos(4)-divwidth);
            northwestpos = [0 pos(4)-northwest ...
                pos(3) northwest];
            dividerpos   = [0 northwestpos(2)-divwidth ...
                pos(3) divwidth];
            southeastpos = [0 0 ...
                pos(3) dividerpos(2)];
        else
            northwest = min(domwidth, pos(3)-divwidth);
            northwestpos = [0 0 ...
                northwest pos(4)];
            dividerpos   = [northwestpos(1)+northwestpos(3) 0 ...
                divwidth pos(4)];
            southeastpos = [dividerpos(1)+dividerpos(3) 0 ...
                pos(3)-dividerpos(1)-dividerpos(3) pos(4)];
        end
    else
        if isvertical
            southeast = min(domwidth, pos(4)-divwidth);
            southeastpos = [0 0 ...
                pos(3) southeast];
            dividerpos   = [0 southeastpos(4) ...
                pos(3) divwidth];
            northwestpos = [0 dividerpos(2)+divwidth ...
                pos(3) pos(4)-dividerpos(2)-divwidth];
        else
            southeast = min(domwidth, pos(3)-divwidth);
            southeastpos = [pos(3)-southeast ...
                0 southeast pos(4)];
            dividerpos   = [southeastpos(1)-divwidth 0 ...
                divwidth pos(4)];
            northwestpos = [0 0 ...
                dividerpos(1) pos(4)];
        end
    end

    set(this.DividerHandle, 'Position', dividerpos);

    % If automatic update is off and the manager is in a "drag" condition, 
    % return early and do not set the component's positions.
    if ~this.AutoUpdate && ~isempty(get(this.DividerHandle, 'UserData'))
        return
    end

    childUpdate(this, 'northwest', northwestpos);
    childUpdate(this, 'southeast', southeastpos);
end

% -------------------------------------------------------------------------
function childUpdate(this, loc, pos)

    % Never allow any position value to be non-positive.
    minValue = 1;
    tst = pos(3:4) <= minValue;
    pos([false false tst]) = minValue;

    % Do the update
    loc = get(this, loc);
    if ~isempty(loc) && ishghandle(loc) && ...
            strcmpi(get(loc, 'Visible'), 'on')
        if ~strcmp(get(loc, 'units'), 'characters')
            set(loc, 'Units', 'characters')
        end
        set(loc, 'Position', pos)
    end
end

function pos = getPanelPos(this)
    %Get the panel position in charater uints.
    hp = get(this, 'Panel');
    pos = hgconvertunits(this.hFig, get(hp, 'Position'), ...
        get(hp,'Units'), 'characters', hp);
end
