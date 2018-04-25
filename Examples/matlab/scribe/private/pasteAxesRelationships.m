function serializedStruct = pasteAxesRelationships(serializedStruct, obj)
% Restore axes relationships

% Copyright 2012-2015 The MathWorks, Inc.

    if isfield(serializedStruct, 'specialChild')
        ax = ancestor(obj, 'axes');
        prop = serializedStruct.specialChild;
        if strcmp(prop, 'Title') || ~isa(ax, 'matlab.graphics.axis.PolarAxes')
            set(ax, prop, obj);
        end
    end
end
