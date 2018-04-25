function th = plot(ax, layout, args, props)
% This internal helper function may be removed in a future release.

%PLOT Plot wordcloud data
%   PLOT(AX, LAYOUT,ARGS,PROPS) makes text objects with positions
%   given in LAYOUT, data in ARGS and text properties in PROPS.

% Copyright 2016-2017 The MathWorks, Inc.

num_words = length(args.words);
layoutSize = layout.layoutSize;
ax.XLim = [-layoutSize(1) layoutSize(1)]/2;
ax.YLim = [-layoutSize(2) layoutSize(2)]/2;

colors = args.colorData;
th = gobjects(1,num_words);
for k=1:num_words
    fsize = layout.fontsize(k);
    x = layout.pos(1,k);
    y = layout.pos(2,k);
    if fsize > 0
        th(k) = text(x,y,char(args.words(k)),'FontUnits','norm','FontSize',fsize,props);
        c = colors(k,:);
        if ~all(isfinite(c))
            th(k).Visible = 'off';
        else
            th(k).Color = c;
        end
    end
end

