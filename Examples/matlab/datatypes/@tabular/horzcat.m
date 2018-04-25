function t = horzcat(varargin)
%HORZCAT Horizontal concatenation for tables.
%   T = HORZCAT(T1, T2, ...) horizontally concatenates the tables T1, T2,
%   ... .  All inputs must have unique variable names.
%
%   Row names for all tables that have them must be identical except for order.
%   HORZCAT concatenates by matching row names when present, or by position for
%   tables that do not have row names.  HORZCAT assigns values for the
%   Description and UserData properties in T using the first non-empty value
%   for the corresponding property in the arrays T1, T2, ... .
%
%   See also CAT, VERTCAT, JOIN.

%   Copyright 2012-2017 The MathWorks, Inc.

import matlab.internal.datatypes.istabular

try
    nvarsTotal = 0;
    for i = 1:nargin
        nvarsTotal = nvarsTotal + size(varargin{i},2); % dispatch to overloaded size, not built-in
    end

    t_nrows = 0; % don't know yet
    t_nvars = 0;
    needATable = true;
    
    for j = 1:nargin
        b = varargin{j};
        vars_j = t_nvars+(1:size(b,2));
        wasCell = iscell(b);
        if istabular(b)
            % OK, avoid other checks
        elseif isnumeric(b) && isequal(b,[]) % treat as "identity element", and ignore
            continue
        elseif wasCell
            b = cell2table(b);
        else
            error(message('MATLAB:table:horzcat:InvalidInput'));
        end
        % metaDim copied from b
        b_nrows = b.rowDim.length;
        b_nvars = b.varDim.length;

        if t_nvars==0 && t_nrows==0 % all previous inputs were 0x0
            t = b; % preserve the subclass
            haveTime = isa(t,'timetable');
            t_data = b.data;
            t_nvars = b_nvars;
            t_nrows = b_nrows;
            t_metaDim = b.metaDim;
            t_varDim = b.varDim.createLike(nvarsTotal); % empty labels
            t_rowDim = t.rowDim;
            t_arrayProps = t.arrayProps;
            needATable = wasCell; % use dim labels from a table, keep looking if a cell array
            
            if t_rowDim.hasLabels
                [t_rowLabelsSorted,t_rowOrder] = sort(t_rowDim.labels);
            end
        elseif ~haveTime && isa(b,'timetable')
            % Tables and cell arrays can be concatenated onto a timetable, but not vice-versa
            if isa(varargin{1},'table')
                error(message('MATLAB:table:horzcat:TableAndTimetable'));   
            else
                % Must be cell array if not table
                error(message('MATLAB:table:horzcat:CellArrayAndTimetable'));             
            end
        elseif b_nvars==0 && b_nrows==0 % special case to mimic built-in behavior
            % do nothing
            continue;
        elseif t_nrows ~= b_nrows
            error(message('MATLAB:table:horzcat:SizeMismatch'));
        else
            b_rowDim = b.rowDim;
            if haveTime && ~isa(b,'timetable')
                t_data = horzcat(t_data, b.data); %#ok<AGROW>
            elseif t_rowDim.hasLabels && b_rowDim.hasLabels
                [b_rowLabelsSorted,b_rowOrder] = sort(b_rowDim.labels);
                if ~isequal(t_rowLabelsSorted,b_rowLabelsSorted)
                    if haveTime
                        error(message('MATLAB:table:horzcat:UnequalRowTimes'));
                    else
                        error(message('MATLAB:table:horzcat:UnequalRowNames'));
                    end
                end
                b_reord(t_rowOrder) = b_rowOrder; %#ok<AGROW>, full reassignment each time
                t_data = horzcat(t_data, cell(1,b_nvars)); %#ok<AGROW>
                for i = 1:b_nvars
                    bVar = b.data{i};
                    sizeOut = size(bVar);
                    if istabular(bVar)
                        t_data{t_nvars+i} = bVar.subsrefParens({b_reord,':'});
                    else
                        t_data{t_nvars+i} = reshape(bVar(b_reord,:),sizeOut);
                    end
                end
            else
                if b_rowDim.hasLabels % && ~t_rowDim.hasLabels
                    t_rowDim = b.rowDim;
                    [t_rowLabelsSorted,t_rowOrder] = sort(t_rowDim.labels);
                end
                t_data = horzcat(t_data, b.data); %#ok<AGROW>
            end
            
            % Make it official.
            t_nvars = t_nvars + b_nvars;
        end
        
        % If it was originally a cell array, there are no row labels or other
        % properties to worry about.
        if ~wasCell
            % If it was originally a table/timetable, get its var labels and
            % per-var properties.
            t_varDim = t_varDim.assignInto(b.varDim,vars_j);
            if needATable
                % If also the first table encountered, get its per-dim properties.
                t_metaDim = b.metaDim;
                needATable = false;
            end
        
            % Use any per-array property values not already present.
            t_arrayProps = tabular.mergeArrayProps(t_arrayProps,b.arrayProps);
        end
    end
    t.data = t_data;

    % Error if var labels are duplicates, and create default labels where labels are
    % not present from cell array inputs. Don't try to recognize and take one copy
    % of variables that have the same name and data, duplicate variable names are an
    % error regardless.
    t.varDim = t_varDim.setLabels(t_varDim.labels,[],false,true);
    
    % Detect conflicts between the combined var names of the result and the dim
    % names of the leading time/table.
    t.metaDim = t_metaDim.checkAgainstVarLabels(t.varDim.labels);
    
    t.rowDim = t_rowDim;
    t.arrayProps = t_arrayProps;
catch ME
    throwAsCaller(ME)
end
