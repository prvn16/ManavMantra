function evalStr = tabularDisp(T, nlspacing)
% tabularDisp helper function to extract values from table and
% produce a custom display for MDF datastore.
%
%   Copyright 2016-2017 The MathWorks, Inc.

% maximum number of strings that we display using tabularDisp
MAX_STRINGS_DISPLAYED_IN_CELL = 3;

% get num items
numItems = size(T,1);
numCols = size(T,2);

ind = min(numItems,MAX_STRINGS_DISPLAYED_IN_CELL);
if numItems < ind
    ind = numItems;
end

% ind is always <= 3
% sets up the basic table structure with 3 variables (or fewer) and 3 rows
% (or fewer), if values within the rows are longer than 70 characters, we trim these values
numInds = min(3,numCols);
% initialize and grow the cell str
tabularArr = cell(1,numInds);

for ii = 1 : numInds
    oneCol = T(1:ind,ii);
    if strcmpi(class(oneCol),'string')
        oneCol = cell(oneCol);
    end
    thisVar = oneCol.Properties.VariableNames{1};
    if isnumeric(oneCol.(thisVar)) || islogical(oneCol.(thisVar))
        convertRow = num2str(oneCol.(thisVar));
    else
        convertRow = oneCol.(thisVar);
    end
    if iscell(convertRow)
        checkSize = cell2mat(cellfun(@(x) size(x,2) > 70,convertRow,...
            'UniformOutput',false));
    else
        checkSize = cell2mat(arrayfun(@(x) size(x,2) > 70,convertRow,...
            'UniformOutput',false));
    end
    if any(checkSize)
       for jj = 1 : size(checkSize,1)
           if checkSize(jj)
               convertRow(jj) = cellstr(['...', ...
                   convertRow{jj}(end-70:end)]);
           end
       end
    end
    tabularArr{ii} = convertRow;
end

% create an array with spaces - this is for display indentation purposes
fakeArr = repmat(' ',1,size(nlspacing,2)-10);

% combine the spaces array with the basic tabular structure from the for
% loop above and a variable with empty entries
numRows = min(size(tabularArr,2),numItems);
tab1 = table(repmat({fakeArr},[numRows,1]),'VariableNames',...
    {'space'});
tab2 = table.empty();
for ii = 1 : numInds
    if size(tabularArr{ii},1) == 1
        if isnumeric(T.(ii))
            tab2.(T.Properties.VariableNames{ii}) = str2double(tabularArr(ii));
        else
            tab2.(T.Properties.VariableNames{ii}) = tabularArr(ii);
        end
    else
        tab2.(T.Properties.VariableNames{ii}) = tabularArr{ii};
    end
end
tab3 = cell2table(cell(numRows,1));
finTable = [tab1, tab2, tab3];

% hacky way to display tables contained within the MDF datastore object
% we take the output of displaying the table and change it according to our
% display specifications
evalStr = evalc('disp(finTable)');

% remove the bold font
evalStr = strrep(strrep(evalStr,'<strong>',''),'</strong>','');

% adding text with ellipsis to signify more column variables
evalStr = strrep(strrep(evalStr,'Var1',sprintf('... and %d more columns',...
    numCols-3)),'[]','');

% replace the variable name 'space' with spaces (done for indentation purposes)
% using regular expressions
evalStr = strrep(evalStr,'space','     ');

% remove underscore for unrequired table variable names
R = regexp(evalStr,'____');
evalStr(R(end):R(end)+3) = ' ';
spaceStr = repmat(' ',1,size(nlspacing,2)-8);

% remove the space string from the first variable column
evalStr = strrep(evalStr,['''' fakeArr ''''],spaceStr);

% remove the first variable's underscore (from the tabular display)
R1 = regexp(evalStr,' _');
R2 = regexp(evalStr,'_ ');
evalStr(R1(1):R2(1)) = ' ';

% only add this string when there are more than 3 rows
if (numItems > 3)
    evalStr = [evalStr, sprintf('%s... and %d more rows', nlspacing,numItems-3)];
end
end