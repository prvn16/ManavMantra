function [numericArray, textArray] = xlsreadTrimArrays(numericArray, textArray)
    % trim leading rows or cols
    % if the string result has dimensions corresponding to a column or row of
    % zeros in the matrix result, trim the zeros.
    [mn, nn] = size(numericArray);
    [ms, ns] = size(textArray);
    
    if ms == mn || ms == 0
        % trim leading column(textArray) from numeric data
        firstcolm = 1;
        while (firstcolm<=nn && all(isnan(numericArray(:,firstcolm))))
            firstcolm = firstcolm+1;
        end
        numericArray=numericArray(:,firstcolm:end);
    end
    
    if ns == nn || ns == 0 || nn == 0
        % trim leading NaN row(s) from numeric data
        firstrow = 1;
        while (firstrow<=mn && all(isnan(numericArray(firstrow,:))))
            firstrow = firstrow+1;
        end
        numericArray=numericArray(firstrow:end,:);
        
        % trim leading empty rows(s) from text data
        firstrow = 1;
        while (firstrow<=ms && all(cellfun('isempty',textArray(firstrow,:))))
            firstrow = firstrow+1;
        end
        textArray=textArray(firstrow:end,:);
    end
    
    % trim all-empty-string trailing rows from text array
    lastrow = size(textArray,1);
    while (lastrow>0 && all(cellfun('isempty',textArray(lastrow,:))))
        lastrow = lastrow-1;
    end
    textArray=textArray(1:lastrow,:);
    
    % trim all-empty-string trailing columns from text array
    lastcolm = size(textArray,2);
    while (lastcolm>0 && all(cellfun('isempty',textArray(:,lastcolm))))
        lastcolm = lastcolm-1;
    end
    textArray=textArray(:,1:lastcolm);
    
    % trim all-NaN trailing rows from numeric array
    lastrow = size(numericArray,1);
    while (lastrow>0 && all(isnan(numericArray(lastrow,:))))
        lastrow=lastrow-1;
    end
    numericArray=numericArray(1:lastrow,:);
    
    % trim all-NaN trailing columns from numeric array
    lastcolm = size(numericArray,2);
    while (lastcolm>0 && all(isnan(numericArray(:,lastcolm))))
        lastcolm=lastcolm-1;
    end
    numericArray=numericArray(:,1:lastcolm);
end


