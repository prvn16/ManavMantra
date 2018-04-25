function out = variableEditorInsert(this,orientation,row,col,data)
% This function is for internal use only and will change in a
% future release.  Do not use this function.

% Performs a insert operation on data from the clipboard.

%   Copyright 2011-2016 The MathWorks, Inc.

numVars = size(this,2);
numRows = size(this,1);

% Get the inserted data as a dataset
if matlab.internal.datatypes.istabular(data)
    varData = data;
elseif iscell(data)        
    % Try to create a table to numeric data first
    try
        varData = table(cell2mat(data));
    catch me %#ok<NASGU>
        varData = table(data);
    end
else
    varData = table(data);
end

[~,varIndices] = variableEditorColumnNames(this);
if isdatetime(this.rowDim.labels) || isduration(this.rowDim.labels)
    % colNames, varIndices and colClasses include the rownames, if they are
    % datetimes or duration.  These aren't needed for the insert function.
    varIndices(1) = [];
    varIndices = varIndices-1;
    
    if strcmp('columns',orientation)
        % col also includes the time column, so decrement it
        col = col-1;
    end
end
insertIndex = find(varIndices<=col,1,'last');

% Find the insertion index
if strcmp('columns',orientation)
    
    % Did the copy include the row name data?  If the first column of the
    % copied data is identical to the row names, then remove it
    if varData.rowDim.hasLabels && ...
            (isdatetime(varData.rowDim.labels) || ...
            isduration(varData.rowDim.labels))
        c = table2cell(varData);
        col1 = [c{:,1}]';
        if isequal(col1, varData.rowDim.labels)
            c(:,1) = [];
            varNames = varData.varDim.labels;
            varNames(1) = [];
            varData = cell2table(c, 'VariableNames', varNames);
        end
    end
        
    % Add the pasted table after the last column
    %this(row:size(data,1)+row-1,end+1:end+size(data,2)) = data;
    newVarIndices = size(this,2)+1:size(this,2)+size(varData,2);
    this = subsasgn(this,struct('type','()','subs',{{row:size(varData,1)+row-1,newVarIndices}}),varData); 
    for k=1:length(newVarIndices)
        % Try to assign the variable name of each inserted table

        % Append digits to guarantee a unique variable name
        newVarName = varData.varDim.labels{k};
        ind = 1;
        while any(strcmp(newVarName,this.varDim.labels))
            newVarName = [varData.varDim.labels{k},num2str(ind)];
            ind=ind+1;
        end

        %this.Properties.VarNames{newVarIndices(k)} = newVarName;
        this.varDim = this.varDim.setLabels(newVarName,newVarIndices(k));
    end

    % Move the appended table to the inserted index
    %this = this(:,[1:index numVars+1:end index+1:numVars]);
    this = subsref(this,struct('type','()','subs',{{1:size(this,1),...
        [1:insertIndex-1 numVars+1:size(this,2) insertIndex:numVars]}}));

else
    if row>numRows+1
       % Add the pasted table after the last row
       % this(row:row+size(varData,1)-1:insertIndex+insertIndex+size(data,2)-1)
       % = varData
       out = subsasgn(this,struct('type','()','subs',...
           {{row:row+size(varData,1)-1,insertIndex:insertIndex+size(data,2)-1}}),...
           varData);  
       return
    end

   % Add the pasted table after the last row
   % this(numRows+1:numRows+size(varData,1):insertIndex+insertIndex+size(data,2)-1)
   % = varData
   try
       this = subsasgn(this,struct('type','()','subs',...
           {{numRows+1:numRows+size(varData,1), ...
           insertIndex:insertIndex+size(data,2)-1}}),...
           varData);
   catch
       % Its possible that the table data contains the row labels as extra
       % data.  Try the insert again after removing this.
       c = table2cell(varData);
       c(:,1) = [];
       tmpVarData = cell2table(c);
       this = subsasgn(this,struct('type','()','subs',...
           {{numRows+1:numRows+size(tmpVarData,1), ...
           insertIndex:insertIndex+size(tmpVarData,2)-1}}),...
           tmpVarData);
   end
 
   % Try to preserve the row labels so that rows can be cut and inserted
   % with their RowLabels intact.
   if varData.rowDim.hasLabels
       this.rowDim = this.rowDim.setLabels(varData.rowDim.labels, ...
           numRows+1:numRows+size(varData,1), true);
   end

   % Move the appended table to the inserted row
   % this = this([1:row numRows+1:end row+1:numRows]);
   if insertIndex<=numRows
       this = subsref(this,struct('type','()','subs',{{
          [1:row-1 numRows+1:numRows+size(varData,1) row:numRows],1:numVars}}));
   end
end

out = this;
