function clearNotify(h, flag)
%clearNotify Perform actions when a figure has some content cleared

%   Copyright 2014-2016 The MathWorks, Inc.

fig = [];
for k=1:length(h)
    obj = h(k);
    if isgraphics(obj) 
        f = ancestor(obj,'figure');
        if ~isempty(f)
            fig = f;
            break;
        end
    end
end

% If this is a live script figure then capture any info before 
% the figure is cleared.
if ~isempty(fig) && isappdata(fig, 'EDITOR_APPDATA')
    if nargin == 1
        flag = '';
    end
    v = getappdata(fig,'EDITOR_APPDATA');
    if ischar(v) && strcmp(v,'unittest') % unit testing API for when clearNotify is called.
        setappdata(fig,'EDITOR_APPDATA',flag);
    else
        matlab.internal.editor.FigureManager.figureBeingCleared(fig, flag);
    end
end
