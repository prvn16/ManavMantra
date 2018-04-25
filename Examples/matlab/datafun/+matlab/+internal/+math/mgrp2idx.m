function [ogroup,gdata,gcount] = mgrp2idx(group,rows,inclnan,inclempty)
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%
%MGRP2IDX Convert multiple grouping variables to index vector
%
%   [OGROUP,GDATA,GCOUNT] = MGRP2IDX(GROUP,ROWS,INCLNAN,INCLEMPTY) 
%   creates an index vector from the grouping variables in GROUP.  
%
%   Inputs: 
%       GROUP is a grouping variable (categorical variable, numeric vector,
%       numeric matrix, datetime vector, datetime matrix, duration vector, 
%       duration matrix, string matrix, or cell array of strings) or a cell
%       array of grouping variables. If GROUP is a cell array, all of the 
%       grouping variables that it contains must have the same number of 
%       rows. 
%
%       ROWS is used only to create a grouping var (all ones) in the 
%       special case when GROUP is a 1x0 cell array containing no grouping 
%       variables (it should be set to the length of the data variable).  
%       It is not used to check lengths of grouping variables against the 
%       data variable; the caller should do that.
%
%       INCLNAN is a true/false flag about whether to include NaNs present 
%       in the group.
%
%       INCLEMPTY is a true/false flag about whether to include groups
%       whose count is 0.
%
%   Outputs:
%       OGROUP is a vector of group indices.  
%
%       GDATA is a cell array containing one column vector per grouping 
%       variable. The column vectors contain one row for each distinct 
%       combination of grouping variable values.
%
%       GCOUNT is a vector containing the group counts for the data

%   Copyright 2017 The MathWorks, Inc.

% Compute number of grouping variables
ngrps = size(group,2);

% if no grouping vars, create one group containing all observations
if ngrps == 0
    ogroup = ones(rows,1);
    gdata = {};
    if ~inclempty && isequal(rows,0)
        gcount = double.empty(0,1);
    else
        gcount = rows;
    end
    return; % Fast exit
end

% Special case a single grouping variable
if ngrps == 1
    % Depending on nargout set the output correctly
    if nargout > 1
        [ogroup,countgrp,gdata{1}] = matlab.internal.math.grp2idx(group{1,1},inclnan,inclempty);
    else
        [ogroup,countgrp] = matlab.internal.math.grp2idx(group{1,1},inclnan,inclempty);
    end
    
    % if required compute group count
    if nargout > 2
        grpmat = ogroup;
        grpmat(isnan(grpmat))=[];
        rows = size(grpmat,1);
        gtag = sparse(1:rows,grpmat,ones(rows,1),rows,countgrp);
        gcount = full(sum(gtag,1))';
    end
    
    return; % Fast exit
end

% preallocate to avoid warnings
gd = cell(1,ngrps);
gdata = cell(1,ngrps);
countgrp = zeros(1,ngrps);

% Compute size of group variable to compare vs other group inputs 
es = size(group{1,1});

% Get integer codes and data/names for each grouping variable
for j=1:ngrps
    % Only calling with the output arguments required
    if nargout > 1
        [g,countgrp(j),gd{1,j}] = matlab.internal.math.grp2idx(group{1,j},inclnan,inclempty);
    else
        [g,countgrp(j)] = matlab.internal.math.grp2idx(group{1,j},inclnan,inclempty);
    end
    
    % Checking input size is correct (needed in findgroups)
    if any(size(group{1,j}) ~= es)
        error(message('MATLAB:findgroups:InputSizeMismatch'));
    end
    
    % If first row have to allocate grpmat
    if j == 1
        rows = size(g,1);
        grpmat = zeros(rows,ngrps);
    end
    
    % Assign output group
    grpmat(:,j) = g;
end

% First remove any NaN categories from grpmat (included missing will have
% number not NaNs)
wasnan = any(isnan(grpmat),2);
grpmat(wasnan,:) = [];

% recompute rows as the number of non-NaN entries
rows = size(grpmat,1);

% If including empties need to create all groups possible first
if inclempty
    
    % Compute the total number of groups
    prodgrp = prod(countgrp(1:j));
    
    % Create linear groupnumber from grpmat
    grplin = sum((grpmat-1).*(prodgrp./cumprod(countgrp)),2)+1;
    
    % For each grouping variable create group data if requested
    if nargout > 1
        for j=1:ngrps
            % catch the case where one grouping variable is all missing and include missing is false
            if prodgrp == 0 
                gnamerow = zeros(0,1);
            else
                % Compute number of repetitions for the data replications
                step = prodgrp/(prod(countgrp(1:j-1))*countgrp(j));
                left = prodgrp/(step*countgrp(j));
            
                % Compute the data numbers for group j for all groups
                gnametag = 1:countgrp(j);
                gnamerow = repmat(repelem(gnametag',step,1),left,1);
            end
            % Index with the group data numbers into gd to compute gdata
            gdata{1,j} = gd{1,j}(gnamerow);
        end
    end
    
    % Adding back missing groups that were ignored
    ogroup = NaN(size(wasnan));
    ogroup(~wasnan) = grplin;
    
    % If we requested groupcounts compute them
    if nargout > 2
        gtag = sparse(1:rows,grplin,ones(rows,1),rows,prodgrp);
        gcount = full(sum(gtag,1))';
    end
% If excluding empties things are simpler
else
    % Group according to each distinct combination of grouping variables, use
    % unique rows to determine combinations
    [urows,~,uj] = unique(grpmat,'rows');
    
    % Adding back missing groups that were ignored
    ogroup = NaN(size(wasnan));
    ogroup(~wasnan) = uj;
    
    % If want groupdata need to use uniquerows and original gd from grp2idx
    % to create the output combinations in gdata
    if nargout > 1
        for j=1:ngrps
            gdata{1,j} = gd{1,j}(urows(:,j));
        end
    end
    
    % If we want group counts also compute them (Ex: groupsummary)
    if nargout > 2
        % Compute largest group
        if isempty(uj)
            prodgrp = 0;
        else
            prodgrp = max(uj);
        end
        
        % Compute group count via sparse matrix (create sparse rows by 
        % numgroups matrix then sum down collumns
        gtag = sparse(1:rows,uj,ones(rows,1),rows,prodgrp);
        gcount = full(sum(gtag,1))';
    end
end