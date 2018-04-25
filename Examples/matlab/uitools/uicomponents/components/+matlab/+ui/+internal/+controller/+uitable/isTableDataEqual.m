% util method called from c++ model to compare table data.
function isEqual = isTableDataEqual (oldTable, newTable)

    % Step 1: use isequaln to check table equality. 
    % NaN, NaT, missing and undefined values are treated as equal to other
    % such values.
    isEqual = isequaln(oldTable, newTable);

    % Step 2: check meta data for equal tables.
    % - Format property of datetime and duration array.
    if isEqual && istable(oldTable)
        for i = 1:length(oldTable.Properties.VariableNames)
            switch class(oldTable.(i))
                % compare Format property for datetime and duration.
                case {'datetime', 'duration', 'calendarDuration'}
                    isEqual = isequal(oldTable.(i).Format, newTable.(i).Format);                    
                    if ~isEqual
                        break; % Done if we found something different.
                    end
                    
                otherwise
                    % no op - tables are truely equal.
            end
        end
    end
end

