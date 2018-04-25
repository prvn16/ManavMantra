function [vars,varData,sortMode,labels,varargin] = ...
    topkrowsFlagChecks(a,vars,sortMode,varargin)
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%

% Parse optional input arguments in tabular topkrows.

%   Copyright 2017 The MathWorks, Inc.

% Parse the VARS
if nargin < 2 % default is sort by all data vars, do not treat [] as "default behavior"
    vars = 1:a.varDim.length;
    varData = a.data;
    labels = a.varDim.labels;
else
    try
        % The reserved name 'RowLabels' is a compatibility special case only for tables.
        if isequal(vars,'RowNames') && isa(a,'table')
            vars = 0;
        else
            vars = a.getVarOrRowLabelIndices(vars,true); % allow empty row labels
        end
        varData = a.getVarOrRowLabelData(vars,'MATLAB:table:topkrows:EmptyRowNames');
        if any(vars == 0)
            if isequal(vars,0) 
                labels = {a.metaDim.labels{1}};
            else
                labels{vars ~= 0} = a.varDim.labels{vars(vars ~= 0)};
                labels{vars == 0} = a.metaDim.labels{1};
            end
        else
            labels = a.varDim.labels(vars);
        end
    catch ME
        if strcmp(ME.identifier,'MATLAB:badsubscript')
            % Non-numeric var subscripts are converted to valid numeric indices, so an
            % error here is from a numeric index that was bad to begin with. sortrows
            % needs a specific error because negative indices are actually valid.
            m = message('MATLAB:table:topkrows:BadNumericVarIndices');
            ME = MException(m.Identifier,'%s',getString(m));
        end
        throwAsCaller(ME);
    end
end

% Parse the DIRECTION / MODE
if nargin < 3
    %   TOPKROWS(T/TT,K,VARS)
    sortMode = [];
else
    if rem(numel(varargin),2) == 0
        %   TOPKROWS(T/TT,K,VARS,DIRECTION)
        %   TOPKROWS(T/TT,K,VARS,DIRECTION,N1,V1,N2,V2,...)
        if isempty(sortMode) && ...
           (ischar(sortMode) || iscellstr(sortMode) || isa(sortMode,'double'))
            % Empty direction allowed because of legacy sortrows behavior
        else
            if ischar(sortMode)
                sortMode = cellstr(sortMode);
            elseif ~iscellstr(sortMode)
                error(message('MATLAB:table:topkrows:UnrecognizedMode'));
            end
            sortModeCell = sortMode;
            sortMode = zeros(numel(sortMode),1);
            for ii = 1:numel(sortMode)
                charFlag = sortModeCell{ii};
                if isrow(charFlag)
                    if strncmpi(charFlag,'ascend',numel(charFlag))
                        sortMode(ii) = 1;
                    elseif strncmpi(charFlag,'descend',numel(charFlag))
                        sortMode(ii) = 2;
                    end
                end
            end
            if ~all(sortMode)
                error(message('MATLAB:table:topkrows:UnrecognizedMode'));
            elseif isscalar(sortMode)
                sortMode = repmat(sortMode,size(vars));
            elseif length(sortMode) ~= length(vars)
                error(message('MATLAB:table:topkrows:WrongLengthMode'));
            end
        end
    else
        %   TOPKROWS(T/TT,K,VARS,N1,V1,N2,V2,...)
        varargin = [sortMode varargin];
        sortMode = [];
    end
end

if isempty(sortMode)
    %   TOPKROWS(T/TT,K,VARS,N1,V1,...)
    %   TOPKROWS(T/TT,K,VARS,[],N1,V1,...)
    sortMode = 2*ones(size(vars));
end