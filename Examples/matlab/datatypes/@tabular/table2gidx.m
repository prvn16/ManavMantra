function [group,glabels,glocs] = table2gidx(a,varIndices,reduce)
% TABLE2GIDX Create group indices from table grouping variables.

%   Copyright 2012-2017 The MathWorks, Inc.

% Default behavior is to leave out categories that are not actually present in
% the data of a categorical variable. Non-categorical variables _always_, in
% effect, do that.
try
    if nargin < 3, reduce = true; end

    a_data = a.data;
    a_varnames = a.varDim.labels;
    nrows = a.rowDim.length;
    ngroupVars = length(varIndices);
    
    if ngroupVars == 0 % if no grouping vars, create one group containing all observations
        group = ones(nrows,1);
        glocs = ones(min(nrows,1),1); % 1 if there are rows, 0x1 if not
        glabels = {'All'};

    elseif ngroupVars == 1
        % Create an index vector based on the unique values of the grouping variable
        if varIndices == 0 % the row labels
            [group,glabels,glocs] = grp2idx(a.rowDim.labels,a.metaDim.labels{1},reduce);
        else
            [group,glabels,glocs] = grp2idx(a_data{varIndices},a_varnames{varIndices},reduce);
        end
        
    else % ngroupVars > 1
        % Get integer group codes and names for each grouping variable
        groups = zeros(nrows,ngroupVars);
        names = cell(1,ngroupVars);
        for j = 1:ngroupVars
            index_j = varIndices(j);
            if index_j == 0
                var_j = a.rowDim.labels;
                name_j = a.metaDim.labels{1};
            else
                var_j = a_data{index_j};
                name_j = a_varnames{index_j};
            end
            [groups(:,j),names{j}] = grp2idx(var_j,name_j,reduce);
        end

        % Create an index vector based on the unique combinations of individual grouping variables
        wasnan = any(isnan(groups),2);
        group = NaN(size(wasnan));
        groups(wasnan,:) = [];
        [urows,glocs,gidx] = unique(groups,'rows','sorted');
        ngroups = size(urows,1);
        group(~wasnan) = gidx;

        % Translate the NaN-reduced row indices back to the original rows 
        tmp = find(~wasnan); glocs = tmp(glocs);

        gnames = cell(ngroups,ngroupVars);
        for j = 1:ngroupVars
            gnames(:,j) = names{j}(urows(:,j));
        end
        
        glabels = join(gnames,'_',2);
    end
catch ME
    throwAsCaller(ME)
end

%-------------------------------------------------------------------------------
function [gidx,gnames,gloc] = grp2idx(var,varName,reduce)
% GRP2IDX  Create index vector from a grouping variable.
%   [G,GN,GL] = GRP2IDX(S) creates an index vector G from the grouping variable
%   S. S can be a categorical, numeric, or logical vector; a cell vector of
%   character vectors; or a character matrix with each row representing a
%   group label. G is a vector of integer values from 1 up to the number K
%   of distinct groups. GN is a cell array of character vectors containing
%   group labels. GN(G) reproduces S (aside from any differences in type).
%   GL is a vector of indices into the first element of S for each group.
%
%   GRP2IDX treats NaNs (numeric or logical), empty character vectors (char
%   or cell array of character vectors), or <undefined> values
%   (categorical) in S as missing values and returns NaNs in the
%   corresponding rows of G. Neither GN nor GL include entries for missing
%   values.

if ischar(var)
    if isempty(var)
        var = cell(0,1);
    else
        var = cellstr(var);
    end
end

if ~iscolumn(var)
    error(message('MATLAB:table:GroupingVarNotColumn'));
end

if isa(var,'categorical')
    if reduce
        [glevels,gloc,gidx] = unique(var);
        if ~isempty(glevels) && isundefined(glevels(end)) % undefineds are sorted to end
            notNaN = ~isundefined(glevels);
            glevels = glevels(notNaN);
            gloc = gloc(notNaN);
            gidx(gidx > length(glevels)) = NaN; % other indices stay the same
        end
        gnames = cellstr(glevels);
    else
        gidx = double(var); % converts <undefined> to NaN
        gnames = categories(var)';
        [~,gloc] = ismember(1:length(gnames),gidx);
    end
else
    try
        [glevels,gloc,gidx] = unique(var,'sorted');
    catch ME
        m = message('MATLAB:table:VarUniqueMethodFailed',varName);
        throwAsCaller(addCause(MException(m.Identifier,'%s',getString(m)), ME));
    end
    if size(gidx,1) ~= size(var,1)
        m = message('MATLAB:table:VarUniqueMethodFailedNumRows',varName);
        throwAsCaller(MException(m.Identifier,'%s',getString(m)));
    end
        
    if isnumeric(var) || islogical(var) || isdatetime(var) || isduration(var) || isstring(var)
        % Handle missing values: return NaN group indices
        if ~isempty(glevels) && ismissing(glevels(end)) % missing values are sorted to end
            notMissing = ~ismissing(glevels);
            glevels = glevels(notMissing);
            gloc = gloc(notMissing);
            gidx(gidx > length(glevels)) = NaN; % other indices stay the same
        end
    elseif iscell(var) % iscellstr enforced by unique above
        % Handle empty char vector missing values: return NaN group indices
        if ~isempty(glevels) && isempty(glevels{1}) % empty '' are sorted to beginning
            % All empties are treated as '', but defensively find the number of empty strings
            notNaN = ~cellfun('isempty',glevels);
            nEmpty = length(glevels) - sum(notNaN);
            glevels = glevels(notNaN);
            gloc = gloc(notNaN);
            adjustIdx = [NaN(1,nEmpty) 1:length(glevels)]';
            gidx = adjustIdx(gidx);
        end
        gnames = glevels;

    else
        throwAsCaller(MException(message('MATLAB:table:GroupTypeIncorrect')));
    end
    if isnumeric(var) || islogical(var)
        gnames = numericLabels(glevels);
    elseif isdatetime(var) || isduration(var) || isstring(var)
        gnames = cellstr(glevels);
    elseif iscell(var)
        gnames = glevels;
    end
end


%-------------------------------------------------------------------------------
function gnames = numericLabels(glevels)
gl = full(glevels);
gnames = sprintfc('%d',gl); % a little less than 19 significant digits
ufmt = (fix(gl) == gl) & (gl > intmax('int64'));
gnames(ufmt) = sprintfc('%u',gl(ufmt)); % a little more than 19 significant digits
gfmt = (fix(gl) ~= gl)| (gl < intmin('int64')) | (gl > intmax('uint64'));
if any(gfmt)
    gnames(gfmt) = sprintfc('%g',gl(gfmt)); % six significant digits
    % If some values in the grouping variable differ by less than (about)
    % 1e-6 (relative), add more digits to make the names unique.
    if length(unique(gnames)) < length(gnames)
        tryFmt = {'%.16g' '%.17g' '0x%bx'};
        for i = 1:length(tryFmt)
            gnames(gfmt) = sprintfc(tryFmt{i},gl(gfmt));
            if length(unique(gnames)) == length(gnames), break; end
        end
    end
end
