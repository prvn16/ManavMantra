function postEdit(f)

% Copyright 2008-2014 The MathWorks, Inc.

% Customize the enabled state of figure Edit menu submenus when in Brushing
% Mode

% Disable the Delete menu
mDelete = findall(f,'Tag','figMenuEditDelete');
if ~isempty(mDelete)
    set(mDelete,'Enable','off');
end

% Enable the copy menu if any objects in the figure are brushed
mCopy = findall(f,'Tag','figMenuEditCopy');
if ~isempty(mCopy)
    bobj = findobj(f,'-function',...
          @(x) isprop(x,'BrushData') && ~isempty(get(x,'BrushData')) && ...
            any(x.BrushData(:)>0), 'HandleVisibility','on');
    if ~isempty(bobj)
        set(mCopy,'Enable','on')
    else
        set(mCopy,'Enable','off')
    end
end
