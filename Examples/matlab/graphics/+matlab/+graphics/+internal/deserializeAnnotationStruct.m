function deserializeAnnotationStruct(obj, struct)

%   Copyright 2013 The MathWorks, Inc.

    annotation = obj.Annotation;
    annotation.LegendInformation.IconDisplayStyle = struct.LegendInformation.IconDisplayStyle;
end
