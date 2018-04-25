function [hList,nList]=bfitgetdata(figureH, dim)
%BFITGETDATA Finds all lines of a figure 
% and returns a list of those handles with appropriate names  

%   Copyright 1984-2014 The MathWorks, Inc.
%     

axesList = datachildren(figureH);
tmp = plotchild(axesList, dim, true);
tmp = flipud(tmp(:)); % so comes out as added to figure
bfitdataall = double(getappdata(figureH,'Basic_Fit_Data_All'));

% This function needs to return "good" lines as well as lines that 
% have just become "bad". "Good" lines have no zdata and lengths of 
% xdata and ydata are equal. 
 
j = 1;
h = [];
for i = length(tmp):-1:1
    if shouldBeAdded(tmp(i))
	   	h(j) = double(tmp(i));
		j = j+1;
    end
end
if length(h)>1
   h = h(end:-1:1);
end

% reorder h so fits, residuals, eval results, data stats, if any, are at the end
bfitind = false(size(h));
for i = 1:length(h)
    value = getappdata(double(h(i)),'bfit');
    if isempty(value)
        fitappdata.type = 'data potential';
        fitappdata.index = [];
        setappdata(double(h(i)),'bfit',fitappdata);
        setappdata(double(h(i)), 'Basic_Fit_Copy_Flag', 1);
        if ~isempty(bfitdataall)
            % pasting an axes will cause the lines to already be recorded
            if ~any(h(i) == bfitdataall)
                bfitdataall(end + 1) = h(i); %#ok<AGROW>
            end
        else
            bfitdataall(1) = h(i);
        end
    elseif ~isequal(value.type,'data') && ~isequal(value.type,'data potential') 
             bfitind(i) = true;
    end
end % for
setappdata(figureH,'Basic_Fit_Data_All', handle(bfitdataall));
% This is all data or potential data in the figure that isn't created by the gui (fit or data stat)
% and the axes that goes with them.
bfitdata = h(~bfitind);
dataaxescell = ancestor(handle(bfitdata),'axes');
if iscell(dataaxescell)
    dataaxes = unique([dataaxescell{:}]);
else % scalar
    dataaxes = dataaxescell;
end
setgraphicappdata(figureH,'Basic_Fit_Axes_All',dataaxes);

% code to get selected handles
selectedHandles = [];
aFigObjH = getobj(figureH);
if ~isempty(aFigObjH)
    dragBinH = aFigObjH.DragObjects;
    if ~isempty(dragBinH.Items)
        objectVector = struct(dragBinH.Items);
        if ~isempty(objectVector)
            selectedHandles = [objectVector.HGHandle];
        end
    end
end
selected = ismember(h,selectedHandles);

% Move the selected lines to the front, then the unselected lines,
% then the selected fits followed by the unselected fits.
% If you want data and fit/stat lines, use this:
% h = [h(selected & ~bfitind); h(~selected & ~bfitind); 
%    h(selected & bfitind); h(~selected & bfitind)];
% If you want just data lines, use this:
h = [h(selected & ~bfitind), h(~selected & ~bfitind)]; 

% If data is not tagged, give it a name.
% Put the tag or name in the appdata
[hList, nList] = datanames(h,figureH);

%-----------------------------------------------------------------
function retval = shouldBeAdded(line)
% Should be added if the line is "good" (there is no zdata and length of xdata and ydata 
% are the same) OR if it was "good" data that has gone "bad" (there is z data or lengths of
% xdata or ydata are not equal).

retval = false;
if ~isvalid(line)
    return;
end
zd = [];
if isprop(line, 'zdata')
    zd = get(line, 'zdata');
end
xd = get(line, 'xdata');
yd = get(line, 'ydata');

if isempty(zd) &&  length(xd) == length(yd)
    retval = true;
elseif isappdata(double(line), 'bfit')
    retval = true;
end

%-----------------------------------------------------------------
function [hList,tagList]=datanames(h,figureH)

%Gets name descriptions for handles
%returns two column cell arrays
if isempty(h)
    hList={};
    tagList={};
    countstart = 1; % Start counting at one
else
    hList=num2cell(h);
    hList=hList(:);
    
    countstart = getappdata(figureH,'Basic_Fit_Data_Counter');
    tagList=get(handle(h),'Tag');
    if length(h)==1
        tagList={tagList};
    else
        tagList = cell(1, length(h));
    end
    
    % if appdataname exists, use it.
    % else if DisplayName is a property and it is not empty, use it
    % else use 'tag'
    % else create a name using the counter.
    for i=1:length(h)
        appdataname = getappdata(double(h(i)),'bfit_dataname');
        if isempty(appdataname)
            if isprop(handle(h(i)), 'DisplayName') && ~isempty(get(h(i), 'DisplayName'))
                tagList{i} = get(h(i), 'DisplayName');
            elseif isempty(tagList{i})
                t = sprintf('data%s', int2str(countstart));
                tagList{i} = t;
                countstart = countstart + 1;
            end
            d = tagList{i};
            % name must be a char row vector.
            if ~isequal(size(d,1),1)
                d = d';
                d = (d(:))';
            end
            setappdata(double(h(i)),'bfit_dataname',d);
        else
            tagList{i} = appdataname;
        end
    end
end
setappdata(figureH,'Basic_Fit_Data_Counter',countstart);

% make sure names are unique for display in the GUIs (if there are 
% duplicate names in a drop down, only the first ever gets selected).
[~, uniqueIndex, origIndex] = unique(tagList);
if length(uniqueIndex) == length(origIndex) % names already unique
    return;
end
names = tagList;
for i = 1:length(uniqueIndex) % for each unique name
    findResults = find(origIndex == i);
    if length(findResults) > 1  % non unique
        tempnamePrefix = tagList{uniqueIndex(i)};
        for j = 1:length(findResults)
            tempname = [tempnamePrefix ' ('  int2str(j) ')']; 
            % make sure new name is unique
            k = j + 1;
            while any(strcmp(tempname, names))
                tempname = [tempnamePrefix ' ('  int2str(k) ')']; 
                k = k+1;
            end
            names{findResults(j)} = tempname;
        end
    end
end
tagList = names;
