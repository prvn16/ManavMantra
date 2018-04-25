function IA = ismissingKernel(A,indicators,stdize,dataVars)
% ismissingKernel Helper function for ismissing and standardizeMissing
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%
% IA is either a logical array (the output of ismissing) or an array/table
% containing standardized entries.

%   Copyright 2016 The MathWorks, Inc.

AisTable = matlab.internal.datatypes.istabular(A);
if nargin <= 1
    % ismissing(A)
    if ~AisTable
        IA = arraySwitch(A,false);
    else
        IA = false(size(A));
        for jj = 1:width(A)
            IA(:,jj) = arraySwitch(A.(jj),true);
        end
    end
else
    if ~AisTable
        % ismissing(A,indicators)
        % standardizeMissing(A,indicators)
        indstruct = parseIndicators(indicators,false,stdize);
        IA = arraySwitchIndicators(A,false,indstruct,stdize);
    else
        if nargin < 4
            dataVars = 1:width(A);
        end
        indstruct = parseIndicators(indicators,true,stdize);
        if ~stdize
            % ismissing(A,indicators)
            IA = false(size(A));
            for jj = dataVars
                IA(:,jj) = arraySwitchIndicators(A.(jj),true,indstruct,stdize);
            end
        else
            % standardizeMissing(A,indicators)
            % standardizeMissing(A,indicators,'DataVariables',dataVars)
            IA = A;
            for jj = dataVars
                IA.(jj) = arraySwitchIndicators(A.(jj),true,indstruct,stdize);
            end
        end
    end
end
%--------------------------------------------------------------------------
function IA = arraySwitch(A,AinTable)
% Used for 1-input ismissing for arrays or table variables
if isfloat(A)
    IA = isnan(A);
elseif ischar(A)
    if ~AinTable
        IA = A == ' '; % blank char
    else
        % Convert to string via helper for correct N-D char array behavior.
        A = matlab.internal.math.charRows2string(A);
        IA = ismissing(A);
    end
elseif iscellstr(A)
    IA = cellfun('isempty',A);
elseif isstring(A)
    IA = ismissing(A);
elseif iscategorical(A)
    IA = isundefined(A);
elseif isdatetime(A)
    IA = isnat(A);
elseif (isduration(A) || iscalendarduration(A))
    IA = isnan(A);
elseif (isinteger(A) || islogical(A))
    IA = false(size(A));
else
    if AinTable
        IA = false(size(A)); % Ignore table variables of unsupported types
    else
        error(message('MATLAB:ismissing:FirstInputInvalid'));
    end
end
if AinTable
    IA = collapseIntoLogicalColumn(IA);
end
end
%--------------------------------------------------------------------------
function IA = arraySwitchIndicators(A,AinTable,ind,stdize)
% Indicators-based ismissing and standardizeMissing for arrays or tables
if isa(A,'double')
    IA = ismissingApply(A,AinTable,ind,stdize,NaN,@ismissingNumeric,'Double');
elseif isa(A,'single')
    IA = ismissingApply(A,AinTable,ind,stdize,NaN,@ismissingNumeric,'Single');
elseif ischar(A)
    if ~AinTable
        IA = ismissingApply(A,AinTable,ind,stdize,' ',@ismissingChar,'Char');
    else
        % Convert to string via helper for correct N-D char array behavior.
        As = matlab.internal.math.charRows2string(A);
        % Remove trailing whitespace. We want the ' ' indicator to match
        % blank rows of any width, and a normal character row to match with
        % the indicators regardless of how much trailing whitespace it has.
        Ad = strip(As,'right');
        IA = ismissingApply(Ad,AinTable,ind,false,[],@ismissingString,'CharInTable');
        if stdize
            As(IA) = string(NaN);
            % Convert back to char via helper for correct N-D char array behavior.
            IA = matlab.internal.math.string2charRows(As);
        end
    end
elseif iscellstr(A)
    IA = ismissingApply(A,AinTable,ind,stdize,{''},@ismissingCellstr,'Cellstr');
elseif isstring(A)
    IA = ismissingApply(A,AinTable,ind,stdize,string(NaN),@ismissingString,'String');
elseif iscategorical(A)
    IA = ismissingApply(A,AinTable,ind,stdize,'',@ismissingCategorical,'Categorical');
    if stdize && isfield(ind,'Categorical')
        indTmp = ind.('Categorical');
        indTmp = indTmp(~cellfun('isempty',indTmp) & ~strcmp(categorical.undefLabel,indTmp));
        IA = removecats(IA,indTmp); % errors if second input is '' or '<undefined>'
    end
elseif isdatetime(A)
    IA = ismissingApply(A,AinTable,ind,stdize,NaT,@ismissingDatetime,'Datetime');
elseif isduration(A)
    IA = ismissingApply(A,AinTable,ind,stdize,NaN,@ismissingDuration,'Duration');
elseif (isinteger(A) || islogical(A))
    % Integer arrays match to double indicators or to integer indicators of
    % exactly the same type of integer -- same behavior as ISMEMBER.
    indTmp = {};
    if isfield(ind,'IntegerLogical')
        indTmp = ind.('IntegerLogical');
        indTmp = indTmp(cellfun(@(x) isa(x,'double') || isa(x,class(A)),indTmp));
    end
    if ~stdize
        IA = ismissingNumeric(A,indTmp);
    else
        IA = A; % Flow-through. Cannot standardize integer/logical ararys.
    end
    if ~AinTable && isempty(indTmp)
        error(message('MATLAB:ismissing:IndicatorsIntegerLogical',class(A)));
    end
else
    if AinTable
        % Ignore table variables of unsupported types
        if ~stdize
            IA = false(size(A));
        else
            IA = A; % Flow-through.
        end
    else
        if iscalendarduration(A)
            if ~stdize
                error(message('MATLAB:ismissing:IndicatorsCalendarDuration'));
            else
                error(message('MATLAB:ismissing:StdizeCalendarDuration'));
            end
        else
            error(message('MATLAB:ismissing:FirstInputInvalid'));
        end
    end
end
if AinTable && ~stdize
    IA = collapseIntoLogicalColumn(IA);
end
end
%--------------------------------------------------------------------------
function IA = ismissingApply(A,AinTable,ind,stdize,missingValue,ismissingFun,typeid)
% Apply ismissing with indicators for arrays or table variables
if isfield(ind,typeid) || ind.hasMissingObj
    % If A is an array, a cell of indicators is not supported
    if ~AinTable && ind.IndIsCell && ...
            (~ind.IndIsCellStr || (~iscategorical(A) && ~iscellstr(A)))
        % But categorical and cellstr inputs do support cellstr indicators 
        error(message(['MATLAB:ismissing:Indicators',typeid]));
    end
    % Indicators of compatible type with A were provided
    if ~stdize
        % IA = ismissing(A,indicators)
        if isfield(ind,typeid)
            IA = ismissingFun(A,ind.(typeid));
        else
            IA = false(size(A));
        end
        if ind.hasMissingObj == 1 % empty missing obj (== 2) has no effect
            IA = IA | ismissing(A);
        end
    else
        % IA = standardizeMissing(A,indicators)
        IA = A; % missing object indicators have no effect
        if isfield(ind,typeid)
            IA(ismissingFun(A,ind.(typeid))) = missingValue;
        end
    end    
else
    if ~AinTable
        error(message(['MATLAB:ismissing:Indicators',typeid]));
    end
    % Flow-through for table if compatible indicators were not provided
    if ~stdize
        IA = false(size(A));
    else
        IA = A;
    end
end
end
%--------------------------------------------------------------------------
function indstruct = parseIndicators(ind,AisTable,stdize)
% Parse indicators. They can be an array or a cell at this point.
indstruct = struct;
indstruct.hasMissingObj = false;
if ~iscell(ind)
    indstruct.IndIsCell = false;
    indstruct.IndIsCellStr = false;
    indstruct = indicatorsSwitch(indstruct,ind,AisTable,stdize);
else
    indstruct.IndIsCell = true;
    indstruct.IndIsCellStr = iscellstr(ind);
    if isempty(ind)
        % {} is still a cellstr, we don't want to error for it
        indstruct = addToField(indstruct,ind,'Cellstr');
        indstruct = addToField(indstruct,ind,'Char');
        indstruct = addToField(indstruct,ind,'Categorical');
    end
    for ii = 1:numel(ind)
        indstruct = indicatorsSwitch(indstruct,ind{ii},AisTable,stdize);
    end
end
end
%--------------------------------------------------------------------------
function indstruct = indicatorsSwitch(indstruct,ind,AisTable,stdize)
% Separate indicators according to the array type they are compatible with
if (isnumeric(ind) || islogical(ind))
    ind = reshape(ind,[],1);
    if isa(ind,'double')
        % Double indicators supported for all numeric and logical arrays
        indstruct = addToField(indstruct,{ind},'Double');
        indstruct = addToField(indstruct,{ind},'Single');
        indstruct = addToField(indstruct,{ind},'IntegerLogical');
    elseif isa(ind,'single')
        % Single indicators supported only for double and single arrays
        indstruct = addToField(indstruct,{ind},'Double');
        indstruct = addToField(indstruct,{ind},'Single');
    else
        % Integer indicators supported only for double and integer arrays
        indstruct = addToField(indstruct,{ind},'Double');
        indstruct = addToField(indstruct,{ind},'IntegerLogical');
    end
elseif ischar(ind)
    if ~isrow(ind) && ~isempty(ind)
        error(message('MATLAB:ismissing:IndicatorsCharRowVector'));
    end
    if ~AisTable
        indstruct = addToField(indstruct,ind(:),'Char');
    else
        % Remove trailing whitespace in indicators used for char in table
        indStr = strip(matlab.internal.math.charRows2string(ind),'right');
        indstruct = addToField(indstruct,indStr,'CharInTable');
    end
    % Keep whitespace in indicators used for cellstr
    ind = {ind};
    indstruct = addToField(indstruct,ind,'Cellstr');
    % Remove leading/trailing whitespace in indicators used for categorical
    indstruct = addToField(indstruct,strtrim(ind),'Categorical');
elseif isstring(ind)
    ind = reshape(ind,[],1);
    % Keep whitespace in indicators used for string
    indstruct = addToField(indstruct,ind,'String');
    % Remove <missing> string from indicators. We do not want the <missing>
    % string to match up to <undefined> in a categorical.
    ind(ismissing(ind)) = [];
    % Remove leading/trailing whitespace in indicators for categorical, but
    % don't match indicators "" and " " to <undefined>. Also, "<undefined>"
    % does not match to <undefined>; only blank character vectors of any
    % length, and '', and '<undefined>' match to <undefined>.
    ind = deblank(ind);
    ind = strip(ind);
    ind(ind == "") = [];
    ind(ind == string(categorical.undefLabel)) = []; % '<undefined>'
    ind = reshape(ind,[],1);
    indstruct = addToField(indstruct,cellstr(ind),'Categorical');
elseif isdatetime(ind)
    ind = reshape(ind,[],1);
    indstruct = addToField(indstruct,ind,'Datetime');
elseif isduration(ind)
    ind = reshape(ind,[],1);
    indstruct = addToField(indstruct,ind,'Duration');
elseif iscalendarduration(ind)
    if ~stdize
        error(message('MATLAB:ismissing:IndicatorsCalendarDuration'));
    else
        error(message('MATLAB:ismissing:StdizeCalendarDuration'));
    end
elseif isa(ind,'missing')
    % 1 for non-empty missing, 2 for empty missing
    indstruct.hasMissingObj = 1 + isempty(ind);
else
    % categorical indicators are not supported
    % cellstr indicators within another cell are also not supported
    error(message('MATLAB:ismissing:IndicatorsInvalidType',class(ind)));
end
end
%--------------------------------------------------------------------------
function indstruct = addToField(indstruct,ind,typeid)
% Grow the array of indicators of a certain type
if isfield(indstruct,typeid)
    indstruct.(typeid) = [indstruct.(typeid); ind];
else
    indstruct.(typeid) = ind;
end
end
%--------------------------------------------------------------------------
function IA = collapseIntoLogicalColumn(IA)
% Collapse 2-D and N-D table variables into one logical column
if ~iscolumn(IA)
    if ~ismatrix(IA)
        IA = reshape(IA,size(IA,1),[]);
    end
    IA = any(IA,2);
end
end
%--------------------------------------------------------------------------
function IA = ismissingNumeric(A,ind)
% A is numeric or logical, ind is numeric or logical
IA = false(size(A));
for ii = 1:numel(ind)
    indii = ind{ii};
    if issparse(indii)
        indii = full(indii);
    end
    mi = isnan(indii);
    if any(mi)
        IA = IA | ismember(A,indii(~mi)) | isnan(A);
    else
        IA = IA | ismember(A,indii);
    end
end
end
%--------------------------------------------------------------------------
function IA = ismissingDatetime(A,ind)
% A and ind are datetime
mi = isnat(ind);
if any(mi)
    IA = ismember(A,ind(~mi)) | isnat(A);
else
    IA = ismember(A,ind);
end
end
%--------------------------------------------------------------------------
function IA = ismissingDuration(A,ind)
% A and ind are duration
mi = isnan(ind);
if any(mi)
    IA = ismember(A,ind(~mi)) | isnan(A);
else
    IA = ismember(A,ind);
end
end
%--------------------------------------------------------------------------
function IA = ismissingCategorical(A,ind)
% A is categorical, ind is cellstr
hasUndefInd = any(cellfun('isempty',ind)) | ...
    any(strcmp(categorical.undefLabel,ind));
if hasUndefInd
    IA = ismember(A,ind) | isundefined(A);
else
    IA = ismember(A,ind);
end
end
%--------------------------------------------------------------------------
function IA = ismissingChar(A,ind)
% A and ind are char arrays
IA = ismember(A,ind);
end
%--------------------------------------------------------------------------
function IA = ismissingCellstr(A,ind)
% A is cellstr, ind is char row vector or cellstr
IA = ismember(A,ind);
end
%--------------------------------------------------------------------------
function IA = ismissingString(A,ind)
% A and ind are string
mi = ismissing(ind);
if any(mi)
    IA = ismember(A,ind(~mi)) | ismissing(A);
else
    IA = ismember(A,ind);
end
end
end % ismissingKernel