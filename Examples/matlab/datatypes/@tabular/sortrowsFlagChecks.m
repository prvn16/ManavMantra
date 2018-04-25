function [vars,varData,sortMode,sortModeStrs,varargin] = ...
    sortrowsFlagChecks(doIssortedrows,a,vars,sortMode,varargin)
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%

% Parse optional input arguments in tabular sortrows and issortedrows.

%   Copyright 2016-2017 The MathWorks, Inc.

% Parse the VARS
sortSigns = [];
if nargin < 3 % default is sort by all data vars, do not treat [] as "default behavior"
    vars = 1:a.varDim.length;
    varData = a.data;
else
    if isnumeric(vars)
        sortSigns = sign(vars);
        vars = abs(vars);
        % These still need to be validated
    end
    try
        % The reserved name 'RowLabels' is a compatibility special case only for tables.
        if isequal(vars,'RowNames') && isa(a,'table')
            vars = 0;
        else
            vars = a.getVarOrRowLabelIndices(vars,true); % allow empty row labels
        end
        varData = a.getVarOrRowLabelData(vars,msgidHelper(doIssortedrows,'EmptyRowNames'));
    catch ME
        if strcmp(ME.identifier,'MATLAB:badsubscript')
            % Non-numeric var subscripts are converted to valid numeric indices, so an
            % error here is from a numeric index that was bad to begin with. sortrows
            % needs a specific error because negative indices are actually valid.
            m = message(msgidHelper(doIssortedrows,'BadNumericVarIndices'));
            ME = MException(m.Identifier,'%s',getString(m));
        end
        throwAsCaller(ME);
    end
end

% Parse the DIRECTION / MODE
if doIssortedrows
    sortModeStrs = {'ascend','descend','monotonic', ...
                    'strictascend','strictdescend','strictmonotonic'};
else
    sortModeStrs = {'ascend','descend'};
end
if nargin < 4
    %   SORTROWS(T/TT,VARS)
    sortMode = [];
else
    if rem(numel(varargin),2) == 0
        %   SORTROWS(T/TT,VARS,DIRECTION)
        %   SORTROWS(T/TT,VARS,DIRECTION,N1,V1,N2,V2,...)
        if isempty(sortMode) && ...
           (ischar(sortMode) || iscellstr(sortMode) || isa(sortMode,'double'))
            % Empty direction allowed because of legacy sortrows behavior
        else
            if ischar(sortMode)
                sortMode = cellstr(sortMode);
            elseif ~iscellstr(sortMode)
                error(message(msgidHelper(doIssortedrows,'UnrecognizedMode')));
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
                    if doIssortedrows % additional issorted directions
                        if strncmpi(charFlag,'monotonic',numel(charFlag))
                            sortMode(ii) = 3;
                        elseif strncmpi(charFlag,'strictascend',max(7,numel(charFlag)))
                            sortMode(ii) = 4;
                        elseif strncmpi(charFlag,'strictdescend',max(7,numel(charFlag)))
                            sortMode(ii) = 5;
                        elseif strncmpi(charFlag,'strictmonotonic',max(7,numel(charFlag)))
                            sortMode(ii) = 6;
                        end
                    end
                end
            end
            if ~all(sortMode)
                error(message(msgidHelper(doIssortedrows,'UnrecognizedMode')));
            elseif isscalar(sortMode)
                sortMode = repmat(sortMode,size(vars));
            elseif length(sortMode) ~= length(vars)
                error(message(msgidHelper(doIssortedrows,'WrongLengthMode')));
            end
        end
    else
        %   SORTROWS(T/TT,VARS,N1,V1,N2,V2,...)
        varargin = [sortMode varargin];
        sortMode = [];
    end
end

if isempty(sortMode)
    %   SORTROWS(T/TT,VARS,N1,V1,...)
    %   SORTROWS(T/TT,VARS,[],N1,V1,...)
    if isempty(sortSigns)
        sortMode = ones(size(vars));
    else
        sortMode = 1 + (sortSigns == -1); % 1 or 2
    end
end

%--------------------------------------------------------------------------
function mid = msgidHelper(doIssortedrows,errid)
if doIssortedrows
    mid = ['MATLAB:table:issortedrows:' errid];
else
    mid = ['MATLAB:table:sortrows:' errid];
end