function t = vertcat(varargin)
%VERTCAT Vertical concatenation for tables.
%   T = VERTCAT(T1, T2, ...) vertically concatenates the tables T1, T2, ... .
%   Row names, when present, must be unique across tables.  VERTCAT fills
%   in default row names for the output when some of the inputs have names
%   and some do not.
%
%   Variable names for all tables must be identical except for order.  VERTCAT
%   concatenates by matching variable names.  VERTCAT assigns values for each
%   property (except for RowNames) in T using the first non-empty value for
%   the corresponding property in the arrays T1, T2, ... .
%
%   See also CAT, HORZCAT.

%   Copyright 2012-2017 The MathWorks, Inc.

try
    nrows = zeros(1,nargin);
    for i = 1:nargin
        nrows(i) = size(varargin{i},1); % dispatch to overloaded size, not built-in
    end
    nrowsTotal = sum(nrows);
    t_nrows = 0;
    t_nvars = 0; % don't know yet
    needATable = true;

    for j = 1:nargin
        b = varargin{j};
        wasCell = iscell(b);
        if matlab.internal.datatypes.istabular(b)
            % OK, avoid other checks
        elseif isnumeric(b) && isequal(b,[]) % treat as "identity element", and ignore
            continue;
        elseif wasCell
            b = cell2table(b); % default var names won't be used
        else
            error(message('MATLAB:table:vertcat:InvalidInput'));
        end
        b_nvars = b.varDim.length;
        b_nrows = b.rowDim.length;
        
        rows_j = sum(nrows(1:j-1)) + (1:nrows(j));
        if t_nvars==0 && t_nrows==0 % first input, or all previous inputs were 0x0
            t = b; % preserve the subclass
            haveTime = isa(t,'timetable');
            t_nvars = b_nvars;
            t_nrows = b_nrows;
            t_metaDim = b.metaDim;
            t_varDim = b.varDim;
            t_rowDim = b.rowDim.createLike(nrowsTotal); % empty labels
            t_arrayProps = b.arrayProps;
            needATable = wasCell; % use var/dim labels from a table, keep looking if a cell array
            
            [t_varLabelsSorted,t_varOrder] = sort(t_varDim.labels);
            
            b_data = cell(nargin,t_nvars);
            b_data(j,:) = b.data;
        elseif ~haveTime && isa(b,'timetable')
            % Tables and cell arrays can be concatenated onto a timetable, but not vice-versa
            if isa(varargin{1},'table')
                error(message('MATLAB:table:vertcat:TableAndTimetable'));    
            else
                % Must be cell array if not table
            	error(message('MATLAB:table:vertcat:CellArrayAndTimetable'));          
            end
        elseif b_nvars==0 && b_nrows==0 % special case to mimic built-in behavior
            % do nothing
            continue;
        elseif b_nvars ~= t_nvars
            error(message('MATLAB:table:vertcat:SizeMismatch'));
        else
            if wasCell
                % Assign positionally
                b_data(j,:) = b.data;
            else % was always a table
                if needATable
                    t_metaDim = b.metaDim;
                    t_varDim = b.varDim;
                    
                    [t_varLabelsSorted,t_varOrder] = sort(b.varDim.labels);
                    needATable = false;
                    b_data(j,:) = b.data;
                else
                    %[tf,b_reord] = ismember(t.varDim.labels,b.varDim.labels);
                    [b_varLabelsSorted,b_varOrder] = sort(b.varDim.labels);
                    if ~isequal(t_varLabelsSorted,b_varLabelsSorted)
                        error(message('MATLAB:table:vertcat:UnequalVarNames'));
                    end
                    b_reord(t_varOrder) = b_varOrder; %#ok<AGROW>, full reassignment each time
                    b_data(j,:) = b.data(b_reord);
                    t_varDim = t_varDim.mergeProps(b.varDim,b_reord);
                end
            end

            t_nrows = t_nrows + b_nrows;
        end
        
        % If it was originally a cell array, there are no row labels or other
        % properties to worry about.
        if ~wasCell
            % If it was originally a table/timetable, get its row labels
            % if any, unless it's a table being added to a timetable.
            if ~haveTime || ~isa(b,'table')
                try
                    t_rowDim = t_rowDim.assignInto(b.rowDim,rows_j);
                catch ME
                    if ~isequal(class(b.rowDim.labels),class(t_rowDim.labels))
                        t.throwSubclassSpecificError('RowLabelsTypeMismatch',class(b.rowDim.labels),class(t_rowDim.labels));
                    else
                        rethrow(ME);
                    end
                end
            end
            
            % Use any per-array property values not already present.
            t_arrayProps = tabular.mergeArrayProps(t_arrayProps,b.arrayProps);
        end
    end

    t_data = cell(1,t_nvars);
    for i = 1:t_nvars
        try
            t_data{i} = vertcat(b_data{:,i}); % []'s are dropped
        catch ME
            m = message('MATLAB:table:vertcat:VertcatMethodFailed',t.varDim.labels{i});
            throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
        end
        % Something went badly wrong with whatever vertcat method was called.
        if size(t_data{i},1) ~= t_nrows
            % One reason for this is concatenation of a cell variable with a non-cell
            % variable, which adds only a single cell to the former, containing the
            % latter.  Check for cell/non-cell only after calling vertcat to allow
            % overloads such as categorical that can vertcat cell/non-cell sensibly.
            b_is0x0 = cellfun(@(c)isequal(size(c),[0 0]),varargin); % only check non-0x0 inputs
            cells = cellfun('isclass',b_data(~b_is0x0,i),'cell');
            if any(cells) && ~all(cells)
                error(message('MATLAB:table:vertcat:VertcatCellAndNonCell', t.varDim.labels{i}));
            else
                error(message('MATLAB:table:vertcat:VertcatWrongLength', t.varDim.labels{i}));
            end
        end
    end
    t.data = t_data;
    
    t.metaDim = t_metaDim;
    t.varDim = t_varDim;
    if t_rowDim.hasLabels
        % Error if row labels are duplicates, and create default labels where labels are not present.
        t_rowDim = t_rowDim.setLabels(t_rowDim.labels,[],false,true);
    end
    t.rowDim = t_rowDim;
    t.arrayProps = t_arrayProps;
catch ME
    throwAsCaller(ME)
end
