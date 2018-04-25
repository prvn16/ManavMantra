function [str,msg] = variableEditorSetDataCode(a, varname, row, col, rhs)
% This function is for internal use only and will change in a
% future release.  Do not use this function.

% Generate MATLAB command to edit the content of a cell to the specified
% rhs for the datetime array.  rhs is expected to be the quoted text of a
% datetime variable.

% Copyright 2014-2015 The MathWorks, Inc.

msg = '';
rhs = strtrim(rhs);
if (size(a, 1) == 1 && row == 1)
    rowCol = num2str(max(row, col));
else
    rowCol = [num2str(row) ',' num2str(col)];
end

if ismember(lower(rhs),{'''now''' '''yesterday''' '''today''' '''tomorrow'''})
    % Allow keyword entry like the datetime constructor does
    str = [varname '(' rowCol ') = datetime(' rhs ');'];
else
    try
        % Verify this is a valid datetime, with the format of the current
        % datetime array.  If it is, assign using the string - the datetime
        % constructor will use the current format by default.
        eval(['datetime(' rhs ', ''Format'', ''' strrep(getDisplayFormat(a), '''', '''''') ''');']);
        str = [varname '(' rowCol ') = ' rhs ';'];
    catch
        errmsg = message('MATLAB:datetime:InvalidFromVE');
        com.mathworks.mlwidgets.array.ArrayDialog.showErrorDialog(errmsg.getString);
        str = '';
    end
end
end
