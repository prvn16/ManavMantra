function hgS = hgsaveStructClass(h)
%hgsaveStructClass Save object handles to a structure.
%
%  hgsaveStructClass converts handles into a structure ready for saving.
%  This function is called when MATLAB is using objects as HG handles.

%   Copyright 2009 The MathWorks, Inc.


% capture necessary information of linked axes , save struct for HG1 format
% set helper information in application data
allAxes = unique(findall(h,'Type','axes'));
l = length(allAxes);
linkage = [];
for i = 1:l
    % for all the axes which are linked, obtain handle to the linkprop objects
    if isappdata(allAxes(i),'graphics_linkaxes')
        temp_link = getappdata(allAxes(i),'graphics_linkaxes');
        if isfield(temp_link,'LinkProp')
            if ishandle(temp_link.LinkProp)
                linkage = [linkage temp_link.LinkProp];
            end
        end
    end
end

linkage = unique(linkage);
targets = [];
for i = 1:length(linkage)
    param = '';
    t = get(linkage(i),'Targets');
    props = get(linkage(i),'PropertyNames');
    if any(strcmp(props,'XLim'))
        param = strcat(param,'x');
    end
    if any(strcmp(props,'YLim'))
        param = strcat(param,'y');
    end
    for j = 1:length(t)
        %Only store this information if the target is being saved
        if any(allAxes == t(j))
            setappdata(t(j),'graphics_linkaxes_targets',i);
            setappdata(t(j),'graphics_linkaxes_props',param);
        else
            t(j) = handle(-500);
        end
    end
    t(~ishandle(t)) = [];
    targets = [targets t]; 
end


hgS = handle2struct(h);



