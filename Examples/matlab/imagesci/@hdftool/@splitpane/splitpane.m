function this = splitpane(hPanel)
%SPLITPANE construct a splitPane object.
%
%   Function arguments
%   ------------------
%   HPANEL: The handle of the parent panel, which we will subdivide.

%   Copyright 2004-2013 The MathWorks, Inc.

    narginchk(1,1);
    this = hdftool.splitpane;

    % Set defaults
    this.DominantExtent    = 100;
    this.MinDominantExtent = 0;
    this.Active           = [false false];
    this.hFig             = ancestor(hPanel, 'figure');

    % Create the 'divider' with a button.
    this.DividerHandle = uicontrol(hPanel, ...
        'style',         'pushbutton', ...
        'Enable',        'Inactive', ...
        'tag',           'splitpanedivider', ...
        'ButtonDownFcn', @(varargin)(this.buttondownCallback(varargin{:})) );

    this.Panel = hPanel;
    pos = getPanelPos(this);
    set(this, 'OldPosition', pos);

    set(this.Panel, 'ResizeFcn', {@ResizeFcn, this});

    this.Invalid = true;
    update(this);


    %----------------------------------------------------------------------
    function ResizeFcn(~, ~, varargin)
        newPos = getPanelPos(this);
        set(this, 'OldPosition', newPos, 'Invalid', true);
        update(this);
    end
        
    function propertyListener(this, varargin) %#ok<DEFNU>
        % Update our children when a relevant property changes.
        this.Invalid = true;
        update(this);
    end
end

function pos = getPanelPos(this)
    %Get the panel position in charater uints.
    hp = get(this, 'Panel');
    pos = hgconvertunits(this.hFig, get(hp, 'Position'), ...
        get(hp,'Units'), 'characters', hp);
end

