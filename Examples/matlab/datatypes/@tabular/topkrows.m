function [b,idx] = topkrows(a,k,varargin)
%TOPKROWS Top K sorted rows of table.
%   B = TOPKROWS(A,K) returns the top K rows of A sorted in descending
%   order by all of the variables in A. The rows in B are sorted first by
%   the first variable, next by the second variable, and so on.
%
%   B = TOPKROWS(A,K,VARS) returns the top K rows sorted by the variables
%   specified by VARS. VARS can be a positive integer, a vector of positive
%   integers, a variable name, a cell array containing one or more variable
%   names, or a logical vector. VARS can also include the name of the row
%   dimension, i.e. A.Properties.DimensionNames{1}, to sort by row names as
%   well as by data variables. By default, the row dimension name is 'Row'.
%
%   B = TOPKROWS(A,K,'RowNames') returns the top K rows sorted by the 
%   row names.
%
%   B = TOPKROWS(A,K,VARS,DIRECTION) also specifies the sort direction(s).
%   DIRECTION can be:
%       'descend' - (default) Sorts in descending order.
%        'ascend' - Sorts in ascending order.
%
%   TOPKROWS sorts A in ascending or descending order according to all
%   variables specified by VARS. Use a different direction for each
%   variable by specifying DIRECTION as a cell array. For example,
%   TOPKROWS(A,5,[2 3],{'ascend' 'descend'}). Specify VARS as 1:SIZE(A,2)
%   to sort using all variables.
%
%   B = TOPKROWS(A,K,VARS,DIRECTION,'ComparisonMethod',C) specifies how to
%   compare complex numbers. The comparison method C can be:
%       'auto' - (default) Compares real numbers according to 'real', and
%                complex numbers according to 'abs'.
%       'real' - Compares according to REAL(A). Elements with equal real
%                parts are then sorted by IMAG(A).
%        'abs' - Compares according to ABS(A). Elements with equal
%                magnitudes are then sorted by ANGLE(A).
%
%   [B,I] = TOPKROWS(...) also returns an index vector I that describes
%   the order of the K selected rows such that B = A(I,:).
%
%   See also SORTROWS.

%   Copyright 2017 The MathWorks, Inc.

% Parse K and error if incorrect value given
if (~isnumeric(k) || ~isscalar(k) || (k ~= floor(k)) || (k < 0))
    error(message('MATLAB:table:topkrows:InvalidK'));
end

% Change K to numrows if more were asked
if (k > a.rowDim.length)
    k = a.rowDim.length;
end
    
% Parse columns, directions and extract data to select on
[vars,varData,sortMode,labels,vararginNV] = topkrowsFlagChecks(a,varargin{:});

% Cells besides cellstrs are not supported at this time by topkrows
if ( any ( cellfun(@iscell,varData) - cellfun(@iscellstr,varData)))
    error(message('MATLAB:table:topkrows:GenCellNotSupported'));
end

% If k is 0 fast exit
if (k == 0)
    idx = [];
    b = a.subsrefParens({idx ':'});
    return
end

% If no columns to sort by fast exit
if (numel(vars)== 0)
    idx = (1:k)';
    b = a.subsrefParens({idx ':'});
    return
end 

% If sorting by RowNames with no labels fast exit
if (isequal(vars,0) && ~a.rowDim.hasLabels)
    idx = (1:k)';
    b = a.subsrefParens({idx ':'});
    return
end

% Compute gradual maxk/mink computation on each succesive column of data in
% a. After each column check the kth element, find it's ties and sort those
% based on next columns. 
if isequal(vars,0) 
    % fast special case for simple row labels cases
    curdata = varData{1};
    if iscellstr(curdata)
            curdata = string(curdata);
    end
    [~,idx] = topk(curdata,k,sortMode(1),vararginNV,labels{1});
    b = a.subsrefParens({idx ':'});
    return;
else
    % Set up initial starting data
    kleft = k;
    indv = 1;
    idxleft = (1:size(varData{1},1))';
    idx = [];
    
    while (indv <= numel(vars))
        % Select only data from column that needs to be compared
        curdata = varData{indv};
        
        % Since we do not handle cellstr convert to String
        if iscellstr(curdata)
            curdata = string(curdata);
        end
        
        % If ND error because indexing below could squeeze out extra dims
        if ~ismatrix(curdata)
            error(message('MATLAB:table:topkrows:NDVar',labels{indv}));
        elseif matlab.internal.datatypes.istabular(curdata)
            % Error gracefully when trying to compare tables of tables
            error(message('MATLAB:table:topkrows:SortOnVarFailed',labels{indv},class(curdata)));
        end
        curdata = curdata(idxleft,:);
        
        % Find max or min kleft elements
        [kdata,it] = topk(curdata,kleft,sortMode(indv),vararginNV,labels{indv});
        
        if iscolumn(kdata)
            % Extract kth element and see which are same in kdata and
            % curdata
            kth = kdata(kleft);
            if (ismissing(kth))
                ksame = ismissing(kdata);
                datasame = ismissing(curdata);
            else
                ksame = (kdata == kth);
                datasame = (curdata == kth);
            end
        else
            % Extract kth row and compare with others in kdata and curdata
            kth = kdata(kleft,:);
            kthnan = ismissing(kth);
            
            % find same rows in kdata
            ksamem = (kdata == kth);
            misksame = ismissing(kdata) & kthnan;
            ksamem(misksame) = true;
            ksame = all(ksamem,2);
            
            % find same rows in curdata
            datasamem = (curdata == kth);
            misdatasame = ismissing(curdata) & kthnan;
            datasamem(misdatasame) = true;
            datasame = all(datasamem,2);
        end
            
        % Compute how many are same and how many left to compare
        kleft = sum(ksame);
        ktotal = sum(datasame);
        
        % Update indices decided and still to consider
        idx = [idx; idxleft(it(~ksame))];
        idxleft = idxleft(datasame);
            
        % If done then exit
        if (kleft == ktotal)
            break;
        end
        
        % Advance to next column
        indv = indv +1;
    end
    
    % Need to grab last kleft into index
    idx = [idx; idxleft(1:kleft)];
end

% grab only rows in idx
b = a.subsrefParens({idx ':'});
datachange = false;
for j=1:numel(vars)
    % change char to uint16
    if ischar(varData{j})
        repData=uint16(varData{j}(idx,:));
        b = b.replaceData(repData,vars(j));
        datachange= true;
    end
    
    % change cellstr to string
    if iscellstr(varData{j})
        repData=string(varData{j}(idx,:));
        if vars(j) == 0
            varpos = b.varDim.length + 1;
            b = b.subsasgnDot(varpos,repData);
            vars(j) = varpos;
        else
            b = b.replaceData(repData,vars(j));
        end
        datachange= true;
    end
end

% Once k rows are selected need to perform one last sort as ties before the
% kth element would not have been solved correctly above
sortVals = {'ascend' 'descend'};

% If having RowTimes use labels
if any(vars == 0)
    vars = labels;
end

% Faster to perform sort of k elements in all cases
[b,it] = sortrows(b,vars,sortVals(sortMode),vararginNV{:},'MissingPlacement','last');

% fix index also
idx = idx(it);

% If changed datatype reindex to get correct data
if datachange
    b = a.subsrefParens({idx ':'});
end

end


% Subfunction to call maxk/mink with correct argument list or topkrows for 
% multi-column variables; This function also throws appropriate errors if
% encountering issues
% As a workaround for topkrows not supporting string calling sortrows and
% indexing 1:k
function [t,i]=topk(var,k,sortvar,vararginNV,label)
    if ~ismatrix(var)
            error(message('MATLAB:table:topkrows:NDVar',label));
    elseif matlab.internal.datatypes.istabular(var)
            % Error gracefully when trying to compare tables of tables
            error(message('MATLAB:table:topkrows:SortOnVarFailed',label,class(var)));
    else
        try
            if (isstring(var))
                col = 1:size(var,2);
                if isempty(vararginNV)
                    if sortvar == 1
                        [t,i] = sortrows(var,col,'ascend','MissingPlacement','last');
                    else % sortvar = 2
                        [t,i] = sortrows(var,col,'descend','MissingPlacement','last');
                    end 
                else
                    if sortvar == 1
                        [t,i] = sortrows(var,col,'ascend',vararginNV{:},'MissingPlacement','last');
                    else
                        [t,i] = sortrows(var,col,'descend',vararginNV{:},'MissingPlacement','last');
                    end
                end
                t = t(1:k,:);
                i = i(1:k,:);
            else
                % Try selecting top k elements with maxk/mink or topkrows
                if iscolumn(var)
                    if isempty(vararginNV)
                        if sortvar == 1
                            [t,i] = mink(var,k);
                        else % sortvar == 2
                            [t,i] = maxk(var,k);
                        end
                    else
                        if sortvar == 1
                            [t,i] = mink(var,k,vararginNV{:});
                        else % sortvar == 2
                            [t,i] = maxk(var,k,vararginNV{:});
                        end
                    end
                else
                    col = 1:size(var,2);
                    if isempty(vararginNV)
                        if sortvar == 1
                            [t,i] = topkrows(var,k,col,'ascend');
                        else % sortvar = 2
                            [t,i] = topkrows(var,k,col,'descend');
                        end 
                    else
                        if sortvar == 1
                            [t,i] = topkrows(var,k,col,'ascend',vararginNV{:});
                        else
                            [t,i] = topkrows(var,k,col,'descend',vararginNV{:});
                        end
                    end
                end
            end
        catch ME
            % Return error message 
            m = message('MATLAB:table:topkrows:SortOnVarFailed',label,class(var));
            throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
        end
    end
end