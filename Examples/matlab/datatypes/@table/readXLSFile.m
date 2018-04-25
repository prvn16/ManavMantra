function t = readXLSFile(xlsfile,args)
%READXLSFILE Read in an XLS file and create a table.

%   Copyright 2012-2016 The MathWorks, Inc.

import matlab.internal.datatypes.validateLogical

pnames = {'ReadVariableNames' 'ReadRowNames' 'TreatAsEmpty' 'Sheet' 'Range' 'Basic' 'TextType' 'DatetimeType'};
dflts =  {               true          false             {}      ''      ''   false 'char'     'datetime'};
[readVarNames,readRowNames,treatAsEmpty,sheet,range,basic,textType,datetimeType] ...
                   = matlab.internal.datatypes.parseArgs(pnames, dflts, args{:});
readRowNames = validateLogical(readRowNames,'ReadRowNames');
readVarNames = validateLogical(readVarNames,'ReadVariableNames');
basic = validateLogical(basic,'Basic');

if isempty(treatAsEmpty)
    treatAsEmpty = cell(0,1);
elseif ischar(treatAsEmpty) && ~isrow(treatAsEmpty)
    % textscan does something a little obscure when treatAsEmpty is char but
    % not a row vector, disallow that here.
    error(message('MATLAB:readtable:InvalidTreatAsEmpty'));
elseif ischar(treatAsEmpty) || iscellstr(treatAsEmpty)
    if ischar(treatAsEmpty), treatAsEmpty = cellstr(treatAsEmpty); end
    % Trim insignificant whitespace to be consistent with what's done for text files.
    treatAsEmpty = strtrim(treatAsEmpty);
    if any(~isnan(str2double(treatAsEmpty))) || any(strcmpi('nan',treatAsEmpty))
        error(message('MATLAB:readtable:NumericTreatAsEmpty'));
    end
else
    error(message('MATLAB:readtable:InvalidTreatAsEmpty'));
end

if (~ischar(sheet) || (~strcmp(sheet, '') && ~isrow(sheet))) && ...
   (~isnumeric(sheet) || ~isscalar(sheet) || (floor(sheet) ~= sheet) || (sheet < 1))
    error(message('MATLAB:readtable:InvalidSheet'));
end

if ~strcmp(range, '') && (~ischar(range) || ~isrow(range))
    error(message('MATLAB:readtable:InvalidRange'));
end

rdOpts.file = xlsfile;
rdOpts.format = matlab.io.spreadsheet.internal.getExtension(xlsfile);
rdOpts.sheet = sheet;
rdOpts.range = range;
rdOpts.readVarNames = readVarNames;
rdOpts.basic = basic;
rdOpts.treatAsEmpty = treatAsEmpty;
rdOpts.logicalType = 'logical';
rdOpts.textType = validatestring(textType, {'char', 'string'});
rdOpts.datetimeType = validatestring(datetimeType, {'text' 'datetime' 'exceldatenum'});

import matlab.io.spreadsheet.internal.readSpreadsheetFile;
out = readSpreadsheetFile(rdOpts);

data = out.variables;

if isempty(data)
    t = table;
    return;
end

if readVarNames
    varNames = out.varNames;
    if ~iscellstr(varNames) || ~isstring(varNames)
        varNames = stringizeLocal(varNames, basic);
    end
else
    % If reading row names, number remaining columns beginning from 1, we'll drop Var0 below.
    varNames = matlab.internal.tabular.private.varNamesDim.dfltLabels((1:numel(data))-readRowNames);
end

if readRowNames
    rowNames = data{1};
    if isstring(rowNames)
        rowNames = convertStringsToChars(rowNames);
    end
    data(1) = [];
    if ~iscellstr(rowNames) || ~isstring(rowNames)
        rowNames = stringizeLocal(rowNames, basic);
    end
    dimNames = matlab.internal.tabular.private.metaDim.dfltLabels;
    if readVarNames, dimNames{1} = varNames{1}; end
    varNames(1) = [];
end

t = table(data{:});

% Set the var names.  These will be modified to make them valid, and the
% original strings saved in the VariableDescriptions property.  Fix up
% duplicate or empty names.
t.varDim = t.varDim.setLabels(varNames,[],true,true,true);

if readRowNames
    t.rowDim = t.rowDim.setLabels(rowNames,[],true,true); % Fix up duplicate or empty names
    t.metaDim = t.metaDim.setLabels(dimNames,[],true,true,true); % Fix up duplicate, empty, or invalid names
end 
if readVarNames
    % Make sure var names and dim names don't conflict. That could happen if var
    % names read from the file are the same as the default dim names (when ReadRowNames
    % is false), or same as the first dim name read from the file (ReadRowNames true).
    t.metaDim = t.metaDim.checkAgainstVarLabels(t.varDim.labels,'silent');
end

end

% ----------------------------------------------------------------------- %
function s = stringizeLocal(c, basic)
    s = matlab.io.spreadsheet.internal.stringize(c, ~basic);
end
