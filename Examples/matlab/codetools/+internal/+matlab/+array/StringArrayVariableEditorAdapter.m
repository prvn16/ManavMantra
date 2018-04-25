% Copyright 2015-2017 The MathWorks, Inc.

classdef StringArrayVariableEditorAdapter
    
    % This class is for internal use only and will change in a future
    % release.  Do not use this class.
    
    methods (Static=true)
        
        function [out, warnmsg] = variableEditorClearDataCode(a, ...
                varName, rowIntervals, colIntervals)
            % Generates the MATLAB command to delete the content specified
            % by the rowIntervals and colIntervals of the string
            % variable.
            warnmsg = '';
            
            rowSubsref = localBuildSubsrefWithLen(rowIntervals(1,1), ...
                rowIntervals(1,2), size(a,1));
            for row=2:size(rowIntervals, 1)
                rowSubsref = sprintf('%s,%s', rowSubsref,...
                    localBuildSubsrefWithLen(rowIntervals(row,1), ...
                    rowIntervals(row,2), size(a,1)));
            end
            if size(rowIntervals,1)>1 % Multiple intervals need to be wrapped in []
                rowSubsref = sprintf('[%s]', rowSubsref);
            end
            
            colSubsref = localBuildSubsrefWithLen(colIntervals(1,1), ...
                colIntervals(1,2), size(a,2));
            for col=2:size(colIntervals,1)
                colSubsref = sprintf('%s,%s', colSubsref, ...
                    localBuildSubsrefWithLen(colIntervals(col,1), ...
                    colIntervals(col,2), size(a,2)));
            end
            if size(colIntervals,1)>1
                colSubsref = sprintf('[%s]', colSubsref);
            end
            
            % Generate code to clear the range, by setting the value to an
            % empty string 
            out = sprintf('%s(%s,%s) = missing;', varName, ...
                rowSubsref, colSubsref);
        end
        
        function [out, warnmsg] = variableEditorColumnDeleteCode(a, ...
                varName, colIntervals)
            % Generate MATLAB command to delete columns positions defined
            % by the 2-column colIntervals matrix. It is assumed that
            % column intervals are disjoint,  in monotonic order,  and
            % bounded by the number of columns in the string variable
            % array.
            warnmsg = '';
            if size(colIntervals,1)==1
                s = size(a);
                if s(1,1) == 1
                    out = sprintf('%s(%s) = [];', varName, ...
                        localBuildSubsref(colIntervals(1), colIntervals(2)));
                else
                    out = sprintf('%s(:,%s) = [];', varName, ...
                        localBuildSubsref(colIntervals(1), colIntervals(2)));
                end
            else
                columnSubsref = localBuildSubsref(colIntervals(1,1), ...
                    colIntervals(1,2));
                for row=2:size(colIntervals,1)
                    columnSubsref = sprintf('%s,%s', columnSubsref, ...
                        localBuildSubsref(colIntervals(row,1), ...
                        colIntervals(row,2)));
                end
                % e.g. x(:, [1:2 5]) = [];
                out = sprintf('%s(:,[%s]) = [];', varName, columnSubsref);
            end
        end
        
        function out = variableEditorInsert(a, orientation, row, col, data)
            % Performs an insert operation on data from the clipboard.
            % Data is expected to be a string, and must be the same size
            % as the row or columns (depending on the orientation argument)
            % of this string.
            
            % Get the inserted data as a string
            if isa(data, 'string')
                varData = data;
            else
                varData = string(data);
            end
            
            if strcmp('columns', orientation)
                if col <= size(a, 2)
                    %this = [this(:,1:col-1) varData this(:,col:end)];
                    a =  horzcat(subsref(a, struct('type', {'()'}, ...
                        'subs', {{':', 1:col-1}})),...
                        varData, subsref(a, struct('type', {'()'}, ...
                        'subs', {{':', col:size(a, 2)}})));
                else
                    %this = [this(:, 1:size(this, 2)) varData];
                    a =  horzcat(subsref(a, struct('type', {'()'}, ...
                        'subs', {{':', 1:size(a, 2)}})), varData);
                end
            else
                if row<=size(a, 1)
                    %this = [this(1:row-1, :); varData; this(row:end, :)];
                    a =  vertcat(subsref(a, struct('type', {'()'}, ...
                        'subs', {{1:row-1, ':'}})), ...
                        varData, subsref(a, struct('type', {'()'}, ...
                        'subs', {{row:size(a, 1), ':'}})));
                else
                    %this = [this(1:row, :); varData];
                    a =  vertcat(subsref(a, struct('type', {'()'}, ...
                        'subs', {{1:size(a, 1), ':'}})), varData);
                end
            end
            
            out = a;
        end
        
        function a = variableEditorPaste(a, rows, columns, data)
            % Performs a paste operation on data from the clipboard which
            % was not obtained from another string array.
            
            if isa(data, 'table')
                % try converting the table to an array.  If it is an array
                % of strings, the paste will succeed.  Otherwise, if it
                % can't be converted to an array or it isn't an array of
                % strings, it will fail below and the user will receive an
                % appropriate error message.
                try
                    data = table2array(data);
                catch
                end
            else
                % does the pasted data start and end with double-quotes?
                % If so, assume they aren't part of the string the user is
                % attempting to paste, and remove them.
                if isa(data, 'string') && isscalar(data)
                    if startsWith(data, '"') && endsWith(data, '"')
                        data = extractBetween(data, 2, strlength(data)-1);
                    end
                elseif ischar(data)
                    if data(1) == '"' && data(end) == '"'
                        data = data(2:end-1);
                    end
                elseif iscellstr(data) && isscalar(data)
                    if data{1,1}(1) == '"' && data{1,1}(end) == '"'
                        data{1,1} = data{1,1}(2:end-1);
                    end
                end
            end
            
            if ischar(data)
                ncols = 1;
                nrows = 1;
            else
                ncols = size(data, 2);
                nrows = size(data, 1);
            end
            
            % If the number of pasted columns does not match the number of
            % selected columns, just paste columns starting at the
            % left-most column
            if length(columns) ~= ncols
                columns = columns(1):columns(end) + ncols - 1;
            end
            
            % If the number of pasted rows does not match the number of
            % selected rows, just paste rows starting at the top-most row
            if length(rows) ~= nrows
                rows = rows(1):rows(end) + nrows - 1;
            end
            
            % Paste data onto existing string variables
            s = struct('type', {'()'}, 'subs', {{rows,columns}});
            if isa(data, 'string')
                a = subsasgn(a, s, data);
            elseif iscell(data)
                a = subsasgn(a, s, data);
            else
                a = subsasgn(a, s, cellstr(data));
            end
        end
        
        function [out, warnmsg] = variableEditorRowDeleteCode(a, ...
                varName, rowIntervals)
            % Generate MATLAB command to delete rows in positions defined
            % by the 2-column rowIntervals matrix. It is assumed that row
            % intervals are disjoint, in monotonic order, and bounded by
            % the number of rows in the string array.
            warnmsg = '';
            
            if size(rowIntervals,1)==1
                s = size(a);
                if s(1,2) == 1
                    out = sprintf('%s(%s) = [];', varName, localBuildSubsref(...
                        rowIntervals(1), rowIntervals(2)));
                else
                    out = sprintf('%s(%s,:) = [];', varName, localBuildSubsref(...
                        rowIntervals(1), rowIntervals(2)));
                end
            else
                rowSubsref = localBuildSubsref(rowIntervals(1,1), ...
                    rowIntervals(1,2));
                for row=2:size(rowIntervals, 1)
                    rowSubsref = sprintf('%s,%s', rowSubsref, localBuildSubsref(...
                        rowIntervals(row,1), rowIntervals(row, 2)));
                end
                % e.g. x([1:2 5],:) = [];
                out = sprintf('%s([%s],:) = [];', varName, rowSubsref);
            end
        end
        
        function [str,msg] = variableEditorSetDataCode(a, ...
                varname, row, col, rhs)
            % Generate MATLAB command to edit the content of a cell to the
            % specified rhs for the string array.  rhs is expected to be
            % the quoted text of a string variable.
            msg = '';

            % Double all the double quotes.  This way we should have
            % valid MATLAB syntax
            rhs = strrep(rhs, """", """""");
            
            if (size(a, 1) == 1 && row == 1)
                rowCol = num2str(max(row, col));
            else
                rowCol = [num2str(row) ',' num2str(col)];
            end           

            % Special handling for any newline characters in the assignment
            if contains(rhs, newline)
                str = [varname '(' rowCol ') = "' char(strrep(rhs, newline, '" + newline + "')) '";'];
            else
                str = [varname '(' rowCol ') = "' char(rhs) '";'];
            end
        end
        
        function [out,warnmsg] = variableEditorSortCode(~, varName, ...
                columnIndexStrings, direction)
            % Generate MATLAB command to sort string rows. The direction
            % input is true for ascending sorts, false otherwise.
            warnmsg = '';
            if iscell(columnIndexStrings)
                columnIndexExpression = ['[' strjoin(columnIndexStrings,' ') ']'];
            else
                columnIndexExpression = columnIndexStrings;
            end
            
            % Generate code for sorting
            if direction
                out = [varName ' = sortrows(' varName ',' ...
                    columnIndexExpression ');'];
            else
                out = [varName ' = sortrows(' varName ',-' ...
                    columnIndexExpression ');'];
            end
        end
    end
end

function subsrefexp = localBuildSubsrefWithLen(startIndex, endIndex, len)
    
    % Create a sub-index expression for the interval startCol:endCol
    if startIndex == 1 && endIndex == len
        subsrefexp = ':';
    elseif startIndex == endIndex
        subsrefexp = sprintf('%d', startIndex);
    else
        subsrefexp = sprintf('%d:%d', startIndex, endIndex);
    end
end

function subsrefexp = localBuildSubsref(startCol, endCol)
    
    % Create a sub-index expression for the interval startCol:endCol
    if startCol == endCol
        subsrefexp = sprintf('%d', startCol);
    else
        subsrefexp = sprintf('%d:%d', startCol, endCol);
    end
end



