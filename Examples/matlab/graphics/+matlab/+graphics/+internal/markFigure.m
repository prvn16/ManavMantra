function markFigure(objs)
%markFigure Mark an editor figure as changed

%   Copyright 2015 The MathWorks, Inc.

for obj = objs(:)'
    if isgraphics(obj)
        fig = ancestor(obj,'figure');
        if ~isempty(fig) && isappdata(fig, 'EDITOR_APPDATA')
            % toggling Color to mark the figure as changed
            color = get(fig,'Color');
            newcolor = 1-color;
            if isequal(color, newcolor)
                newcolor = [0 0 0];
            end
            set(fig,'Color',newcolor);
            set(fig,'Color',color);
        end
    end
end
