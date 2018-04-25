function retval = isplotchild(obj, dim, bfmode)
    %PLOTCHILD Get plot objects in an axis
    %  This function is a helper function for the plot tools and basic
    %  fitting. Do not call this function directly.
    
    %   RETVAL = ISPLOTCHILD(OBJ) returns true if the object is a plot object
    %   and returns false otherwise.
    %
    %   RETVAL = ISPLOTCHILD(OBJ, 2) returns true if the object is a plot object
    %   and does not have zdata and returns false otherwise.
    %
    %   RETVAL = ISPLOTCHILD(OBJ, 2, true) returns true if the object is compatible
    %   with the Basic Fitting and Data Statistics GUI.
    %
    %   See also: PLOTTOOLS, PLOTCHILD
    
    %   Copyright 1984-2017 The MathWorks, Inc.
    
    if ~(isa(obj, 'matlab.graphics.Graphics') || any(ishghandle(obj)))
        retval = false;
        return
    end
    
    if nargin < 2
        dim = 3;
    end
    
    if nargin < 3
        bfmode = false;
    end
    
    obj = handle(obj);
    retval = false;
    
    if  isvalid(obj) && validDataBehavior(obj, bfmode) && ...
            isSameXYLength(obj, bfmode) && ...
            isValidAxes(obj, bfmode) && ...
            ( validSpecgraphItem(obj, bfmode) || ...
            isa(obj,'matlab.graphics.chart.primitive.Line') || ...
            isa(obj,'matlab.graphics.primitive.Image') || ...
            isa(obj,'matlab.graphics.chart.primitive.Surface') || ...
            isa(obj,'matlab.graphics.primitive.Surface') || ...
            validLine(obj, bfmode))
        % Make sure no zdata exists
        retval = (dim ~= 2) || ~isprop(obj, 'ZData') || ...
            isempty(get(obj,'ZData')) || ~isRealZData(obj);
    end
end

%--------------------------------------------------------------------------
function tf = isValidAxes(obj, bfmode)
    % return true unless basic fitting mode and the axes is
    % not a cartesian axes with enabled DataDescriptor behavior.
    tf = true;
    if bfmode
        ax = ancestor(obj,'axes');
        tf = ~isempty(ax) && validDataBehavior(ax, bfmode);
    end
end

%--------------------------------------------------------------------------
function tf = isRealZData(obj)
    % real Z data is not a vector and values are not all zeros
    if isempty(obj.ZData)
        tf = false;
        return;
    end
    tf = ~(isvector(obj.ZData) && all(obj.ZData(:) == 0));
end

%--------------------------------------------------------------------------
function valid = validDataBehavior(obj, bfmode)
    % Return true unless a behavior object exists and it
    % is disabled.
    
    valid = true;
    hBehavior = hggetbehavior(obj,'DataDescriptor','-peek');
    if ~isempty(hBehavior) && ~get(hBehavior,'Enable') && bfmode
        valid = false;
    end
end

%--------------------------------------------------------------------------
function valid = validSpecgraphItem(l, bfmode)
    % Basic Fitting/Data Stats does not want baseline "lines"
    
    valid = false;
    cls = metaclass(l);
    pkg = cls.ContainingPackage;
    pkgname = pkg.Name;
    if strcmp(pkgname,'matlab.graphics.chart.primitive') || ...
        strcmp(pkgname,'matlab.graphics.function') || ...
        (isa(l, 'matlab.graphics.axis.decorator.Baseline') && ~bfmode)
        valid = true;
    end
end

%--------------------------------------------------------------------------
function valid = validLine(l, bfmode)
    % Basic Fitting/Data Stats want lines as long as their parents are axes
    % (except for baseline "lines").
    valid = false;
    if bfmode
        if isa(l, 'matlab.graphics.primitive.Line') ...
                && strcmpi(get(get(l, 'Parent'),'Type'), 'Axes') && ...
                ~isa(l, 'matlab.graphics.axis.decorator.Baseline')
            valid = true;
        end
    end
end

%--------------------------------------------------------------------------
function valid = isSameXYLength(l, bfmode)
    % Basic Fitting/Data Stats want lines only if the length of XData and 
    % YData is the same (if those properties exist). Also assume they are
    % different length if any of them is tall
    valid = true;
    if bfmode && isprop(l, 'XData') && isprop(l, 'YData') && ...     
         (istall(get(l, 'XData')) || istall(get(l, 'YData')) || ...
         ~( length(get(l, 'XData')) == length(get(l, 'YData')) ))
            valid = false;
    end
end
