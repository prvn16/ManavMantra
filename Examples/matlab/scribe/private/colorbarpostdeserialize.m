function colorbarpostdeserialize(ax,~)
%COLORBARPOSTDESERIALIZE Post-deserialization hook for colorbar
%   Internal helper function for colorbar.

%   Deletes the supplied colorbar and creates a new one in the same
%   place so that all the state and listeners are properly created.

%   Copyright 1984-2017 The MathWorks, Inc.

cbtitle = getappdata(double(ax),'CBTitle'); 
cbxlabel = getappdata(double(ax),'CBXLabel');
cbylabel = getappdata(double(ax),'CBYLabel');

if cbtitle ~= get(ax, 'Title')
    title(ax, get(cbtitle, 'String'));
    delete(cbtitle);
end
if cbxlabel ~= get(ax, 'xlabel')
    xlabel(ax, get(cbxlabel, 'String'));
    delete(cbxlabel);
end
if cbylabel ~= get(ax, 'ylabel')
    ylabel(ax, get(cbylabel, 'String'));
    delete(cbylabel);
end

ax = handle(ax);
ax.init();
