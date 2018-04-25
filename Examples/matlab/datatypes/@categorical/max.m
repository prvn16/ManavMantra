function [c,i] = max(a,b,varargin)
%MAX Largest element in an ordinal categorical array.
%   B = MAX(A), when A is an ordinal categorical vector, returns the largest
%   element in A. For matrices, MAX(A) is a row vector containing the maximum
%   element from each column.  For N-D arrays, MAX(A) operates along the first
%   non-singleton dimension.  B is an ordinal categorical array with the same
%   categories as A.
%
%   [B,I] = MAX(A) returns the indices of the maximum values in vector I.
%   If the values along the first non-singleton dimension contain more
%   than one maximal element, the index of the first one is returned.
%
%   C = MAX(A,B) returns an ordinal categorical array the same size as A
%   and B with the largest elements taken from A or B.  A and B must have
%   the same sets of categories, including their order.  Either A or B may
%   also be a string scalar or a character vector.
%
%   [B,I] = MAX(A,[],DIM) operates along the dimension DIM. 
%   
%   MAX(..., UNDEFINEDFLAG) specifies how undefined elements are treated.
%      'omitundefined' - Ignores all undefined elements and returns the maximum
%                        of the remaining elements. If all elements are undefined,
%                        then the first one is returned. 'omitnan' is equivalent
%                        to 'omitundefined'.
%      'includeundefined' - Returns an undefined element if there are any undefined
%                        elements. The index points to the first NaT element.
%                        'includenan' is equivalent to 'includeundefined'.
%   Default is 'omitundefined'.
%   
%   Examples:
%      
%      % Find the maximum of an ordinal categorical vector.
%      c = categorical([1 2 2 4 3],1:4,{'a' 'b' 'c' 'd'},'Ordinal',true)
%      cmax = max(c)
%
%      % Find the elementwise maximum between two ordinal categorical vectors,
%      % first by omitting undefined elements, then including them.
%      c1 = categorical([1   2 3 NaN],1:4,{'a' 'b' 'c' 'd'},'Ordinal',true)
%      c2 = categorical([4 NaN 2   1],1:4,{'a' 'b' 'c' 'd'},'Ordinal',true)
%      cmaxOmit = max(c1,c2)
%      cmaxInclude = max(c1,c2,'includeundefined')
%
%   See also MIN, SORT.

%   Copyright 2006-2017 The MathWorks, Inc.

if nargin > 2
    [omitUndefined,varargin{end}] = validateMissingOption(varargin{end});
else
    omitUndefined = true;
end

% Unary max
if nargin < 2 ... % max(a)
        || (nargin > 2 && isnumeric(b) && isequal(b,[])) % max(a,[],...) but not max(a,[])
    if ~a.isOrdinal
        error(message('MATLAB:categorical:NotOrdinal'));
    end
    
    acodes = a.codes;
    c = a;
    
    % Undefined elements have code zero, less than any legal code. They will not be
    % the max value unless there's nothing else, which is the correct behavior for
    % 'omitundefined'. For 'includeundefined', set the code value for undefined
    % elements to the largest integer to make sure they will be the max value.
    if ~omitUndefined
        tmpCode = invalidCode(acodes);
        acodes(acodes==categorical.undefCode) = tmpCode;
    end
    
    try
        if nargin < 2
            if nargout <= 1
                ccodes = max(acodes);
            else
                [ccodes,i] = max(acodes);
            end
        else % nargin > 2
            if nargout <= 1
                ccodes = max(acodes,[],varargin{:});
            else
                [ccodes,i] = max(acodes,[],varargin{:});
            end
        end
    catch ME
        throw(ME);
    end
    
% Binary max
else % max(a,b) or max(a,b,...)
    % Accept -Inf as a valid "identity element" in the two-arg case. If compared
    % to <undefined> with 'omitundefined', the minimal value will be the result as
    % long as there is at least one category. If compared with 'includeundefined',
    % <undefined> will be the result.
    if isnumeric(a) && isequal(a,-Inf) % && isa(b,'categorical')
        bcodes = b.codes;
        acodes = cast(~isempty(b.categoryNames),'like',bcodes); % minimal value, or <undefined>
        c = b; % preserve subclass
    elseif isnumeric(b) && isequal(b,-Inf) % && isa(a,'categorical')
        acodes = a.codes;
        bcodes = cast(~isempty(a.categoryNames),'like',acodes); % minimal value, or <undefined>
        c = a; % preserve subclass
    else
        [acodes,bcodes,c] = reconcileCategories(a,b,true); % require ordinal
    end
    
    % Undefined elements have code zero, less than any legal code. They will not be
    % the max value unless there's nothing else, which is the correct behavior for
    % 'omitnan'. For 'includenan', set the code value for undefined elements to the
    % largest integer to make sure they will be the max value when present.
    if ~omitUndefined
        tmpCode = invalidCode(acodes); % acodes is always correct type by now
        acodes(acodes==categorical.undefCode) = tmpCode;
        bcodes(bcodes==categorical.undefCode) = tmpCode;
    end
    try
        if nargout <= 1
            ccodes = max(acodes,bcodes,varargin{:});
        else
            [ccodes,i] = max(acodes,bcodes,varargin{:});
        end
    catch ME
        throw(ME);
    end
end

if ~omitUndefined
    ccodes(ccodes==tmpCode) = categorical.undefCode; % restore undefined code
end

% No need to call castCodes on c, because nothing has been upcast. That's
% because there's either one input, or the two inputs have the exact same
% categories (they're both ordinal), and therefore same codes class.
c.codes = ccodes;
