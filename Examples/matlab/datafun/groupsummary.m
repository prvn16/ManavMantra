function G = groupsummary(T,groupvars,varargin)
%GROUPSUMMARY Summary computations by group.
%   G = GROUPSUMMARY(T,GROUPVARS) for a table or timetable T, returns a
%   table containing the number of elements in each group created by the 
%   unique combinations of grouping variables in GROUPVARS. GROUPVARS must 
%   be a table variable name, a cell array of table variable names, a  
%   vector of table variable indices, a logical vector, or a function  
%   handle that returns a logical scalar (such as @isnumeric). GROUPVARS  
%   can also be [] to indicate no grouping and return the number of 
%   elements as the height of T.
%
%   GROUPSUMMARY(T,GROUPVARS,GROUPBINS) specifies the discretization for 
%   GROUPVARS to be done prior to grouping. If GROUPBINS is one of the 
%   options from the list below, then that discretization is applied to 
%   every grouping variable. Otherwise, GROUPBINS must be a cell array with 
%   one element for each grouping variable. Elements of GROUPBINS can be 
%   one of the following:
% 
%      - (default) 'none' indicating no discretization
%      - a list of bin edges specified as a numeric vector
%      - number of bins specified as an integer scalar
%      - time duration specified as a scalar of type duration or 
%        calendarDuration indicating bin widths for datetime or duration 
%        grouping variables
%      - time bins for datetime grouping variables specified as one of the 
%        following: 'second', 'minute', 'hour', 'day', 'week', 'month', 
%        'quarter', 'year', 'decade', 'century', 'secondofminute', 
%        'minuteofhour', 'hourofday', 'dayname','dayofweek', 'dayofmonth', 
%        'dayofyear', 'weekofmonth', 'weekofyear', 'monthofyear', 
%        'monthname', or 'quarterofyear'
%
%   GROUPSUMMARY(...,METHOD) also returns the computations specified by 
%   METHOD. METHOD is applied to all non-grouping variables in T. METHOD 
%   can be a function handle or name, or a cell array containing multiple 
%   function handles or names. Names can be any of the following:
%
%      'mean'       - mean
%      'sum'        - sum
%      'min'        - minimum
%      'max'        - maximum
%      'range'      - maximum - minimum
%      'median'     - median
%      'mode'       - mode
%      'var'        - variance
%      'std'        - standard deviation
%      'nummissing' - number of missing elements 
%      'nnz'        - number of non-zero and non-NaN elements
%      'all'        - all methods above
% 
%   GROUPSUMMARY(...,METHOD,DATAVARS) applies the methods to the data in 
%   the table variables specified by DATAVARS. The default is all 
%   non-grouping variables in T. DATAVARS must be a table variable name,  
%   a cell array of table variable names, a vector of table variable  
%   indices, a logical vector, or a function handle that returns a logical 
%   scalar (such as @isnumeric).
%
%   GROUPSUMMARY(...,'IncludeMissingGroups',TF) specifies whether groups 
%   of missing data in the grouping variables are included and given their  
%   own category. TF must be one of the following:
%      true     - (default) include missing groups 
%      false    - exclude missing groups
%
%   GROUPSUMMARY(...,'IncludeEmptyGroups',TF) specifies whether groups with 
%   0 elements are included in the output. TF must be one of the following:
%      true     - (default) include empty groups 
%      false    - exclude empty groups
%
%   GROUPSUMMARY(...,'IncludedEdge',LR) specifies which edge is included 
%   for each bin in the discretization. This N-V pair can only be used when 
%   GROUPBINS is specified. LR must be one of the following:
%      'left'     - (default) all bins include left bin edge, except for 
%                 the last bin which includes both edges.
%      'right'    - all bins include right bin edge, except for the first 
%                 bin which includes both edges.
%
%   Examples:
%
%      % Load data and create table
%      load patients;
%      T = table(Age,Gender,Height,Weight,'VariableNames', ...
%          {'Age','Gender','Height','Weight'})
%
%      % Compute the mean height by gender
%      G = groupsummary(T,'Gender','mean','Height')
%
%      % Compute the range for height and weight grouped by gender and age,
%      % and discretize into 5 bins
%      G = groupsummary(T,{'Gender','Age'},{'none',10},'range')
%
%   See also FINDGROUPS, SPLITAPPLY, DISCRETIZE.

%   Copyright 2017-2018 The MathWorks, Inc. 

narginchk(2,Inf);

% Suppress warnings thrown from vertcat
oldWarningState = warning;
warning('off','MATLAB:catenate:DimensionMismatch');
cleanupObj = onCleanup(@() warning(oldWarningState));

% If not table/timetable error
if ~isa(T,'tabular')
    error(message('MATLAB:groupsummary:FirstInputType'));
end

% Extract grouping variables
[groupvars,T] = checkVars(T,groupvars,'Group');

varnamesT = T.Properties.VariableNames;
if ~iscell(groupvars)
    groupvars = varnamesT(groupvars);
end

labels = groupvars;

groupingdata = cell(1,numel(groupvars));
for jj = 1:numel(groupvars)
    groupingdata{jj} = T{:,groupvars{jj}};
    % Special check since mgrp2idx allows row elements also
    if ~iscolumn(groupingdata{jj})
        error(message('MATLAB:findgroups:GroupingVarNotVector'));
    end
end

gclabel = {'GroupCount'};

% Set default values
datavars = varnamesT;
nummethods = 0;
inclempty = false;
inclnan = true;
incledge = 'left';

% Parse remaining inputs
gbProvided = false;
if nargin > 2
    indStart = 1;
    % Parse groupbins
    dvNotProvided = true;
    if isgroupbins(varargin{indStart})
        [groupbins,flag] = parsegroupbins(varargin{indStart});
        if flag
            numGroupBins = numel(groupbins);
            numGroupVars = numel(groupvars);
            % Number of groupbins must match groupvars unless groupbins is 1
            if isequal(numGroupBins,1)
                if isempty(groupbins{1})
                    error(message('MATLAB:groupsummary:GroupBinsEmpty'));
                elseif isequal(numGroupVars,0) && ~strcmpi(groupbins{1},'none')
                    error(message('MATLAB:groupsummary:GroupBinsNoGroupVars'));
                else
                    groupbins = repmat(groupbins,1,numGroupVars);
                end
            elseif ~isequal(numGroupVars,numGroupBins)
                error(message('MATLAB:groupsummary:GroupBinsVarsDiffSize'));
            end
            indStart = indStart + 1;
            gbProvided = true;
        end
    end
    if indStart < nargin-1
        % Parse method
        if ismethod(varargin{indStart})
            [methods,methodprefix,nummethods] = parsemethods(varargin{indStart});
            indStart = indStart + 1;
            if indStart < nargin-1
                %Parse data variables
                if (isnumeric(varargin{indStart}) || islogical(varargin{indStart}) || ...
                        ((ischar(varargin{indStart}) || isstring(varargin{indStart})) && ...
                        ~any(matlab.internal.math.checkInputName(varargin{indStart},{'IncludeEmptyGroups','IncludedEdge','IncludeMissingGroups'},8))) || ...
                        isa(varargin{indStart},'function_handle') || iscell(varargin{indStart}) || ...
                        rem(nargin-(indStart),2) == 0)                        
                        datavars = checkVars(T, varargin{indStart}, 'Data');
                        if ~iscell(datavars)
                            datavars = varnamesT(datavars);
                        end
                        datavars = unique(datavars,'stable');
                        dvNotProvided = false;
                    indStart = indStart + 1;
                end
            end
        end
    end
    
    % Parse name-value pairs
    if rem(nargin-(1+indStart),2) == 0
        for j = indStart:2:length(varargin)
            name = varargin{j};
            if (~(ischar(name) && isrow(name)) && ~(isstring(name) && isscalar(name))) ...
                || (isstring(name) && strlength(name) == 0)
                error(message('MATLAB:groupsummary:ParseFlags'));
            elseif matlab.internal.math.checkInputName(name,{'IncludeEmptyGroups'},8)
                inclempty = varargin{j+1};
                matlab.internal.datatypes.validateLogical(inclempty,'IncludeEmptyGroups');
            elseif matlab.internal.math.checkInputName(name,{'IncludeMissingGroups'},8)
                inclnan = varargin{j+1};
                matlab.internal.datatypes.validateLogical(inclnan,'IncludeMissingGroups');
            elseif matlab.internal.math.checkInputName(name,{'IncludedEdge'},8)
                if ~gbProvided
                    error(message('MATLAB:groupsummary:IncludedEdgeNoGroupBins'));
                end
                incledge = varargin{j+1};
            else
                error(message('MATLAB:groupsummary:ParseFlags'));
            end
        end
    elseif (nargin < 4) || (gbProvided && nargin < 5)
        error(message('MATLAB:groupsummary:InvalidMethodOption'));
    else
        error(message('MATLAB:groupsummary:KeyWithoutValue'));
    end
end

if gbProvided
    % Discretize grouping variables
    for jj = 1:numel(groupvars)
        if isempty(groupbins{jj})
            error(message('MATLAB:groupsummary:GroupBinsEmpty'));
        end
        [groupingdata{jj},labels{jj}] = discgroupvar(groupingdata{jj},labels{jj},groupbins{jj},incledge);
    end
    
    % Check for repeated pairs of groupvars and groupbins
    [uniqueLabels,~,idx] = unique(labels,'stable');
    rLabels = true(size(labels));
    for i = 1:numel(uniqueLabels)
        ridx = find(idx == idx(i));
        ctr = 1;
        rList = 0;
        for ii = 1:numel(ridx)
            for iii = ii+1:numel(ridx)
                if isequaln(groupbins{ridx(ii)},groupbins{ridx(iii)})
                    rLabels(ridx(iii)) = false;
                elseif ~any(isequal(rList,ridx(iii)))
                    labels{ridx(iii)} = [labels{ridx(iii)},'_',num2str(ctr)];
                    ctr = ctr+1;
                    rList(end,1) = ridx(iii);
                end
            end
        end
    end
    groupvars = groupvars(rLabels);
    groupingdata = groupingdata(rLabels);
    labels = labels(rLabels);
    numgvars = numel(groupvars);
else
    % Remove repeated groupvars
    [groupvars,ridx] = unique(groupvars,'stable');
    groupingdata = groupingdata(ridx);
    labels = labels(ridx);
    numgvars = numel(groupvars);
end

% Compute grouping index and data
[gvidx,gdata,gcount] = matlab.internal.math.mgrp2idx(groupingdata,size(T,1),inclnan,inclempty);

% Extract data variables
if nargin == 2
    if isempty(groupvars)
        % G = table(gcount,'VariableNames',{'GroupCount'});
        G = maketable([],gcount,[],gclabel,[],[],0,0);
    else
        % Make sure labels are unique
        uniquelabels = matlab.lang.makeUniqueStrings([labels,gclabel]);
        uniquelabels = string(uniquelabels);
        labels = {uniquelabels{1:numgvars}};
        gclabel = {uniquelabels{numgvars+1}};
        % G = table(gdata{:},gcount,'VariableNames',{labels{:} 'GroupCount'});
        G = maketable(gdata,gcount,[],gclabel,labels,[],numgvars,0);
    end
    return;
else
    if dvNotProvided
        dvtab = T(:,datavars);
        dvtab(:,groupvars)=[];
    else
        dvtab = T(:,datavars);
    end
    numdatavars = size(dvtab,2);
    datalabels = dvtab.Properties.VariableNames;
    data = cell(1,numdatavars);
    for i=1:numdatavars
        data{i} = dvtab{:,i};
        if ~(iscolumn(data{i}) || isempty(data{i}))
            error(message('MATLAB:groupsummary:NonVectorTableVariable',datalabels{i}));
        end
    end
end

% Compute group summary computations
gstats = cell(1,nummethods*numdatavars);
gstatslabel = cell(1,nummethods*numdatavars);
idx = ~isnan(gvidx);
gvidx = gvidx(idx);
for ii = 1:numdatavars
    for jj = 1:nummethods
        try
            x = data{ii};
            f = methods{jj};
            if isempty(x)
                g = @(y) {f(x(y,:))};
            else
                x = x(idx);
                g = @(y) {f(x(y))};
            end
            % Error for median of char
            if strcmp(methodprefix{jj},'median') && ischar(x)
                error(message('MATLAB:groupsummary:ApplyDataVarsError',methodprefix{jj},datalabels{ii}));
            end
            
            % Determine type of fill values
            if any(strcmp(methodprefix{jj},{'nummissing','nnz'}))
                fillval = 0;
            elseif strcmp(methodprefix{jj},'sum')
                c = str2func([class(x) '.empty']);
                fillval = f(c(0,1));
            elseif ~strncmp(methodprefix{jj},'fun',3)
                fillval = missing;
            else % function handle
                c = str2func([class(x) '.empty']);
                fillval = f(c(1,0));
                if isempty(fillval)
                    fillval = missing;
                end
            end
            
            % Correct fill value for special cases
            if isempty(x)
                c = str2func([class(x) '.empty']);
                fillval = f(c(1,0));
            else
                d1 = f(x(1));
                if isinteger(d1)
                    fillval = cast(NaN,class(d1));
                elseif islogical(d1)
                    fillval = false;
                elseif ischar(d1)
                    fillval = ' ';
                end
            end
            
            % Convert missing if only output is empty group
            if numel(gcount) == 1 && isequal(class(fillval),'missing')
                c = str2func([class(f(x)) '.empty']);
                fillval = c(1,0);
            end
            
            d = accumarray(gvidx,(1:numel(gvidx)).',[size(gcount,1) 1],g,{fillval});
            
            % Check to make sure method returned one element per group
            if any(cellfun(@numel,d) > 1)
                error(message('MATLAB:groupsummary:ApplyDataVarsError',methodprefix{jj},datalabels{ii}));
            end
            
            gstats{(ii-1)*nummethods + jj} = vertcat(d{:,1});
            % Check to make sure vertcat output the correct number of elements
            if ~isequal(size(gstats{(ii-1)*nummethods + jj},1),size(gcount,1))
                error(message('MATLAB:groupsummary:ApplyDataVarsError',methodprefix{jj},datalabels{ii}));
            end
            gstatslabel{(ii-1)*nummethods + jj} = [methodprefix{jj} '_' datalabels{ii}];
        catch ME
            % Return error message with added information
            m = message('MATLAB:groupsummary:ApplyDataVarsError',methodprefix{jj},datalabels{ii});
            throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
        end
    end
end

% Make sure all labels are unique
uniquelabels = matlab.lang.makeUniqueStrings([labels,gclabel,gstatslabel]);
uniquelabels = string(uniquelabels);
labels = {uniquelabels{1:numgvars}};
gclabel = {uniquelabels{numgvars+1}};
gstatslabel = {uniquelabels{numgvars+2:end}};

% Assemble results
if isempty(groupvars)
%     G = table(gcount,gstats{:},'VariableNames',{'GroupCount' gstatslabel{:}});
    G = maketable([],gcount,gstats,gclabel,[],gstatslabel,0,numdatavars*nummethods);
else
%     G = table(gdata{:},gcount,gstats{:},'VariableNames',{labels{:} 'GroupCount' gstatslabel{:}});
    G = maketable(gdata,gcount,gstats,gclabel,labels,gstatslabel,numgvars,numdatavars*nummethods);
end


end

%--------------------------------------------------------------------------
function G = maketable(gdata,gcount,gstats,gclabel,labels,gstatslabel,numgvars,numdatavars)
%MAKETABLE Create table through struct 
%   This helper function creates a table 2x faster than calling table
%   constructor
    gs = struct;
    for i=1:numgvars
        gs.(labels{i})=gdata{i};
    end

    gs.(gclabel{1}) = gcount;
    for i=1:numdatavars
        gs.(gstatslabel{i})=gstats{i};
    end

    G = struct2table(gs);
end

%--------------------------------------------------------------------------
function [gd,label] = discgroupvar(gd,label,gbins,incledge)
%DISCGROUPVAR Discretize groupiung variable
%   This function will discretize the grouping variable gd according to
%   gbinds and update the label accordingly
    if strcmpi(gbins,'none')
        return;
    elseif (isnumeric(gbins) || isduration(gbins) || iscalendarduration(gbins) || isdatetime(gbins))
        gd = discretize(gd,gbins,'categorical','IncludedEdge',incledge);
        label = ['disc_' label];
    else
        try
            if isduration(gd) || isdatetime(gd)
                switch lower(gbins)
                    case 'secondofminute'
                        gd = categorical(floor(second(gd)),0:59);
                    case 'minuteofhour'
                        gd = categorical(minute(gd),0:59);
                    case 'hourofday'
                        if isduration(gd)
                            error(message('MATLAB:groupsummary:GroupBinsError',gbins,label));
                        else
                            gd = categorical(hour(gd),0:23);
                        end
                    case 'dayname'
                        gd = categorical(day(gd,'name'),datetime.DaysOfWeek.Long);
                    case 'dayofweek'
                        if isduration(gd)
                            error(message('MATLAB:groupsummary:GroupBinsError',gbins,label));
                        else
                            gd = categorical(day(gd,gbins),1:7);
                        end
                    case 'dayofmonth'
                        if isduration(gd)
                            error(message('MATLAB:groupsummary:GroupBinsError',gbins,label));
                        else
                            gd = categorical(day(gd,gbins),1:31);
                        end
                    case 'dayofyear'
                        if isduration(gd)
                            error(message('MATLAB:groupsummary:GroupBinsError',gbins,label));
                        else
                            gd = categorical(day(gd,gbins),1:366);
                        end
                    case 'weekofmonth'
                        gd = categorical(week(gd,gbins),1:6);
                    case 'weekofyear'
                        gd = categorical(week(gd,gbins),1:54);
                    case 'monthname'
                        if isduration(gd)
                            error(message('MATLAB:duration:MonthsNotSupported','month'));
                        else
                            gd = categorical(month(gd,'name'),datetime.MonthsOfYear.Long);
                        end
                    case 'monthofyear'
                        if isduration(gd)
                            error(message('MATLAB:duration:MonthsNotSupported','month'));
                        else
                            gd = categorical(month(gd,gbins),1:12);
                        end
                    case 'quarterofyear'
                        gd = categorical(quarter(gd),1:4);
                    otherwise
                        gd = discretize(gd,gbins,'categorical','IncludedEdge',incledge);
                end
            else
                gd = discretize(gd,gbins,'categorical','IncludedEdge',incledge);
            end
        catch ME
            % Return error message 
            m = message('MATLAB:groupsummary:GroupBinsError',gbins,label);
            throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
        end
        label = [gbins '_' label];
    end      
end

%--------------------------------------------------------------------------
function tf = isgroupbins(gb)
%ISGROUPBINS Finds if gb is a groupbin specification
    if isstring(gb)
        gb = cellstr(gb);
    elseif ~iscell(gb)
        gb = {gb};
    end
    
    if isempty(gb) % Catch {} case
        error(message('MATLAB:groupsummary:GroupBinsEmpty'));                
    elseif isnumeric(gb{1}) || isduration(gb{1}) || iscalendarduration(gb{1}) || isdatetime(gb{1})
        tf = true;
    else
        if (ischar(gb{1}) && isrow(gb{1})) || isstring(gb{1})
            tf = any(startsWith({'none', 'second', 'minute', 'hour', 'day', 'week', 'month', 'quarter', ...
                                 'year', 'decade', 'century', 'secondofminute', 'minuteofhour', ...
                                 'hourofday', 'dayname','dayofweek', 'dayofmonth', 'dayofyear', 'weekofmonth',...
                                 'weekofyear', 'monthofyear', 'monthname', 'quarterofyear'},char(gb{1}),'IgnoreCase',true));
        else
            tf = false;
        end
    end 
end

%--------------------------------------------------------------------------
function [groupbins,flag] = parsegroupbins(groupbins)
%PARSEGROUPBINS Checks if we in fact have groupbins and they have correct 
%partial matching.  Assembles groupbins into a cell array.

if isstring(groupbins)
    groupbins = cellstr(groupbins);
end
if ischar(groupbins) || isnumeric(groupbins) || isduration(groupbins) || iscalendarduration(groupbins) || isdatetime(groupbins)
    groupbins = {groupbins};
end

flag = true;
for j = 1:numel(groupbins)
    if ischar(groupbins{j}) || isstring(groupbins{j})
        if strncmpi(groupbins{j},'none',2)
            groupbins{j} = 'none';
        elseif strcmpi(groupbins{j},'second')
            groupbins{j} = 'second';
        elseif strcmpi(groupbins{j},'minute')
            groupbins{j} = 'minute';
        elseif strcmpi(groupbins{j},'hour')
            groupbins{j} = 'hour';
        elseif strcmpi(groupbins{j},'day')
            groupbins{j} = 'day';
        elseif strcmpi(groupbins{j},'week')
            groupbins{j} = 'week';
        elseif strcmpi(groupbins{j},'month')
            groupbins{j} = 'month';
        elseif strcmpi(groupbins{j},'quarter')
            groupbins{j} = 'quarter';
        elseif strncmpi(groupbins{j},'year',1)
            groupbins{j} = 'year';
        elseif strncmpi(groupbins{j},'decade',2)
            groupbins{j} = 'decade';
        elseif strncmpi(groupbins{j},'century',1)
            groupbins{j} = 'century';
        elseif strncmpi(groupbins{j},'secondofminute',7)
            groupbins{j} = 'secondofminute';
        elseif strncmpi(groupbins{j},'minuteofhour',7)
            groupbins{j} = 'minuteofhour';
        elseif strncmpi(groupbins{j},'hourofday',5)
            groupbins{j} = 'hourofday';
        elseif strncmpi(groupbins{j},'dayname',4)
            groupbins{j} = 'dayname';
        elseif strncmpi(groupbins{j},'dayofweek',6)
            groupbins{j} = 'dayofweek';
        elseif strncmpi(groupbins{j},'dayofmonth',6)
            groupbins{j} = 'dayofmonth';
        elseif strncmpi(groupbins{j},'dayofyear',6)
            groupbins{j} = 'dayofyear';
        elseif strncmpi(groupbins{j},'weekofmonth',7)
            groupbins{j} = 'weekofmonth';
        elseif strncmpi(groupbins{j},'weekofyear',7)
            groupbins{j} = 'weekofyear';
        elseif strncmpi(groupbins{j},'monthofyear',6)
            groupbins{j} = 'monthofyear';
        elseif strncmpi(groupbins{j},'monthname',6)
            groupbins{j} = 'monthname';
        elseif strncmpi(groupbins{j},'quarterofyear',8)
            groupbins{j} = 'quarterofyear';
        else
            if j == 1 %Partial match didn't work, go to method parsing
                flag = false;
                return;
            else
                error(message('MATLAB:groupsummary:GroupBinsEmpty'));
            end
        end
    end
        
end

end

%--------------------------------------------------------------------------
function tf = ismethod(methods)
%ISGROUPBINS Finds if gb is a groupbin specification
    if isstring(methods)
        methods = cellstr(methods);
    elseif ~iscell(methods)
        methods = {methods};
    end
    
    if isempty(methods)
        tf = false;
    elseif isa(methods{1},'function_handle')
        tf = true;
    else
        if (ischar(methods{1}) && isrow(methods{1})) || isstring(methods{1})
            tf = any(startsWith({'all', 'mean', 'sum', 'min', 'max', 'range', ...
                'median', 'mode', 'var', 'std', 'nummissing', 'nnz'},char(methods{1}),'IgnoreCase',true));
        else
            tf = false;
        end
    end 
end

%--------------------------------------------------------------------------
function [methods,methodprefix,nummethods] = parsemethods(methods)
%PARSEMETHODS Assembles methods into a cell array of function handles
%   This function checks and replaces all with list of methods then changes
%   values into function handles and computes correct prefixes for the
%   methods given

if isstring(methods)
    methods = cellstr(methods);
elseif ~iscell(methods)
    methods = {methods};
end
nummethods = numel(methods);

% Check for all option
isall = false(1,nummethods);
for jj = nummethods:-1:1
    if isstring(methods{jj})
        methods{jj} = char(methods{jj});
    end
    if ischar(methods{jj}) && strncmpi(methods{jj},'all',1)
        isall(jj) = true;
        firstall = jj;
    end
end
if any(isall)
    methods(isall) = [];
    allmethods = {'mean', 'sum', 'min', 'max', 'range', 'median', 'mode', 'var', 'std', 'nummissing', 'nnz'};
    methods = {methods{1:firstall-1} allmethods{:} methods{firstall:end}}; %#ok
    nummethods = numel(methods);
end

% Change each option to a function handle and set names appropriately
methodprefix = cell(1,nummethods);
numfun = 1;
for jj = 1:nummethods
    if ischar(methods{jj})
        if strncmpi(methods{jj},'nummissing',2)
            methods{jj} = @(x) sum(ismissing(x),1);
            methodprefix{jj} = 'nummissing';
        elseif strncmpi(methods{jj},'nnz',2)
            methods{jj} = @(x) nnz(x(~ismissing(x)));
            methodprefix{jj} = 'nnz';
        elseif strncmpi(methods{jj},'mean',3)
            methods{jj} = @(x) mean(x,1,'omitnan');
            methodprefix{jj} = 'mean';
        elseif strncmpi(methods{jj},'median',3)
            methods{jj} = @(x) median(x,1,'omitnan');
            methodprefix{jj} = 'median';
        elseif strncmpi(methods{jj},'mode',3)
            methods{jj} = @(x) mode(x,1);
            methodprefix{jj} = 'mode';
        elseif  strncmpi(methods{jj},'var',1)
            methods{jj} = @(x) var(x,0,1,'omitnan');
            methodprefix{jj} = 'var';
        elseif  strncmpi(methods{jj},'std',2)
            methods{jj} = @(x) std(x,0,1,'omitnan');
            methodprefix{jj} = 'std';
        elseif  strncmpi(methods{jj},'min',3)
            methods{jj} = @(x) min(x,[],1,'omitnan');
            methodprefix{jj} = 'min';
        elseif strncmpi(methods{jj},'max',2)
            methods{jj} = @(x) max(x,[],1,'omitnan');
            methodprefix{jj} = 'max';
        elseif strncmpi(methods{jj},'range',1)
            methods{jj} = @(x) max(x,[],1,'omitnan') - min(x,[],1,'omitnan');
            methodprefix{jj} = 'range';
        elseif strncmpi(methods{jj},'sum',2)
            methods{jj} = @(x) sum(x,1,'omitnan');
            methodprefix{jj} = 'sum';
        else
            error(message('MATLAB:groupsummary:InvalidMethodOption'));
        end
    else
        if ~isa(methods{jj},'function_handle')
            error(message('MATLAB:groupsummary:InvalidMethodOption'));
        end
        methodprefix{jj} = ['fun' num2str(numfun)];
        numfun = numfun +1;
    end
end

% Remove repeated method names
[methodprefix,idx] = unique(methodprefix,'stable');
methods = methods(idx);
nummethods = numel(methods);

end

%--------------------------------------------------------------------------
function [vars,T] = checkVars(T,vars,eid)
%checkVars Validate Grouping and Data Variables

if isstring(vars)
    vars(ismissing(vars)) = '';
    vars = cellstr(vars); % errors for <missing> string
end
% Allow grouping on time variable of timetable
if strcmpi(eid,'Group') && istimetable(T)
    if any(strcmpi(T.Properties.DimensionNames{1},vars))
        T = timetable2table(T);
    end
end
try
    varfun(@(x)x,T,'InputVariables',vars);
catch ME
    if strcmp(ME.identifier,'MATLAB:table:varfun:InvalidInputVariablesFun')
        error(message(['MATLAB:groupsummary:',eid,'VariablesFunctionHandle']));
    else
        error(message(['MATLAB:groupsummary:',eid,'VariablesTableSubscript']));
    end
end

if isa(vars,'function_handle')
    try
        vars = varfun(vars,T,'OutputFormat','uniform');
    catch ME
        error(message(['MATLAB:groupsummary:',eid,'VariablesFunctionHandle']));
    end
    vars = find(reshape(vars,1,[]));
elseif ischar(vars)
    vars = {vars};    
else
    vars = reshape(vars,1,[]);
end
end