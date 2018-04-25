function res=islegendable(in_array)
%ISLEGENDABLE Tests if an object can be in a legend
%    RES = ISLEGENDABLE(H) returns true if graphics object H can
%    be shown in a legend.

%   Copyright 1984-2014 The MathWorks, Inc.

res = false(1,numel(in_array));

for i = 1:numel(in_array)
    h = in_array(i);
    if isa(h,'matlab.graphics.mixin.Legendable') && ...
       isvalid(h) && ...
       strcmp(h.HandleVisibility,'on') && ...
       strcmpi(h.LegendDisplay,'on') && ...
       ~strcmpi(h.Annotation.LegendInformation.IconDisplayStyle,'off') && ...
       hasbehavior(h,'legend')

        res(i) = true;

        % if HGGroup, must have children
        if res(i) && isa(h,'matlab.graphics.primitive.Group')
            if isempty(h.Children')
                res(i) = false;
            end
        end
    end
end
