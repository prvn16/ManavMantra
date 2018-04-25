function [state,I] = isFigureLinked(fig)

I = [];
state = false;
fig = handle(fig);

if ~isempty(fig.findprop('LinkPlot')) && fig.LinkPlot 
    h = datamanager.LinkplotManager.getInstance();
    if ~isempty(h.Figures)
        I = find([h.Figures.('Figure')]==fig);
        if ~isempty(I)
            state = true;
        end
    end
end
