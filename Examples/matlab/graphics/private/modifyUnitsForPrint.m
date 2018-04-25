function objUnitsModified = modifyUnitsForPrint(...
    modifyRevertFlag, varargin)
% MODIFYUNITSFORPRINT Modifies or restores a figure's axes and other
% object's units for printing. This undocumented helper function is for
% internal use.

% This function is called during the print path.  See usage in
% alternatePrintPath.m

% MODIFYUNITSFORPRINT('modify', h) can be used to modify the units of the
% axes and other objects.  The return will be: objUnitsModified
% which is a struct of cell arrays of the objects whose units
% were set to normalized, along with other related properties that were 
% modified so that the output scales correctly (e.g. props that are 
% implicitly measured in POINTS, such as line wides, marker sizes, and font units

% The modifyRevertFlag can be used when calling this function
% to 'revert' the changes made during the 'modify' step 
% MODIFYUNITSFORPRINT('revert', h, pixelObjects) reverts
% the units to their original values, before 'modify' was called.
% and restores/reverts the other related properties that had been modified
% so that the output scales correctly 

% Copyright 2013-2017 The MathWorks, Inc.

narginchk(2, 3)

% The set of units to modify
unitsToModify = {'centimeters', 'inches', 'characters', 'pixels', 'points'};

if strcmp(modifyRevertFlag, 'modify')
    narginchk(3, 3)
    h = varargin{1};
    % we want to look at all objects, and can save some time by
    % caching the handles up front 
    if ishghandle(h, 'figure')
        h = findall(h); 
    end
    dpiAdjustment = varargin{2};
    % Find all objects with units of centimeters, inches, characters, or
    % pixels, and change them to normalized so they can be printed
    % appropriately.  They will be stored as fields in struct
    % objUnitsModified
    hUnits = findall(h, '-property', 'units', '-depth', 0); 
    
    objUnitsModified = getObjWithUnits(hUnits, ...
        'Units', unitsToModify);

    unitsModified = structfun(@(x) ~isempty(x), objUnitsModified);
    if any(unitsModified)
        % If any units need changing, set them to normalized
        unitsToChange = unitsToModify(unitsModified);
        for idx=1:length(unitsToChange)
            cellfun(@(ph) set(ph, 'Units', 'normalized'), objUnitsModified.(unitsToChange{idx}).handles,...
                'UniformOutput', false);
        end
    end
    
    % for fontunits of pixels - change to points rather than normalized 
    hPixelFontUnits = findall(h, '-property', 'fontunits', 'fontunits', 'pixels', '-depth', 0); 
    objUnitsModified.fontunitsPixels = updatePixelFontUnits(hPixelFontUnits); 
    
    % call scaleForPrinting on those chart objects that have the method
    selfScalingObjects = findall(h, '-isa','matlab.graphics.chart.Chart', 'visible', 'on', '-method', 'scaleForPrinting', '-depth', 0);
    objUnitsModified.selfScalingObjects = selfScalingObjects;
    for sObj = 1:numel(selfScalingObjects)
        selfScalingObjects(sObj).scaleForPrinting('modify', dpiAdjustment);
    end
    
    % NOTE: - when restoring, need to restore the font size for the scaled
    % fonts first, before restoring font units to pixels (if any, from
    % above) 
    % for fontunits that are "measured", need to adjust scale if paperpos >
    % screen size 
    if dpiAdjustment ~= 1 
        fontUnitsSelector = {'fontunits', 'inches', '-or', 'fontunits', 'points', '-or', ...
                'fontunits', 'centimeters'};
        hMeasuredFontUnits = findall(h, '-property', 'fontunits', fontUnitsSelector, '-depth', 0); 
        assumedPointsFontUnits = findall(h, '-not', '-property', 'fontunits', '-property', 'fontsize', '-depth', 0);
        hMeasuredFontUnits = [hMeasuredFontUnits; assumedPointsFontUnits];
        scale = 1.0 / dpiAdjustment; 
        objUnitsModified.fontunitsMeasured = scaleObjectSizes(hMeasuredFontUnits, scale, 'FontSize', 'fontsize'); 
        
        % likewise scale line widths 
        lw = findall(h, 'visible', 'on', '-property', 'LineWidth', '-depth', 0); 
        objUnitsModified.lineobjects = scaleObjectSizes(lw, scale, 'LineWidth', 'linewidth');
        
        % and marker sizes 
        ms = findall(h, {'visible', 'on', '-property', 'MarkerSize', '-property', 'Marker', '-not', 'Marker', 'none'}, '-depth', 0);
        objUnitsModified.markerobjects = scaleObjectSizes(ms, scale, 'MarkerSize', 'markersize'); 
        
    else
        objUnitsModified.fontunitsMeasured = [];
        objUnitsModified.lineobjects       = [];
        objUnitsModified.markerobjects     = [];
    end
elseif strcmp(modifyRevertFlag, 'revert')
    narginchk(2, 2)
    objUnitsModified = varargin{1};
    
    if isempty(objUnitsModified)
        return
    end
    % revert fontsizes for objects w/fontunits that were "measured" 
    %  (undoes any scaling that was needed to account for paperposition
    %  size > screen size 
    if ~isempty(objUnitsModified.fontunitsMeasured) 
        cellfun(@(ph, sz) set(ph, 'FontSize', sz), ...
            objUnitsModified.fontunitsMeasured.handles, objUnitsModified.fontunitsMeasured.fontsize, 'UniformOutput', false);
        
        cellfun(@(ph, modeValue) setPropMode(ph, 'FontSizeMode', modeValue), ...
            objUnitsModified.fontunitsMeasured.handles, objUnitsModified.fontunitsMeasured.fontsizemode, 'UniformOutput', false);
    end
    % revert fontunits for objects which were modified 
    if ~isempty(objUnitsModified.fontunitsPixels) 
        if all(cellfun( @(ph) ishghandle(ph), objUnitsModified.fontunitsPixels.handles))
            cellfun(@(ph, fSize) set(ph,  'FontUnits', 'pixels', 'FontSize', fSize),...
                objUnitsModified.fontunitsPixels.handles, objUnitsModified.fontunitsPixels.fontsize, 'UniformOutput', false);

            % restore modes as well 
            cellfun(@(ph, modeValue) setPropMode(ph, 'FontSizeMode', modeValue), ...
                objUnitsModified.fontunitsPixels.handles, objUnitsModified.fontunitsPixels.fontsizemode, 'UniformOutput', false);
            cellfun(@(ph, modeValue) setPropMode(ph, 'FontUnitsMode', modeValue), ...
                objUnitsModified.fontunitsPixels.handles, objUnitsModified.fontunitsPixels.fontunitsmode, 'UniformOutput', false);
        end
    end
    % restore line widths and modes
    if ~isempty(objUnitsModified.lineobjects)
        cellfun(@(ph, sz) set(ph, 'LineWidth', sz), ...
            objUnitsModified.lineobjects.handles, objUnitsModified.lineobjects.linewidth, 'UniformOutput', false);
        
        cellfun(@(ph, modeValue) setPropMode(ph, 'LineWidthMode', modeValue), ...
            objUnitsModified.lineobjects.handles, objUnitsModified.lineobjects.linewidthmode, 'UniformOutput', false);
    end
    % restore marker sizes and modes
    if ~isempty(objUnitsModified.markerobjects)
        cellfun(@(ph, sz) set(ph, 'MarkerSize', sz), ...
            objUnitsModified.markerobjects.handles, objUnitsModified.markerobjects.markersize, 'UniformOutput', false);
        
        cellfun(@(ph, modeValue) setPropMode(ph, 'MarkerSizeMode', modeValue), ...
            objUnitsModified.markerobjects.handles, objUnitsModified.markerobjects.markersizemode, 'UniformOutput', false);
    end
    
    selfScalingObjects = objUnitsModified.selfScalingObjects;
    for sObj = 1:numel(selfScalingObjects)
        selfScalingObjects(sObj).scaleForPrinting('revert');
    end

    % Revert units and position for objects which were modified
    % Need to loop over property sets because vectorized sets with cell
    % array inputs is not enabled.
    for idx=1:length(unitsToModify)
        units = unitsToModify{idx};
        if ~isempty(objUnitsModified.(units))
            if all(cellfun(@(ph) ishghandle(ph), objUnitsModified.(units).handles))                
                cellfun(@(ph, pos) set(ph, 'Units', units, 'Position', pos),...
                    objUnitsModified.(units).handles, objUnitsModified.(units).positions, 'UniformOutput', false);
                % restore modes as well ... 
                cellfun(@(ph, modeValue) setPropMode(ph, 'PositionMode', modeValue), ...
                    objUnitsModified.(units).handles,objUnitsModified.(units).positionmode, 'UniformOutput', false);
                cellfun(@(ph, modeValue) setPropMode(ph, 'UnitsMode', modeValue), ...
                    objUnitsModified.(units).handles,objUnitsModified.(units).unitsmode, 'UniformOutput', false);

            end
        end
    end
else
    error(message('MATLAB:modifyunitsforprint:invalidFirstArgument'))
end

end

function objUnitsModified = getObjWithUnits(h, unitsProp, units)

% Returns an array of objects which have the unitsProp property
% value set to the specified units.
saveProp = lower(unitsProp);
for unitsIdx = 1:length(units)
    objWithUnits = findall(h, 'flat', unitsProp, units{unitsIdx}, '-property', 'Position');
    
    % Don't include the figure itself in this list
    handles = objWithUnits(~ishghandle(objWithUnits, 'figure'));
    objUnitsModified.(units{unitsIdx}).handles = num2cell(handles);
    
    % The get command returns a cell array when passed multiple
    % handles. To keep the code simple downstream, wrap the single
    % handle result in a cell array too.
    objUnitsModified.(units{unitsIdx}).positions = cellfun(@(ph)get(ph, 'Position'), ...
        objUnitsModified.(units{unitsIdx}).handles, 'UniformOutput', false);
    % also store positionmode and unitsmode prop values
    objUnitsModified.(units{unitsIdx}).positionmode = ...
        cellfun(@(ph) getPropMode(ph, 'Position'), objUnitsModified.(units{unitsIdx}).handles, 'UniformOutput', false);
    objUnitsModified.(units{unitsIdx}).([saveProp 'mode']) = ...
        cellfun(@(ph) getPropMode(ph, unitsProp), objUnitsModified.(units{unitsIdx}).handles, 'UniformOutput', false);
end

end

function fontunitsPixels = updatePixelFontUnits(hFontUnits)

fontunitsPixels = {};
hFontUnits = num2cell(hFontUnits);
if ~isempty(hFontUnits)
    fontunitsPixels.handles = hFontUnits;
    fontunitsPixels.fontsize = cellfun(@(ph) get(ph, 'FontSize'), hFontUnits, 'UniformOutput', false);
    % save fontsize modes as well ...
    fontunitsPixels.fontsizemode = ...
        cellfun(@(ph) getPropMode(ph, 'FontSize'), hFontUnits, 'UniformOutput', false);    
    % save font units modes too ...
    fontunitsPixels.fontunitsmode = ...
        cellfun(@(ph) getPropMode(ph, 'FontUnits'), hFontUnits, 'UniformOutput', false);
    % set pixel fontunits to points
    cellfun(@(ph) set(ph, 'FontUnits', 'points'), fontunitsPixels.handles, ...
        'UniformOutput', false);
end

end

function objects = scaleObjectSizes(objs, scale, prop, savePropName)

objects = [];
objs = num2cell(objs);
if ~isempty(objs)
    objects.handles = objs;
    objects.(savePropName) = cellfun(@(ph) get(ph, prop), objs, 'UniformOutput', false);    
    % get prop modes as well ...
    objects.([savePropName 'mode']) = ...
        cellfun(@(ph) getPropMode(ph, prop), objs, 'UniformOutput', false);
    % scale the prop values
    cellfun(@(ph, sz) set(ph, prop, sz*scale), ...
        objs, objects.(savePropName), 'UniformOutput', false);
end

end

function mode = getPropMode(obj, prop)

mode = [];
if isprop(obj, [prop 'Mode'])
    mode = obj.([prop 'Mode']);
end

end

function setPropMode(obj, modeProp, modeValue)

if isprop(obj, modeProp)
    obj.(modeProp) = modeValue;
end

end

