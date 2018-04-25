function [names,indices,classes,iscellStr,charArrayWidths] = variableEditorColumnNames(a)
% This function is for internal use only and will change in a
% future release.  Do not use this function.

% Undocumented method used by the Variable Editor to determine the names and
% properties of table columns.

%   Copyright 2011-2016 The MathWorks, Inc.

% Check to see if the table contains row names which are datetimes or
% durations.  If so, these will be included along with the data.

import matlab.internal.datatypes.istabular

dateOrDurationRows = isdatetime(a.rowDim.labels) || isduration(a.rowDim.labels);

if dateOrDurationRows
    % Include rownames which are datetimes or duration along with the data.
    % So the names needs to include this (the dimension name)
    names = [a.Properties.DimensionNames(1) a.varDim.labels];
else
    names = a.varDim.labels;
end

% indices identifies the column positions of each table variable with
% an additional last value of indices is the column after the last column of the
% dataset.
if nargout >= 2
    if isempty(a)
        indices = 1:size(a,2)+1;
    else
        indices = cumsum([1 cellfun(@(x) size(x,2)*ismatrix(x)*~ischar(x)*~isa(x,'dataset')*~istabular(x)...
    +ischar(x)+isa(x,'dataset')+istabular(x),a.data)]);
    end
    
    if dateOrDurationRows
        % Include rownames which are datetimes or duration along with the
        % data.  So the indices needs to include this extra column.
        indices = [1 indices+1];
    end
end

if nargout>=3
    classes = cellfun(@class,a.data,'UniformOutput',false); 
    if dateOrDurationRows
        % Include rownames which are datetimes or duration along with the data.
        classes = [class(a.rowDim.labels) classes];
    end
end


if nargout>=4
    iscellStr = false(length(names),1);
    a_data = a.data;
    if dateOrDurationRows
        a_data = [{a.rowDim.labels} a_data];
    end
    for index=1:length(names)
        if strcmp(classes{index},'cell')
            iscellStr(index) = iscellstr(a_data{index});
        end
    end
end

% Determine the number of chars in any char array columns
if nargout>=5
    charArrayWidths = zeros(length(names),1);
    for index=1:length(names)
        if strcmp(classes{index},'char')
            charArrayWidths(index) = size(a_data{index},2);
        end
    end
end
