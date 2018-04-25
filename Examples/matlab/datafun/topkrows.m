function [B,I] = topkrows(A,k,varargin)
%TOPKROWS Top K sorted rows of matrix.
%   B = TOPKROWS(A,K) returns the top K rows of matrix A sorted in
%   descending order as a group.
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
%   B = TOPKROWS(...,'ComparisonMethod',C) specifies how to compare complex
%   numbers. The comparison method C can be:
%       'auto' - (default) Compares real numbers according to 'real', and
%                complex numbers according to 'abs'.
%       'real' - Compares according to REAL(A). Elements with equal real
%                parts are then sorted by IMAG(A).
%        'abs' - Compares according to ABS(A). Elements with equal
%                magnitudes are then sorted by ANGLE(A).
%
%   [B,I] = TOPKROWS(...) also returns an index vector I that describes the
%   order of the K selected rows such that B = A(I,:).
%
%   See also SORTROWS, MAXK, MINK.

%   Copyright 2017 The MathWorks, Inc.

% Check number of inputs
narginchk(2,Inf);

% Special cases for cellstr and string, otherwise call builtin
if isstring(A) || iscellstr(A)
    % check type of k
    if (~isnumeric(k) || ~isscalar(k) || (k ~= floor(k)) || (k < 0))
        error(message('MATLAB:topkrows:InvalidK'));
    end
    
    % adjust k if needed
    if k > size(A,1)
        k = size(A,1);
    end
    
    % ComparisonMethod not supported.
    for ii = 1:(nargin-2)
        if matlab.internal.math.checkInputName(varargin{ii},{'ComparisonMethod'})
            error(message('MATLAB:topkrows:InvalidAbsRealType'));
        end
    end
    
    % Check if direction and col are specified
    hascol = false;
    hasdir = false;
    
    % Check if first varargin is numeric
    if nargin > 2
        hascol = isnumeric(varargin{1});
    end
    
    % check for strings ascend, descend, or cell containing them
    for ii = 1:(nargin-2)
        if matlab.internal.math.checkInputName(varargin{ii},{'ascend'}) || matlab.internal.math.checkInputName(varargin{ii},{'descend'}) || iscell(varargin{ii})
            hasdir = true;
        end
    end
    
    if isstring(A)
        if hasdir
            % sortrows A
            if (nargout > 1)
                [AS,IS] = sortrows(A,varargin{:},'MissingPlacement','last');
            else
                AS = sortrows(A,varargin{:},'MissingPlacement','last');
            end
        else
            if hascol
                % sortrows A
                if (nargout > 1)
                    [AS,IS] = sortrows(A,varargin{1},'descend',varargin{2:end},'MissingPlacement','last');
                else
                    AS = sortrows(A,varargin{1},'descend',varargin{2:end},'MissingPlacement','last');
                end
            else
                % sortrows A
                if (nargout > 1)
                    [AS,IS] = sortrows(A,'descend',varargin{:},'MissingPlacement','last');
                else
                    AS = sortrows(A,'descend',varargin{:},'MissingPlacement','last');
                end
            end
        end
        
        % extract first k rows from all list
        B = AS(1:k,:);
        if (nargout > 1)
            I = IS(1:k,:);
        end
    else
        % Treating '' as empty character as opposed to missing.
        % this is same behavior as sortrows
        if hasdir
            % sortrows A
            [~,IS] = sortrows(string(A),varargin{:},'MissingPlacement','last');
        else
            if hascol
                % sortrows A
                [~,IS] = sortrows(string(A),varargin{1},'descend',varargin{2:end},'MissingPlacement','last');
            else
                % sortrows A
                [~,IS] = sortrows(string(A),'descend',varargin{:},'MissingPlacement','last');
            end
        end
        
        % extract first k rows from all list
        I = IS(1:k,:);
        B = A(I,:);
    end
    
else
    try
        % Call builtin for remaining types
        if nargout > 1
            [B,I] = builtin('_topkrows',A,k,varargin{:});
        else
            B = builtin('_topkrows',A,k,varargin{:});
        end
    catch ME
        throwAsCaller(ME);
    end
end