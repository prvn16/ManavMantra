function legKidsOut = expandLegendChildren(legKids)
%EXPANDLEGENDCHILDREN recursively goes through a list of graphics objects,
%   expanding groups whose "LegendEntry" display property is set to
%   "Children".

%   Copyright 2007-2014 The MathWorks, Inc.

legKidsOut = [];
if isempty(legKids)
    return
end

% Legend PlotChildren property expects objects of class primitive.Data
legKidsOut = matlab.graphics.primitive.Data.empty;

% only do the recurisve expanson (which is slow) if there is an hggroup
% present
if any(arrayfun(@(x) isa(x,'matlab.graphics.primitive.Group'),legKids)) 
    for i = 1:length(legKids)
        hA = get(legKids(i),'Annotation');
        if isobject(hA) && isvalid(hA)
            hL = get(hA,'LegendInformation');
            if isobject(hA) && isvalid(hA) && strcmpi(hL.IconDisplayStyle,'Children')
                if isprop(handle(legKids(i)),'Children') && ...
                        ~isempty(get(legKids(i),'Children'))
                    legKidsOut = [legKidsOut;...
                        expandLegendChildren(get(legKids(i),'Children'))];
                else
                    legKidsOut = [legKidsOut;legKids(i)];
                end
            else
                legKidsOut = [legKidsOut;legKids(i)];
            end
        else
            legKidsOut = [legKidsOut;legKids(i)];
        end
    end
    % make sure we haven't pulledin any non-legendable Group children
    legKidsOut = legKidsOut(islegendable(legKidsOut));
else
    % if there are no groups just return the input array
    legKidsOut = legKids;
end