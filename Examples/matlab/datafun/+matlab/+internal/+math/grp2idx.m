function [gidx,ng,gdata] = grp2idx(group,inclnan,inclempty)
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%
% GRP2IDX  Create index vector from a grouping variable.
%
%   [GIDX,NG,GDATA] = GRP2IDX(GROUP,INCLNAN,INCLEMPTY) creates an index  
%   vector from the grouping variable GROUP. 
%
%   Inputs:
%       GROUP is a single vector variable. It can be a categorical,
%       numeric, logical, datetime or duration vector; a cell vector of 
%       strings; or a character matrix with each row representing a group 
%       label. 
%
%       INCLNAN is a true/false flag about whether to include NaNs present 
%       in the group.
%
%       INCLEMPTY is a true/false flag about whether to include empty 
%       categorical or logical entries when counting GIDX and in GDATA
%
%   Outputs:
%       GIDX is a vector taking integer values from 1 up to the number NG  
%       of distinct groups or NaN for excluded values. 
%
%       NG is an integer containing the number of groups
%
%       GDATA is a vector of the same type as GROUP containing the unique
%       values within GROUP

%   Copyright 2017-2018 The MathWorks, Inc.


% If group is char matrix or row vector throw nice error pointing to 
% cellstrs
if ischar(group) && size(group,2) > 1
    error(message('MATLAB:findgroups:CharData'));
end

% If group not vector error
if ~isvector(group)
    error(message('MATLAB:findgroups:GroupingVarNotVector'));
end

% If we have row input move to column for easier processing
if isrow(group) && ~isa(group,'tabular')
    group = group(:);
end    

if iscategorical(group) % categorical has easy option    
    
    % Call to hidden categorical grp2idx function
    [gidx,ng,gdata] = mlinternal_grp2idx(group,inclnan,inclempty);

elseif islogical(group) % logical has easy option
    
    % Check if we're including empty categories
    if inclempty
        % If so the groups are easily defined
        gidx = group + 1;
        ng = 2;
        gdata = [false; true];
    else
        % if group is empty set categories
        if isempty(group)
            gidx = double(group);
            ng = 0;
            gdata = group;
        else
            % If all are true or false only have one group
            if all(group) || ~any(group)
                gidx = ones(size(group));
                ng = 1;
                gdata = all(group);
            else
                % Otherwise same easy definition as above
                gidx = group + 1;
                ng = 2;
                gdata = [false; true];
            end
        end
    end
    
elseif isnumeric(group) || isdatetime(group) || isduration(group) || iscalendarduration(group)
    
    % For most types start with running unique
    [gdata,~,gidx] = unique(group);
    
    % Fix missing behavior
    if isdatetime(group)
        % Handle NaT missing values: return NaN group indices
        if ~isempty(gdata) && isnat(gdata(end)) % NaTs are sorted to end
            gdata = gdata(~isnat(gdata));
            if inclnan
                gidx(gidx > length(gdata)) = length(gdata)+1;
                gdata(end+1,1) = NaT;
            else
                gidx(gidx > length(gdata)) = NaN;
            end
        end
    else
        % Handle NaN missing values: return NaN group indices
        if ~isempty(gdata) && isnan(gdata(end)) % NaNs are sorted to end
            gdata = gdata(~isnan(gdata));
            if inclnan
                gidx(gidx > length(gdata)) = length(gdata)+1;
                gdata(end+1,1) = NaN;
            else
                gidx(gidx > length(gdata)) = NaN;
            end
        end
    end
    
    % Compute number of groups
    ng = size(gdata,1);
    
elseif iscell(group) || isstring(group)
    
    % For cellstrs and string use unique with some special checks copied
    % from stats grp2idx
    try
        [gdata,~,gidx] = unique(group);
    catch ME
        if isequal(ME.identifier,'MATLAB:UNIQUE:InputClass')
            error(message('MATLAB:findgroups:GroupTypeIncorrect',class(group)));
        else
            rethrow(ME);
        end
    end
    
    if ~isempty(gdata)
        % Need to handle missing for cellstr and strings
        % cellstr - '' is sorted to beginning
        % string  - missing is sorted to end and separate
        if inclnan
            % for cell nothing to do
            % for string need to merge missing
            if isstring(group) && ismissing(gdata(end))
                % delete entries from gdata and fix gidx 
                imiss = ismissing(gdata);
                idm = nnz(~imiss);
                gidx(gidx > idm) = idm+1;
                imiss(idm+1) = false;
                gdata(imiss) = [];
            end
        else
            if iscell(group) && strcmp('',gdata(1))
                % change group number and delete first entry
                gidx = gidx-1;
                gidx(gidx==0) = NaN;
                gdata(1)=[];
            elseif isstring(group) && ismissing(gdata(end))
                % delete entries from gdata and fix gidx
                imiss = ismissing(gdata);
                gidx(gidx > nnz(~imiss)) = NaN;
                gdata(imiss) = [];
            end
        end
        
        % sometimes empties are correct size and we don't need to transpose
        if isempty(gdata) && size(gdata,2) == 0 
            gdata = gdata';
        end
    end
    
    % Compute number of groups
    ng = size(gdata,1);
    
else
    % cannot group by tables error
    if isa(group,'tabular')
        error(message('MATLAB:findgroups:GroupTypeIncorrect',class(group)));
    end
    
    % attempt to call unique on unknown type, if that doesn't work error
    try 
        [gdata,~,gidx] = unique(group);
    catch ME
        error(message('MATLAB:findgroups:GroupTypeIncorrect',class(group)));
    end
    
    % ensure the index returned by unique has a group for each row
    if numel(gidx) ~= numel(group) 
        throwAsCaller(MException(message('MATLAB:findgroups:VarUniqueMethodFailedNumRows')));
    end
    
    % Compute number of groups
    ng = size(gdata,1);
end

