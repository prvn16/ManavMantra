function [tf,failInfo] = issortedrowsFrontToBack(A,dirCodes,dirStrs,varargin)
% ISSORTEDFRONTTOBACK   Front-to-Back issortedrows algorithm
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%

%   Front-to-Back issortedrows algorithm:
%   Check if a matrix (or tabular) is sorted by rows by starting with the
%   first column (or variable). Move to the next column (or variable) if we
%   need to break any ties.
%
%   Inputs:
%   (1) For tabular usage (nargout == 2):
%       A     - 1-by-numCols cell containing the underlying tabular data.
%               Each cell must contain a column vector.
%
%   (2) For matrix usage (nargout == 1):
%       A     - numRows-by-numCols matrix.
%
%   dirCodes  - 1 for 'ascend'
%             - 2 for 'descend'
%             - 3 for 'monotonic'
%             - 4 for 'strictascend'
%             - 5 for 'strictdescend'
%             - 6 for 'strictmonotonic'
%   dirStrs   - {'ascend' 'descend' 'monotonic' ...
%                'strictascend' 'strictdescend' 'strictmonotonic'}
%   varargin can contain:
%       'MissingPlacement','auto'/'first'/'last' and/or
%       'ComparisonMethod','auto'/'abs'/'real'.

%   Copyright 2016-2017 The MathWorks, Inc.

tf = true;
if nargout < 2
    % Matrix (2-array) usage:
    isTabularCaller = false;
    getColFcn = @(A,jj) A(:,jj); % get matrix column
else
    % Tabular usage:
    isTabularCaller = true;
    failInfo = struct.empty();
    getColFcn = @(A,jj) A{jj}; % get entry in cell vector
end

% Return TRUE for empty inputs:
numCols = size(A,2);
if numCols == 0
    return
end
numRows = size(getColFcn(A,1),1);
if numRows == 0
    return
end

try
    if numCols <= 1
        % Simply call ISSORTED on only one column:
        jj = 1; % Spelled out for try-catch error purposes
        tf = issorted(getColFcn(A,jj),dirStrs{dirCodes(jj)},varargin{:});
    else
        
        % Use the groups found in the previous column (or tabular variable):
        if numRows > 1
            % Use 'ascend' for previous column ids because they are always
            % sorted -- they are the third output of a stable unique call:
            groupIdsPrevCol = zeros(numRows,1);
            dirPrevCol = 'ascend';
        else
            % Ensure 'strictascend' returns false for 1 row of missing data:
            groupIdsPrevCol = [];
            dirPrevCol = '';
        end
        
        for jj = 1:numCols
            
            % Call ISSORTED and/or SORT to get group ids for this column:
            groupIdsThisCol = getGroupIds(getColFcn(A,jj),varargin{:});
            
            % issortedrows builtin on a numRows-by-2 double matrix of group ids
            % formed from the groups found in the previous and current column
            % (varargin gives correct MissingPlacement behavior via NaN groups):
            tf = issortedrows([groupIdsPrevCol groupIdsThisCol],[dirPrevCol {dirStrs{dirCodes(jj)}}],varargin{:});
            
            if tf && (dirCodes(jj) < 4) && (jj < numCols)
                % Data is sorted in the non-strict sense (ascend/descend/monotonic),
                % BUT it could have ties. Find new groups and go to next column
                % (convert NaN ids to 0 to force unique 'rows' to treat NaNs as ties):
                groupIdsThisCol(isnan(groupIdsThisCol)) = 0;
                [~,~,groupIdsPrevCol] = unique([groupIdsPrevCol groupIdsThisCol],'rows','stable');
                
                % Stop if there are no ties to break:
                if max(groupIdsPrevCol) == numRows
                    return
                end
            else
                % Stop if not sorted at all
                %   OR
                % if the j-th sort direction is strictascend/strictdescend/strictmonotonic.
                return
            end
        end
    end
catch ME
    if isTabularCaller
        % Use failure info to throw a more helpful error message for tabular:
        failInfo = struct('ME',ME,'colNum',jj);
    else
        throw(ME);
    end
end

%--------------------------------------------------------------------------
function groupIdsWithNaN = getGroupIds(A,varargin)
% Returns similar output to third output of unique: [~,~,IC] = unique(A).
% But, takes into account name-value pairs provided to issortedrows.
% Hence, it produces the correct behavior when varargin contains
%   'MissingPlacement','auto'/'first'/'last' and/or
%   'ComparisonMethod','auto'/'abs'/'real'.
% A must be a column.

if issorted(A,varargin{:})
    indSortA = (1:numel(A))';
else
    [A,indSortA] = sort(A,varargin{:});
end

% Indices where a new group starts:
groupIdsWithNaN = [true; A(1:end-1) ~= A(2:end)];
% Treat missing (NaN) as ties, make sure all NaNs belong to a single group:
mA = find(ismissing(A));
groupIdsWithNaN(mA(2:end)) = false;

% Turn into group ids and permute to match initial input ordering:
groupIdsWithNaN = cumsum(groupIdsWithNaN);
% Use NaN ids for missing data to ensure correct MissingPlacement behavior:
groupIdsWithNaN(mA) = NaN;
groupIdsWithNaN(indSortA) = groupIdsWithNaN;