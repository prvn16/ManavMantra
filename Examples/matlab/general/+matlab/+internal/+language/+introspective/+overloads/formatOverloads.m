function text = formatOverloads(overloadList)

    text = '';
    
    if isempty(overloadList)
       return; 
    end

    overloadList = overloadList(:);
    for columnCount = 4:-1:1
        text = applyFormat(overloadList, columnCount);
        if max(cellfun('length',text)) < 75
            break; 
        end
    end
    text = [strjoin(text, newline) newline];
end

function text = applyFormat(overloads, columnCount)

    numberOfOverloads     = numel(overloads);
    maxOverloadsPerColumn = ceil(numberOfOverloads/columnCount);
    columnAssignment      = getColumnAssingment(numberOfOverloads, maxOverloadsPerColumn, columnCount);

    textColumn = repmat({''}, maxOverloadsPerColumn, 1);
    textArray  = repmat({textColumn}, 1, columnCount);
    
    for column = 1:columnCount  
        overloadColumn = overloads(column == columnAssignment);
        overloadColumn = makeUniformWidthColumn(overloadColumn);
        
        textArray{column}(1:numel(overloadColumn)) = overloadColumn;
    end
    
    text = strcat({'       '}, textArray{:});
    text = deblank(text);
end

function columnAssignment = getColumnAssingment(numberOfOverloads, maxOverloadsPerColumn, columnCount)
    overloadsPerColumn = maxOverloadsPerColumn*ones(1,columnCount);
    nonPaddedColumns   = mod(numberOfOverloads, columnCount);
    
    if nonPaddedColumns ~= 0
        overloadsPerColumn  = overloadsPerColumn - (1:columnCount > nonPaddedColumns);
    end
    
    columnAssignment = repelem(1:columnCount, overloadsPerColumn);
end

function columnOfText = makeUniformWidthColumn(cellOfOverloads)
    columnOfText = num2cell(char(cellOfOverloads), 2);
    columnOfText = strcat(columnOfText,{'    '});
end