function [gnums, varargout] = findgroups(varargin)
%FINDGROUPS Find groups and return group numbers
%   G = FINDGROUPS(A) returns G, a vector of group numbers created from the
%   grouping variable A. G contains integer values from 1 to N, indicating
%   N distinct groups for the N unique values in A.
%
%   A is a categorical, numeric, logical, string, datetime, duration,
%   or calendarDuration vector, or a cell array of character vectors.
%   G has the same length as A.
%
%   [G,ID] = FINDGROUPS(A) also returns ID, a vector of the N unique values
%   that identify each group in A. ID has the same type as A.
%
%   [G,ID1,ID2,...] = FINDGROUPS(A1,A2,...) returns group numbers created
%   from one or more grouping variables A1,A2,... . Each group is defined
%   by a unique combination of values across A1,A2,... .
%   [ID1(J),ID2(J),...] contains the values that define the J-th group.
%
%   [G,TID] = FINDGROUPS(T) returns group numbers created from the
%   variables in the table T. The length of G equals the number of rows of
%   T. Each group is defined by a unique combination of values in the rows
%   of T. TID is a table where TID(J,:) contains the values that define the
%   J-th group.
%
%   FINDGROUPS returns NaNs for corresponding missing elements in A.
%   Examples of missing elements are:
%       * NaN in a double array
%       * '' in a cell array of character vectors
%       * Any element that displays as <missing>, without quotes
%   For more information on missing elements type "help ismissing".
%
%   Examples:
%      % Load patients data.
%      % List Weight, Gender, and Smoker variables for patients.
%      load patients;
%      whos Weight Gender Smoker
%      
%      % Find the mean weights by gender.
%      G = findgroups(Gender);
%      Y = splitapply(@mean,Weight,G)
%
%      % Find the median weights by gender. Create a table containing the
%      % results.
%      [G,gender] = findgroups(Gender);
%      medianWeight = splitapply(@median,Weight,G)
%      results = table(gender,medianWeight)
%
%      % Find the mean weights for all four groups of patients. 
%      G = findgroups(Gender,Smoker);
%      Y = splitapply(@mean,Weight,G)
%
%      % Find the mean weights for the four groups of patients. Create a table
%      % containing the results.
%      [G,gender,smoker] = findgroups(Gender,Smoker);
%      meanWeight = splitapply(@mean,Weight,G);
%      results = table(gender,smoker,meanWeight)
%     
%      % Read power loss data into a table.
%      % Find the maximum power loss in each region and by cause of power
%      % outage. Specify the grouping variables using table indexing.
%      % Return the maximum power losses in a table.
%      T = readtable('outages.csv');
%      summary(T)
%      [G,powerLoss] = findgroups(T(:,{'Region','Cause'}));
%      powerLoss.maxLoss = splitapply(@max,T.Loss,G)
%      
%   See also SPLITAPPLY, UNIQUE, ISMEMBER, ISMISSING

% Copyright 2015-2016 The MathWorks, Inc.

narginchk(1,inf);
nargoutchk(0, nargin+1);

% Parse inputs into grouping variables. Remember which grouping variables
% come from table input and the corresponding variable names
[groupVars, outVarIdx, tOutTemplate] = parseInput(varargin);

if isscalar(groupVars) % fast case for a single grouping variable
    [gnums,gnames{1}] = localgrp2idx(groupVars{1});
else % Group according to each distinct combination of grouping variables
    nGrpVars = size(groupVars,2);
    grpLabelmat = cell(1,nGrpVars);
    grpIdxMat = zeros(0,nGrpVars);
    gIsRow = false;
    
    % Get integer codes and names for each grouping variable
    for j=1:nGrpVars
        [grpIdx,gLabel] = localgrp2idx(groupVars{1,j});
        if j==1
            outputSize = size(grpIdx);
            
            gIsRow = isrow(grpIdx);
            grpIdxMat = zeros(size(grpIdx(:),1),nGrpVars);
        elseif any(size(grpIdx)~=outputSize)
            error(message('MATLAB:findgroups:InputSizeMismatch'));
        end
        grpIdxMat(:,j) = grpIdx(:);
        grpLabelmat{1,j} = gLabel;
    end
    
    % Find all unique combinations
    wasnan = any(isnan(grpIdxMat),2);    
    grpIdxMat(wasnan,:) = [];
    [urows,~,uj] = unique(grpIdxMat,'rows','sorted');
    
    % Create an index vector based on those unique combinations
    gnums = NaN(size(wasnan));
    gnums(~wasnan) = uj;

    % restore original orientation
    if gIsRow
        gnums = gnums';
    end
    
    gnames = cell(1,nGrpVars);
    for j=1:nGrpVars
        gLabel = grpLabelmat{1,j};
        gnames{j} = gLabel(urows(:,j));
    end
    
    
end

if nargout<=1
    return; % don't compute varargout
end

% Build output for group IDs
varargout = cell(1, nargin);
for i = 1:nargin
    if istable(tOutTemplate{i})
        gnames_i = gnames(outVarIdx{i});
        varargout{i} = table(gnames_i{:});
        varargout{i}.Properties = tOutTemplate{i}.Properties;
    else
        varargout(i) = gnames(outVarIdx{i});
    end
end
end

%-------------------------------------------------------------------------------
function [groupVars, outVarIdx, tOutTemplate] = parseInput(userInput)
% ParseInput Extract grouping variables from user inputs.
%   [GROUPVARS, OUTVARIDX, TOUTTEMPLATE] = PARSEINPUT(USERINPUT) extracts
%   into GROUPVARS a cell array of grouping variables from USERINPUT.
%   PARSEINPUT does not verify types of USERINPUT. Variables in table
%   entries in USERINPUT are extracted as individual grouping variables;
%   non-table entries are treated as grouping variables on their own.
%
%   OUTVARIDX is a cell array of indices the same length as USERINPUT. Each
%   cell contains indices into GROUPVARS. These indices indicate which
%   grouping variables in GROUPVARS correspond to each element in
%   USERINPUT. Cells of OUTVARIDX that correspond to table entries in
%   USERINPUT have the same number of indices as there are variables in the
%   table.
%
%   TOUTTEMPLATE is a cell array the same length as USERINPUT. Cells that
%   corresponds to table entries in USERINPUT contain a 0-by-N sub-table
%   where N is the number of variables in that table. Cells that
%   corresponds to non-table entries in USERINPUT will be empty.

% Total number of grouping variables equal sum of non-table inputs and
% total number of variables across all table inputs
isTabularInput = cellfun(@matlab.internal.datatypes.istabular, userInput);
nGrpVars = sum(cellfun(@width, userInput(isTabularInput))) + sum(~isTabularInput);

groupVars    = cell(1, nGrpVars);
outVarIdx    = cell(size(userInput));
tOutTemplate = cell(size(userInput));

% Extract grouping variables from userInput
groupVarIdx = 0; % loop invariant: number of grouping variable already extracted
for i = 1:length(userInput)
    if isTabularInput(i)
        t = userInput{i};
        if istimetable(t), t = timetable2table(t,'ConvertRowTimes',false); end
        varIndices = groupVarIdx + (1:width(t));
        groupVars(varIndices) = struct2cell(getVars(t))';
        tOutTemplate{i} = t([],:);
        tOutTemplate{i}.Properties.RowNames = {}; % clear rowNames for use as output template
    else
        varIndices = groupVarIdx + 1;
        groupVars(varIndices) = userInput(i);
    end
    
    outVarIdx{i} = varIndices;
    
    % Update loop invariant: number of grouping variable already extracted
    groupVarIdx = groupVarIdx + length(outVarIdx{i});
end

if isempty(groupVars)
    throwAsCaller(MException(message('MATLAB:findgroups:GroupingVarNotVector')));
end

end
%-------------------------------------------------------------------------------
function [gidx,glevels] = localgrp2idx(var)
% LOCALGRP2IDX  Create index vector from a grouping variable.
%   [GIDX, GLEVELS] = LOCALGRP2IDX(VAR) creates an index vector GIDX from
%   the grouping variable VAR. VAR can be a categorical, numeric, logical,
%   datetime, duration, or string vector, or a cell array of character
%   vectors. GIDX is a vector of integer values from 1 up to the number K
%   of distinct groups. GLEVELS contains the K distinct values in VAR.
%
%   LOCALGRP2IDX treats NaNs (numeric or logical), empty text (string or
%   cell array of character vectors), <missing> values (string), or
%   <undefined> values (categorical) in S as missing values and returns
%   NaNs in the corresponding rows of GIDX.
%   GLEVELS does not include entries for missing values.

if ischar(var) && ismatrix(var)
    throwAsCaller(MException(message('MATLAB:findgroups:CharData')));
elseif ~isvector(var)
    throwAsCaller(MException(message('MATLAB:findgroups:GroupingVarNotVector')));
end

varIsRow = isrow(var);

if isa(var,'categorical')
    [glevels,~,gidx] = unique(var(:));
    if ~isempty(glevels) && isundefined(glevels(end)) % undefineds are sorted to end
        notNaN = ~isundefined(glevels);
        glevels = glevels(notNaN,1);
        gidx(gidx > length(glevels)) = NaN; % other indices stay the same
    end
else
    try
        [glevels,~,gidx] = unique(var(:),'sorted');
    catch ME
        if ~( isnumeric(var) || islogical(var) || isduration(var) || iscalendarduration(var) || isdatetime(var) || iscellstr(var) )
            throwAsCaller(MException(message('MATLAB:findgroups:GroupTypeIncorrect',class(var))));
        else
            throwAsCaller(addCause(MException(message('MATLAB:findgroups:VarUniqueMethodFailed')), ME));
        end
    end
    if numel(gidx) ~= numel(var) % var should be a vector at this point
        throwAsCaller(MException(message('MATLAB:findgroups:VarUniqueMethodFailedNumRows')));
    end
    
    if isnumeric(var) || islogical(var) || isduration(var) || iscalendarduration(var) || isdatetime(var) || isstring(var)
        % Handle missing values: return NaN group indices
        if ~isempty(glevels) && ismissing(glevels(end)) % missing values are sorted to end
            glevels = glevels(~ismissing(glevels),1);
            gidx(gidx > length(glevels)) = NaN; % other indices stay the same
        end
    elseif iscell(var)% iscellstr enforced by unique above
        % Handle empty character vector missing values: return NaN group indices
        if ~isempty(glevels) && isempty(glevels{1}) % empty character vectors are sorted to beginning
            notNaN = ~cellfun('isempty',glevels);
            % All empties are treated as '', but defensively find the number of empty character vectors
            nEmpty = length(glevels) - sum(notNaN);
            glevels = glevels(notNaN,1);
            adjustIdx = [NaN(1,nEmpty) 1:length(glevels)]';
            gidx = adjustIdx(gidx);
        end
    else
        throwAsCaller(MException(message('MATLAB:findgroups:GroupTypeIncorrect',class(var))));
    end
end

if varIsRow
    gidx = gidx';
    glevels = glevels';
end

end