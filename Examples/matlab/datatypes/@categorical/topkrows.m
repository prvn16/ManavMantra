function [b,i] = topkrows(a,k,varargin)
%TOPKROWS Top K sorted rows of categorical array.
%   B = TOPKROWS(A,K) returns the top K rows of A sorted in 
%   descending order as a group. A must be a 2-D categorical array.
%
%   B = TOPKROWS(A,K,COL) sorts the top K rows according to the columns
%   specified by the vector COL.
%
%   B = TOPKROWS(...,DIRECTION) also specifies the sort direction(s).
%   DIRECTION can be:
%       'descend' - (default) Sorts in descending order.
%        'ascend' - Sorts in ascending order.
%
%   Use a different sorting direction for each column by specifying
%   DIRECTION as a cell array. For example, TOPKROWS(A,2,[2 3],{'ascend'
%   'descend'}) gets the top 2 rows by first sorting rows in ascending
%   order according to column 2; then, rows with equal entries in column 2
%   get sorted in descending order according to column 3.
%
%   [B,I] = TOPKROWS(...) also returns an index vector I that describes the
%   order of the K selected rows such that B = A(I,:).
%
%   See also SORTROWS, MAXK, MINK.

%   Copyright 2017 The MathWorks, Inc. 

for ii = 1:(nargin-2) % ComparisonMethod not supported.
    if matlab.internal.math.checkInputName(varargin{ii},{'ComparisonMethod'})
        error(message('MATLAB:topkrows:InvalidAbsRealType'));
    end
end

acodes = a.codes;
bcodes = acodes;

for ii = 1:(nargin-2) % Check if <undefined> codes need to be adjusted
    if (iscellstr(varargin{ii}) || matlab.internal.math.checkInputName(varargin{ii},{'ascend'}))
        % Use sortrows internal parser to find which columns are 
        % ascend/descend for NaN flags
        col = matlab.internal.math.sortrowsParseInputs(acodes,varargin{:});
        
        % Need extra check on col for repeated columns to place NaNs 
        % according to first occurence only 
        [~,ia] = unique(abs(col));
        col = col(ia);
        
        % Apply NaN mask to undefCode or 0
        undefmask = (acodes == categorical.undefCode);
        undefmask(:,abs(col(col < 0))) = 0;
        acodes(undefmask) = invalidCode(acodes); % Set invalidCode
    end
end

[~,i] = topkrows(acodes,k,varargin{:});

b = a; % preserve subclass
b.codes = bcodes(i,:);
