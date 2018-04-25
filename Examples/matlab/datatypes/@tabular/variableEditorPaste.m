function out = variableEditorPaste(this,rows,columns,data)
% This function is for internal use only and will change in a
% future release.  Do not use this function.

% Performs a paste operation on data from the clipboard which was not
% obtained from another table.

%   Copyright 2011-2016 The MathWorks, Inc.

import matlab.internal.datatypes.istabular

    if istabular(data)
        [nrows,ncols] = variableEditorGridSize(data);
    else
        ncols = size(data,2);
        nrows = size(data,1);
    end

    [varNames,varIndices,classes] = variableEditorColumnNames(this);

    if isdatetime(this.rowDim.labels) || isduration(this.rowDim.labels) 
        % varNames, varIndices and classes includes the rownames, if they are
        % datetimes or duration. This isn't needed for the paste function.
        varNames(1) = [];
        varIndices(1) = [];
        varIndices = varIndices-1;
        classes(1) = [];
    
        % col also includes the time column, so decrement it
        columns = columns-1;
    end
    
    if length(columns) == 1 && columns(1) == 0 && ...
        (~istabular(data) || (~isdatetime(data.rowDim.labels) && ... 
            ~isduration(data.rowDim.labels)))
    % If the user has only selected the time column (0), and they are
    % pasting data which is not a table (hopefull it is a datetime or
    % the row names as durations or datetimes.  (If multiple columns are
    % selected, or if the table contains row names, then this will be
    % handled as a standard paste below).
    
    if isa(data,'table')
        % This will work if it is a table containing datetimes or
        % durations
        data = table2array(data);
    end
    
    % Pasting into the row labels only
    if (isduration(this.rowDim.labels) && isduration(data)) || ...
            (isdatetime(this.rowDim.labels) && isdatetime(data))
        
        % If the number of pasted rows does not match the number of selected rows,
        % just paste rows starting at the top-most row
        if length(rows)~=nrows && nrows>1
            rows = rows(1):rows(end)+nrows-1;
        end
        if length(rows) > nrows && nrows == 1
            % resize the data
            data = repmat(data, length(rows), 1);
        end
        
        this.rowDim = this.rowDim.setLabels(data, rows, true);
        out = this;
        return
    end
end

isCatClass = cellfun(@(x)isa(x,'categorical'),this.data);
tableSize = size(this);

% Find the table indices which correspond to the columnIntervals. If the
% number of pasted columns does not match the number of selected columns,
% just paste columns starting at the left-most column 
if length(columns)~=ncols && ncols > 1
    I = unique(find(varIndices(1:end-1)>=columns(1) & varIndices(1:end-1)<=columns(end)+ncols-1));
    columns = columns(1):columns(end)+ncols-1;
else
    % Find the indices of each column
    colIndices=zeros(varIndices(end),1);
    colIndices(varIndices)=1;
    colIndices = cumsum(colIndices);
    colIndices = colIndices(1:end-1);
    
    % Index into it to convert (ignoring columns beyond the last table
    % column)
    I = unique(colIndices(columns(columns<=varIndices(end-1))));
end

% If the number of pasted rows does not match the number of selected rows,
% just paste rows starting at the top-most row 
if length(rows)~=nrows && nrows > 1
    rows = rows(1):rows(end)+nrows-1;
end
 

% Paste data one variable at a time, converting from a cell array for
% non-cell table variables

% Paste data onto existing table variables
col = 1;
if ~isempty(I)
    % Loop through variable indices from min(I) to max(I)
    for k=1:length(I)
        if istabular(data)
            if width(data) == 1
                % Allow pasting of a single cell selection into multiple
                % cells
                s = struct('type', {'()'}, 'subs', {{':', 1}});
            else
                s = struct('type', {'()'}, 'subs', {{':', k}});      
            end
            variableData = subsref(data,s);%data(:,k);
            % this(rows,I(k)) = variableData
            s = struct('type',{'()'},'subs',{{rows,I(k)}});
            this = subsasgn(this,s,variableData);
        else
            variableData = data(:,col:min(size(data,2),col+varIndices(I(k)+1)-varIndices(I(k))-1));
            if isempty(variableData) && isscalar(data)
                variableData = data;
            end
            col = col+varIndices(I(k)+1)-varIndices(I(k));

            % this.VarName(rows,1:size(variableData,2)) = variableData
            s = struct('type',{'.','()'},'subs',{varNames{I(k)},{rows,1:size(variableData,2)}});       
            if strcmp(classes{I(k)},'cell')
                this = subsasgn(this,s,variableData);
            elseif isCatClass(I(k)) % categorical or its subclasses
                % This supports assignment from a categorical or a cellstr.
                % Assignment of a categorical will fail if categories don't
                % match and the target is ordinal or protected.
                this = subsasgn(this,s,variableData);
            else
                try
                    this = subsasgn(this,s,cell2mat(variableData));
                catch %#ok<CTCH>
                    this = subsasgn(this,s,variableData);
                end
            end
        end
    end  
end

if istabular(data) && data.rowDim.hasLabels
   if this.rowDim.hasLabels
       extendRows = (rows > tableSize(1)); % rows in the source that will be new rows in the destination
       if any(extendRows)
           % Preserve the destination's row labels, but paste labels from the source for rows
           % that extend the destination, fixing any that duplicate existing labels.
           this.rowDim = this.rowDim.setLabels(data.rowDim.labels(extendRows),rows(extendRows),true);
       elseif isdatetime(this.rowDim.labels) || isduration(this.rowDim.labels)
           this.rowDim = this.rowDim.setLabels(data.rowDim.labels, rows, true);
       end
   else
       % Copy row labels from the source, creating default labels for the remaining rows.
       rowLabels = this.rowDim.emptyLabels(this.rowDim.length);
       rowLabels(rows) = data.rowDim.labels;
       this.rowDim = this.rowDim.setLabels(rowLabels,[],true,true); % fills in empty labels
   end
end
   
% Any remaining pasted data should be added in the columns to the right of
% the table. Discontiguous column selection in this region must be
% ignored since the table does not allow empty variables.
appendedColumnCount = sum(columns>=varIndices(end));
if appendedColumnCount>0    
    %appendedCols = startColumn+ncols-varIndices(end);
    
    % Sub-reference the pasted data to get the part to be pasted after the 
    % table.
    if istabular(data)
        [~,srcVarIndices] = variableEditorColumnNames(data);
        firstAppendedColumnPosition = ncols-appendedColumnCount+1;
        srcStartIndex = find(srcVarIndices(1:end-1)<=firstAppendedColumnPosition,1,'last');
        appendedIndices = size(data,2)-srcStartIndex+1;
        s = struct('type',{'()'},'subs',{{':',size(data,2)-appendedIndices+1:size(data,2)}});
        data = subsref(data,s);
    else
        appendedIndices = appendedColumnCount;
        data = data(:,end-appendedColumnCount+1:end);
    end
    
    lastVariableIndex = length(varIndices)-1;
    for index=size(data,2)-appendedIndices+1:size(data,2) 
        % variableData = data(:,index);
        s = struct('type',{'()'},'subs',{{':',index}});
        variableData = subsref(data,s);
        
        % this(rows,lastVariableIndex+index) = variableData
        s = struct('type','()','subs',{{rows,lastVariableIndex+index}});
        
        if istabular(data)
            this = subsasgn(this,s,variableData);
               
            %this.Properties.VariableNames{end} = newVarName;
            newVarName = localGetUniqueVarName(data.varDim.labels{index},this.varDim.labels);
            this.varDim = this.varDim.setLabels(newVarName,size(this,2));
        else   
            try
                % Prevent char arrays
                if all(cellfun(@(x) isnumeric(x),variableData))
                    this = subsasgn(this,s,table(cell2mat(variableData)));
                else
                    this = subsasgn(this,s,table(variableData));
                end
            catch %#ok<CTCH>
                this = subsasgn(this,s,table(variableData));
            end
        end
    end
end
out = this;


function varName = localGetUniqueVarName(newVarName,varNames)

% Append digits to guarantee a unique variable name
ind = 1;
varName = newVarName;
while any(strcmp(varName,varNames))
    varName = [newVarName,num2str(ind)];
    ind=ind+1;
end
