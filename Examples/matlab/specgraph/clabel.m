function hh = clabel(cs, varargin)
%CLABEL Contour plot elevation labels.
%
%   CLABEL(C,h) inserts rotated labels into each contour line. The contour
%   line must be long enough to fit the label, otherwise CLABEL does not
%   insert a label. C and h are the contour matrix and contour object
%   handle outputs from CONTOUR, CONTOUR3, or CONTOURF. Alternately, as
%   long as h is provided, you can replace C with [].
% 
%   CLABEL(C,h,v) labels only the contour levels specified by vector v.
% 
%   CLABEL(C,h,'manual') places contour labels at locations you select with
%   a mouse. Click the mouse or press the space bar to label the contour
%   closest to the center of the crosshair. Press the Return key while the
%   cursor is within the figure window to terminate labeling.
%
%   t = CLABEL(C,h,'manual') returns handles to the manually-placed text.
% 
%   CLABEL(C) labels all contours displayed in the current contour plot.
%   Labels are upright and displayed with '+' symbols. CLABEL randomly
%   selects label positions.
% 
%   CLABEL(C,v) labels only the contour levels specified by the vector, v.
% 
%   CLABEL(C,'manual') places contour labels at locations you select with a
%   mouse.
% 
%   tl = CLABEL(C,___), in cases where the contour object handle h is
%   omitted, returns the text and line object handles.
%
%   CLABEL(___,Name,Value) specifies text properties using one or more
%   name-value pairs. Use this option with any of the input argument
%   combinations in the previous syntaxes. For example, 'Color','blue'
%   specifies blue text and 'LabelSpacing',72 spaces the labels 72 points
%   apart (1 inch). (LabelSpacing can be controlled only in cases that
%   include the contour handle h and omit the 'manual' flag.)
%
%   Example:
%      % Show both modes of automatic label placement (in-line and '+'
%      % symbols), with and without optional name-value pairs.
%      figure
%      subplot(2,2,1)
%      [C,h] = contour(peaks);
%      clabel(C,h)
%      subplot(2,2,2)
%      [C,h] = contour(peaks);
%      clabel(C,h,'LabelSpacing',72,'Color','b','FontWeight','bold')
%      subplot(2,2,3)
%      C = contour(peaks);
%      clabel(C)
%      subplot(2,2,4)
%      C = contour(peaks);
%      clabel(C,'FontSize',13,'Color','r','FontWeight','bold')
%
%   See also CONTOUR, CONTOUR3, CONTOURF.
    
% Copyright 1984-2017 The MathWorks, Inc.

% Thanks to R. Pawlowicz (IOS) rich@ios.bc.ca for the algorithm used
% for inline labeling.

    % Check whether the argument after cs is a handle to a Contour object.
    % If it is not a contour object, numeric or char, error
    hContour = [];
    if ~isempty(varargin)
        varargin = matlab.graphics.internal.convertStringToCharArgs(varargin);
        if ~isempty(varargin{1})
            arg2 = varargin{1};
            % Check whether the input is a contour object.  Check only the
            % first element since the input could be a numeric or char array
            if ishghandle(arg2(1)) && isa(handle(arg2(1)), ...
                    'matlab.graphics.chart.primitive.Contour')
                hContour = arg2;
                varargin(1) = [];
            % Second input must be a numeric or char at this point
            elseif ~isnumeric(arg2(1)) && ~matlab.graphics.internal.isCharOrString(arg2(1))
                error(message('MATLAB:clabel:ContourHandleInputs'));
            end
        end
    end
    
    if isempty(hContour) && isempty(cs)
        if nargout > 0
            hh = [];
        end
        return
    end

    % Check whether cs is a valid Contour Matrix.
    if ~isempty(cs)
      if ~isa(cs, 'double')
        cs = double(cs);
      end
      % sparse, complex, and ndims > 2 are errors
      if issparse(cs)
        error(message('MATLAB:clabel:ContourMatrixMustBeFull'));
      end
      if ~isreal(cs)
        error(message('MATLAB:clabel:ContourMatrixMustBeReal'));
      end
      if ~ismatrix(cs)
        error(message('MATLAB:clabel:ContourMatrixMustHaveAtMost2Dimensions'));
      end
      if size(cs, 1) ~= 2
        error(message('MATLAB:clabel:ContourMatrixMustHave2Rows'));
      end
    end    
    
    % Argument parsing
    bManual = false;
    bTextList = false;
    textList = [];
    if ~isempty(varargin)
        if isnumeric(varargin{1})
            bTextList = true;
            textList = varargin{1};
            % Check whether textList is valid
            if ~isempty(textList) && ~isvector(textList)
                error(message('MATLAB:clabel:TextListMustBeVectorOrScalar'));
            end
            if ~isempty(find(~isfinite(textList), 1))
                error(message('MATLAB:clabel:TextListMustBeFinite'));
            end
            varargin(1) = [];
        elseif matlab.graphics.internal.isCharOrString(varargin{1}) && strcmp(varargin{1}, 'manual')
            bManual = true;
            varargin(1) = [];
        end
    end
    
    % LabelSpacing parsing
    bLabelSpacing = false;
    labelSpacing = 144;
    nargs = length(varargin);
    if nargs > 0
        hInd = find(strcmpi('LabelSpacing', varargin));
        if ~isempty(hInd)
            hInd = unique([hInd hInd+1]);
            lsInd = hInd(end);
            if nargs >= lsInd
                labelSpacing = varargin{lsInd};
                bLabelSpacing = true;
                varargin(hInd) = [];
            end
        end
    end
    
    % ContourZLevel parsing
    bContourZLevel = false;
    czLevel = 0;
    nargs = length(varargin);
    if nargs > 0
        hInd = find(strcmpi('ContourZLevel', varargin));
        if ~isempty(hInd)
            hInd = unique([hInd hInd+1]);
            lsInd = hInd(end);
            if nargs >= lsInd
                czLevel = varargin{lsInd};
                bContourZLevel = true;
                varargin(hInd) = [];
            end
        end
    end
    
    % Determine the Axes to use and whether we are 3D.
    if isempty(hContour)
        cax = gca;
        hc = findobj(cax, '-class', 'matlab.graphics.chart.primitive.Contour');
        if isempty(hc)
            is3D = false;
        else
            is3D = ~isempty(find(strcmp(get(hc, 'Is3D'), 'on'), 1));
        end
    else
        cax = ancestor(hContour, 'axes');
        is3D = strcmp(get(hContour, 'Is3D'), 'on');
    end
    
    % Validate label text property names, then dispatch to specific routines.
    labelTextPairs = varargin;
    errorOnReadOnlyTextProperties(labelTextPairs)
    labelTextPairs = warnAndIgnoreTextProperties(labelTextPairs);
    if isempty(hContour)
        if bManual
            if bLabelSpacing
                warning(message('MATLAB:clabel:LabelSpacingIgnoredManual'))
            end
            labelTextPairs = validateTextPropertyNames(labelTextPairs, {'FontUnits','Rotation'});
            
            h = plusLabelsManual(cax, cs, is3D, bContourZLevel, czLevel, labelTextPairs);
        else
            if bLabelSpacing
                warning(message('MATLAB:clabel:LabelSpacingIgnoredAuto'))
            end
            labelTextPairs = validateTextPropertyNames(labelTextPairs, {'FontUnits','Rotation'});
            
            h = plusLabelsAuto(cax, cs, is3D, bTextList, textList, bContourZLevel, czLevel, labelTextPairs);
        end
    else
        if bManual
            if bLabelSpacing
                warning(message('MATLAB:clabel:LabelSpacingIgnoredManual'))
            end
            labelTextPairs = validateTextPropertyNames(labelTextPairs, {'FontUnits','Rotation'});
            
            h = inlineLabelsManual(cax, hContour, is3D, bContourZLevel, czLevel, labelTextPairs);
        else
            labelTextPairs = warnAndRemoveSpecial(labelTextPairs, 'FontUnits');
            labelTextPairs = warnAndRemoveSpecial(labelTextPairs, 'Rotation');
            labelTextPairs = validateTextPropertyNames(labelTextPairs);
            
            h = inlineLabelsAuto(hContour, bTextList, textList, bLabelSpacing, labelSpacing, bContourZLevel, czLevel, labelTextPairs);
            
            if nargout > 0
               warning(message('MATLAB:clabel:LabelHandleOutputs'))
            end
        end
    end
    
    if nargout > 0
        hh = h;
    end
end

function h = plusLabelsManual(cax, cs, is3D, bContourZLevel, extContourZLevel, labelTextPairs)
    %
    % Draw the labels as plus symbols next to text (v4 compatible)
    %
    
    %    RP - 14/5/97
    %    Clay M. Thompson 6-7-96
    %    Charles R. Denham, MathWorks, 1988, 1989, 1990.
    
    % Set up the return value
    h = [];
    
    % Get the length of the contour matrix
    csLen = size(cs, 2);
    
    % Initialize lists
    xlist = [];
    ylist = [];
    clist = [];
    zLevels = [];
    
    i = 1;
    k = 1;
    while i < csLen
        zLevel = cs(1, i);
        nPoints = cs(2, i);
        iBegin = i + 1;
        iNext = iBegin + nPoints;
        iEnd = iNext - 1;
        
        nn = 2 .* nPoints - 1;
        xtemp = zeros(nn, 1);
        ytemp = zeros(nn, 1);
        xtemp(1 : 2 : nn) = cs(1, iBegin : iEnd);
        xtemp(2 : 2 : nn) = (xtemp(1 : 2 : nn - 2) + xtemp(3 : 2 : nn)) ./ 2;
        ytemp(1 : 2 : nn) = cs(2, iBegin : iEnd);
        ytemp(2 : 2 : nn) = (ytemp(1 : 2 : nn - 2) + ytemp(3 : 2 : nn)) ./ 2;
        xlist = [xlist; xtemp]; %#ok<AGROW>
        ylist = [ylist; ytemp]; %#ok<AGROW>
        clist = [clist; zLevel .* ones(2 * nPoints - 1, 1)]; %#ok<AGROW>
        zLevels(k) = zLevel; %#ok<AGROW>
        
        k = k + 1;
        i = iNext;
    end
    
    crange = max(abs(zLevels));
    cdelta = abs(diff(zLevels));
    cdelta = min(cdelta(cdelta > eps)) / max(eps, crange); % Minimum significant change
    if isempty(cdelta)
        cdelta = 0;
    end
    
    ax = axis;
    xmin = ax(1);
    xmax = ax(2);
    ymin = ax(3);
    ymax = ax(4);
    xrange = xmax - xmin;
    yrange = ymax - ymin;
    xylist = (xlist .* yrange + sqrt(-1) .* ylist .* xrange);
    
    % Temporary mods for editing the contour label positions.
    [az, el] = view;
    hObj = findobj(cax, 'Visible', 'on');
    hLen = length(hObj);
    hInd(hLen, 1) = false;
    for ind = 1 : hLen
        hInd(ind) = (hObj(ind) ~= cax & ~isa(hObj(ind), 'matlab.graphics.chart.primitive.Contour'));
    end
    view(cax, 2);
    set(hObj(hInd), 'Visible_I', 'off');
    
    disp(' ')
    disp(['    ',getString(message('MATLAB:clabel:PleaseWaitAMoment'))])
    disp(' ')
    disp(['   ',getString(message('MATLAB:clabel:SelectContoursForLabeling'))])
    disp(['   ',getString(message('MATLAB:clabel:WhenDonePressReturn'))])
    
    while (1)
        % Use GINPUT and select nearest point
        try
            [xx, yy, button] = ginput(1);
        catch err %#ok<NASGU>
            hInd = hInd & isvalid(hObj);
            set(hObj(hInd), 'Visible_I', 'on');
            view(az, el);
            return
        end
        if isempty(button) || isequal(button, 13)
            break
        end
        if xx < xmin || xx > xmax
            break
        end
        if yy < ymin || yy > ymax
            break
        end
        xy = xx .* yrange + sqrt(-1) .* yy .* xrange;
        dist = abs(xylist - xy);
        [~, f] = min(dist);
        if ~isempty(f)
            f = f(1);
            xx = xlist(f);
            yy = ylist(f);
            zLevel = clist(f);
            okay = 1;
        else
            okay = 0;
        end
        
        % Label the point.
        
        if okay
            % Set tiny labels to zero.
            if abs(zLevel) <= 10 * eps * crange
                zLevel = 0;
            end
            % Determine format string number of digits
            if cdelta > 0
                ndigits = max(3, ceil(-log10(cdelta)));
            else
                ndigits = 3;
            end
            s = num2str(zLevel, ndigits);
            hl = line('XData', xx, 'YData', yy, 'Marker', '+');
            ht = text(xx, yy, s, 'Parent', cax, 'VerticalAlignment', 'bottom', ...
                'HorizontalAlignment', 'left', ...
                'Clipping', 'on', 'UserData', zLevel, labelTextPairs{:});
            if is3D
                set(hl, 'ZData', zLevel);
                set(ht, 'Position', [xx, yy, zLevel]);
            elseif bContourZLevel
                set(hl, 'ZData', extContourZLevel);
                set(ht, 'Position', [xx, yy, extContourZLevel]);
            end
            h = [h; hl]; %#ok<AGROW>
            h = [h; ht]; %#ok<AGROW>
        end
    end
    hInd = hInd & isvalid(hObj);
    set(hObj(hInd), 'Visible_I', 'on');
    view(az, el);
end

function h = plusLabelsAuto(cax, cs, is3D, bTextList, textList, bContourZLevel, extContourZLevel, labelTextPairs)
    %
    % Draw the labels as plus symbols next to text (v4 compatible)
    %
    
    %    RP - 14/5/97
    %    Clay M. Thompson 6-7-96
    %    Charles R. Denham, MathWorks, 1988, 1989, 1990.
    
    % Set up the return value
    h = [];
    
    % Get the length of the contour matrix
    csLen = size(cs, 2);
    
    % Initialize lists
    zLevels = [];
    
    % Find range of levels.
    i = 1;
    k = 1;
    while i < csLen
        zLevels(k) = cs(1, i); %#ok<AGROW>
        
        k = k + 1;
        i = i + cs(2, i) + 1;
    end
    
    crange = max(abs(zLevels));
    cdelta = abs(diff(zLevels));
    cdelta = min(cdelta(cdelta > eps)) / max(eps, crange); % Minimum significant change
    if isempty(cdelta)
        cdelta = 0;
    end
    
    flip = 0;
    
    i = 1;
    while i < csLen
        zLevel = cs(1, i);
        nPoints = cs(2, i);
        if bTextList
            f = find(abs(zLevel - textList) / max(eps + abs(textList)) < .00001, 1);
            okay = ~isempty(f);
        else
            okay = 1;
        end
        if okay
            r = rands(1);
            j = fix(r .* (nPoints - 1)) + 1;
            if flip
                j = nPoints - j;
            end
            flip = ~flip;
            if nPoints == 1    % if there is only one point
                xx = cs(1, j + i);
                yy = cs(2, j + i);
            else
                x1 = cs(1, j + i);
                y1 = cs(2, j + i);
                x2 = cs(1, j + i + 1);
                y2 = cs(2, j + i + 1);
                xx = (x1 + x2) ./ 2;
                yy = (y1 + y2) ./ 2;  % Test was here; removed.
            end
        end
        
        % Label the point.
        
        if okay
            % Set tiny labels to zero.
            if abs(zLevel) <= 10 * eps * crange
                zLevel = 0;
            end
            % Determine format string number of digits
            if cdelta > 0
                ndigits = max(3, ceil(-log10(cdelta)));
            else
                ndigits = 3;
            end
            s = num2str(zLevel, ndigits);
            hl = line('XData', xx, 'YData', yy, 'Marker', '+');
            ht = text(xx, yy, s, 'Parent', cax, 'VerticalAlignment', 'bottom', ...
                'HorizontalAlignment', 'left', ...
                'Clipping', 'on', 'UserData', zLevel, labelTextPairs{:});
            if is3D
                set(hl, 'ZData', zLevel);
                set(ht, 'Position', [xx, yy, zLevel]);
            elseif bContourZLevel
                set(hl, 'ZData', extContourZLevel);
                set(ht, 'Position', [xx, yy, extContourZLevel]);
            end
            h = [h; hl]; %#ok<AGROW>
            h = [h; ht]; %#ok<AGROW>
        end
        i = i + nPoints + 1;
    end
end

function h = inlineLabelsManual(cax, hContour, is3D, bContourZLevel, extContourZLevel, labelTextPairs)
    %
    % Draw the labels along the contours and rotated to match the local slope.
    %
    
    % Author: R. Pawlowicz IOS rich@ios.bc.ca
    %         12/12/94
    %         changes - R. Pawlowicz 14/5/97 - small bug in "that ole'
    %         matlab magic" fixed, also another in manual selection
    %         of locations.
    
    % Set up the return value
    h = [];
    
    % Get the length of the contour matrix
    cs = get(hContour, 'ContourMatrix');
    csLen = size(cs, 2);
    
    % Determine the ContourZLevel to use
    czLevel = get(hContour, 'ContourZLevel');
    if bContourZLevel
        czLevel = extContourZLevel;
    end
    
    % Initialize lists
    xlist = [];
    ylist = [];
    ilist = [];
    klist = [];
    plist = [];
    zLevels = [];
    
    i = 1;
    k = 1;
    
    while i < csLen
        zLevel = cs(1, i);
        nPoints = cs(2, i);
        iBegin = i + 1;
        iNext = iBegin + nPoints;
        iEnd = iNext - 1;
        
        nn = 2 .* nPoints - 1;
        xtemp = zeros(nn, 1);
        ytemp = zeros(nn, 1);
        xtemp(1 : 2 : nn) = cs(1, iBegin : iEnd);
        xtemp(2 : 2 : nn) = (xtemp(1 : 2 : nn - 2) + xtemp(3 : 2 : nn)) ./ 2;
        ytemp(1 : 2 : nn) = cs(2, iBegin : iEnd);
        ytemp(2 : 2 : nn) = (ytemp(1 : 2 : nn - 2) + ytemp(3 : 2 : nn)) ./ 2;
        xlist = [xlist; xtemp]; %#ok<AGROW>
        ylist = [ylist; ytemp]; %#ok<AGROW>
        ilist = [ilist; i(ones(nn, 1))]; %#ok<AGROW>
        klist = [klist; k(ones(nn, 1))]; %#ok<AGROW>
        plist = [plist; (1 : .5 : nPoints)']; %#ok<AGROW>
        zLevels(k) = zLevel; %#ok<AGROW>
        
        k = k + 1;
        i = iNext;
    end
    
    % Get labels all at once to get the length of the longest string.
    % This allows us to call extent only once, thus speeding up this routine
    labels = num2str(zLevels');
    
    % Until we determine proper axes limits
    x = hContour.XData;
    y = hContour.YData;
    
    xmin = 0;
    xmax = 0;
    if ~isempty(x)
        finiteIndX = find(isfinite(x));
        if ~isempty(finiteIndX)
            xmax = max(x(finiteIndX));
            xmin = min(x(finiteIndX));
            if xmin == xmax
                xmin = xmin - 1;
                xmax = xmax + 1;
            end
        end
        clear finiteIndX;
    end
    
    ymin = 0;
    ymax = 0;
    if ~isempty(y)
        finiteIndY = find(isfinite(y));
        if ~isempty(finiteIndY)
            ymax = max(y(finiteIndY));
            ymin = min(y(finiteIndY));
            if ymin == ymax
                ymin = ymin - 1;
                ymax = ymax + 1;
            end
        end
        clear finiteIndY;
    end
    
    % Calculate various contour label scale parameters
    [xDir, yDir, axScaleXPos, axScaleYPos, dummyExtent] = specgraphhelper('contourobjHelper', 'contourLabelScaleParams', cax, [xmin, xmax], [ymin, ymax]);
    
    ax = axis;
    xmin = ax(1);
    xmax = ax(2);
    ymin = ax(3);
    ymax = ax(4);
    xrange = xmax - xmin;
    yrange = ymax - ymin;
    xylist = (xlist .* yrange + sqrt(-1) .* ylist .* xrange);
    
    % Temporary mods for editing the contour label positions.
    [az, el] = view;
    hObj = findobj(cax, 'Visible', 'on');
    hInd = (hObj ~= cax & hObj ~= hContour);
    view(cax, 2);
    set(hObj(hInd), 'Visible_I', 'off');
    
    disp(' ')
    disp(['    ',getString(message('MATLAB:clabel:PleaseWaitAMoment'))])
    disp(' ')
    disp(['   ',getString(message('MATLAB:clabel:SelectContoursForLabeling'))])
    disp(['   ',getString(message('MATLAB:clabel:WhenDonePressReturn'))])
    
    while (1)
        try
            [xx, yy, button] = ginput(1);
        catch err %#ok<NASGU>
            hInd = hInd & isvalid(hObj);
            set(hObj(hInd), 'Visible_I', 'on');
            view(az, el);
            return
        end
        if isempty(button) || isequal(button, 13)
            break
        end
        if xx < xmin || xx > xmax
            break
        end
        if yy < ymin || yy > ymax
            break
        end
        xy = xx .* yrange + sqrt(-1) .* yy .* xrange;
        dist = abs(xylist - xy);
        [~, f] = min(dist);
        if ~isempty(f)
            f = f(1);
            i = ilist(f);
            k = klist(f);
            p = floor(plist(f));
            okay = 1;
        else
            okay = 0;
        end
        
        % Label the point.
        if okay
            getStartParam = @() rands(1);
            [bValid, zLevel, lab, lp, xc, yc, trot] = specgraphhelper('contourobjHelper', 'contourLabelRenderParams', cs, i, k, labels, dummyExtent, xDir, yDir, axScaleXPos, axScaleYPos, true, p, 0, [], getStartParam);
            if bValid
                for jj = 1 : lp
                    ht = text(xc(jj), yc(jj), lab, 'Parent', cax, 'Rotation', trot(jj), ...
                        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', ...
                        'Clipping', 'on', ...
                        'UserData', zLevel, labelTextPairs{:});
                    if is3D
                        set(ht, 'Position', [xc(jj), yc(jj), zLevel]);
                    else
                        set(ht, 'Position', [xc(jj), yc(jj), czLevel]);
                    end
                    h = [h; ht]; %#ok<AGROW>
                end
            end
        end
    end
    hInd = hInd & isvalid(hObj);
    set(hObj(hInd), 'Visible_I', 'on');
    view(az, el);
end

function h = inlineLabelsAuto(hContour, bTextList, extTextList, bLabelSpacing, extLabelSpacing, bContourZLevel, extContourZLevel, labelTextPairs)

    try
        updateLabelTextProperties(hContour, struct(labelTextPairs{:}))
    catch me
        throwAsCaller(me)
    end
    
    if bTextList
        hContour.TextList = extTextList;
    end
    
    if bLabelSpacing
        hContour.LabelSpacing = extLabelSpacing;
    end
    
    if bContourZLevel
        hContour.ContourZLevel = extContourZLevel;
    end
    
    hContour.ShowText = 'on';
    h = gobjects(0);
end

function errorOnReadOnlyTextProperties(labelTextPairs)

    readOnlyTextProperties = {
        'BeingDeleted'
        'Extent'
        'Type'
    };
    
    len = length(labelTextPairs);
    for k = 1:2:len
        name = labelTextPairs{k};
        if ~isempty(name)
            n = find(strncmpi(name, readOnlyTextProperties, length(name)));
            if n >= 1
                msg = message('MATLAB:clabel:ReadOnlyTextProperty', ...
                    readOnlyTextProperties{n(1)});
                throwAsCaller(MException(msg.Identifier, '%s', msg.getString()))
            end
        end
    end
end

function labelTextPairs = warnAndIgnoreTextProperties(labelTextPairs, propertiesToIgnore)

    if nargin < 2
        propertiesToIgnore = {
            'Annotation'
            'BeingDeleted'
            'BusyAction'
            'ButtonDownFcn'
            'Children'
            'Clipping'
            'CreateFcn'
            'DeleteFcn'
            'DisplayName'
            'Editing'
            'Extent'
            'HandleVisibility'
            'HitTest'
            'HorizontalAlignment'
            'Interruptible'
            'Parent'
            'PickableParts'
            'Position'
            'Selected'
            'SelectionHighlight'
            'String'
            'Tag'
            'Type'
            'UIContextMenu'
            'Units'
            'UserData'
            'VerticalAlignment'
            'Visible'
        };
    end
    
    len = length(labelTextPairs);
    remove = false(1,len);
    for k = 1:2:len
        name = labelTextPairs{k};
        if ~isempty(name)
            n = find(strncmpi(name, propertiesToIgnore, length(name)));
            if n >= 1
                warning(message('MATLAB:clabel:IgnoringTextProperty', ...
                    propertiesToIgnore{n(1)}))
                remove(k:min(k+1,len)) = true;
            end
        end
    end
    labelTextPairs(remove) = [];
end

function labelTextPairs = warnAndRemoveSpecial(labelTextPairs, propertyName)
% Additional filtering needed for 'FontUnits' and 'Rotation' when the
% contour handle h is input and the manual flag is not.
    len = length(labelTextPairs);
    remove = false(1,len);
    for k = 1:2:len
        name = labelTextPairs{k};
        if ~isempty(name)
            n = find(strncmpi(name, propertyName, length(name)));
            if n >= 1
                warning(message('MATLAB:clabel:IgnoringSpecialTextProperty', propertyName))
                remove(k:min(k+1,len)) = true;
            end
        end
    end
    labelTextPairs(remove) = [];
end

function labelTextPairs = validateTextPropertyNames(labelTextPairs, additionalProperties)
    % Validate and standardize the property names in labelTextPairs.
    
    acceptedPropertyNames = {
        'BackgroundColor'
        'Color'
        'EdgeColor'
        'FontAngle'
        'FontName'
        'FontSize'
        'FontSmoothing'
        'FontWeight'
        'Interpreter'
        'LineStyle'
        'LineWidth'
        'Margin'
        };
    
    if nargin > 1
        acceptedPropertyNames(end+1:end+length(additionalProperties)) ...
            = additionalProperties(:);
    end
    
    for k = 1:2:length(labelTextPairs)
        name = labelTextPairs{k};
        name = validatestring(name, acceptedPropertyNames, '', 'Name');
        labelTextPairs{k} = name;
    end
end

function r = rands(sz)
    %RANDS Uniform random values without affecting the global stream
    dflt = RandStream.getGlobalStream();
    savedState = dflt.State;
    r = rand(sz);
    dflt.State = savedState;
end
