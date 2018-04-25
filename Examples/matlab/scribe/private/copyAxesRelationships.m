function serializedStruct = copyAxesRelationships(serializedStruct, obj)
% Capture axes relationships

% Copyright 2012-2015 The MathWorks, Inc.

    if ~strcmp(obj.Type,'text') || ~strcmp(obj.PositionMode,'auto')
        return;
    end
    parentax = ancestor(obj, 'axes');
    if get(parentax,'Title') == obj
        serializedStruct.specialChild = 'Title';
    elseif ~isa(parentax,'matlab.graphics.axis.PolarAxes')
        if get(parentax,'XLabel') == obj
            serializedStruct.specialChild = 'XLabel';
        elseif get(parentax,'YLabel') == obj
            serializedStruct.specialChild = 'YLabel';
        elseif get(parentax,'ZLabel') == obj
            serializedStruct.specialChild = 'ZLabel';
        end
    end
end
