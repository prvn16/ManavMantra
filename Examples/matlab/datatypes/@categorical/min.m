function [c,i] = min(a,b,varargin)
%MIN Smallest element in an ordinal categorical array.
%   B = MIN(A), when A is an ordinal categorical vector, returns the smallest
%   element in A. For matrices, MIN(A) is a row vector containing the minimum
%   element from each column.  For N-D arrays, MIN(A) operates along the first
%   non-singleton dimension.  B is an ordinal categorical array with the same
%   categories as A.
%
%   [B,I] = MIN(A) returns the indices of the minimum values in vector I. If
%   the values along the first non-singleton dimension contain more than one
%   minimal element, the index of the first one is returned.
%
%   C = MIN(A,B) returns an ordinal categorical array the same size as A
%   and B with the smallest elements taken from A or B.  A and B must have
%   the same sets of categories, including their order.  Either A or B may
%   also be a string scalar or a character vector.
%
%   [B,I] = MIN(A,[],DIM) operates along the dimension DIM. 
%   
%   MIN(..., UNDEFINEDFLAG) specifies how undefined elements are treated.
%      'omitundefined' - Ignores all undefined elements and returns the minimum
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
%      % Find the minimum of an ordinal categorical vector.
%      c = categorical([1 2 2 4 3],1:4,{'a' 'b' 'c' 'd'},'Ordinal',true)
%      cmin = min(c)
%
%      % Find the elementwise minimum between two ordinal categorical vectors,
%      % first by omitting undefined elements, then including them.
%      c1 = categorical([1   2 3 NaN],1:4,{'a' 'b' 'c' 'd'},'Ordinal',true)
%      c2 = categorical([4 NaN 2   1],1:4,{'a' 'b' 'c' 'd'},'Ordinal',true)
%      cminOmit = min(c1,c2)
%      cminInclude = min(c1,c2,'includeundefined')
%
%   See also MIN, SORT.

%   Copyright 2006-2017 The MathWorks, Inc.

if nargin > 2
    [omitUndefined,varargin{end}] = validateMissingOption(varargin{end});
else
    omitUndefined = true;
end

% Unary max
if nargin < 2 ... % min(a)
        || (nargin > 2 && isnumeric(b) && isequal(b,[])) % min(a,[],...) but not min(a,[])
    if ~a.isOrdinal
        error(message('MATLAB:categorical:NotOrdinal'));
    end
    
    acodes = a.codes;
    c = a;
    
    % Undefined elements have code zero, less than any legal code. They will always
    % be the min value, which is the correct behavior for 'includeundefined'. For
    % 'omitundefined', set the code value for undefined elements to the largest
    % integer to make sure they will be not the min value unless there's nothing
    % else.
    if omitUndefined
        tmpCode = invalidCode(acodes);
        acodes(acodes==categorical.undefCode) = tmpCode;
    end
    
    try
        if nargin < 2
            if nargout <= 1
                ccodes = min(acodes);
            else
                [ccodes,i] = min(acodes);
            end
        else % nargin > 2
            if nargout <= 1
                ccodes = min(acodes,[],varargin{:});
            else
                [ccodes,i] = min(acodes,[],varargin{:});
            end
        end
    catch ME
        throw(ME);
    end
    
% Binary max
else % min(a,b) or min(a,b,...)
    % Accept Inf as a valid "identity element" in the two-arg case. If compared
    % to <undefined> with 'omitundefined', the maximal value will be the result as
    % long as there is at least one category. If compared with 'includeundefined',
    % <undefined> will be the result.
    if isnumeric(a) && isequal(a,Inf) % && isa(b,'categorical')
        bcodes = b.codes;
        acodes = cast(length(b.categoryNames),'like',bcodes); % maximal value, or <undefined>
        c = b; % preserve subclass
    elseif isnumeric(b) && isequal(b,Inf) % && isa(a,'categorical')
        acodes = a.codes;
        bcodes = cast(length(a.categoryNames),'like',acodes); % maximal value, or <undefined>
        c = a; % preserve subclass
    else
        [acodes,bcodes,c] = reconcileCategories(a,b,true); % require ordinal
    end
    
    % Undefined elements have code zero, less than any legal code. They will always
    % be the min value, which is the correct behavior for 'includeundefined'. For
    % 'omitnan', set the code value for undefined elements to the largest integer to
    % make sure they will be not the min value unless there's nothing else.
    if omitUndefined
        tmpCode = invalidCode(acodes); % acodes is always correct type by now
        acodes(acodes==categorical.undefCode) = tmpCode;
        bcodes(bcodes==categorical.undefCode) = tmpCode;
    end
    try
        if nargout <= 1
            ccodes = min(acodes,bcodes,varargin{:});
        else
            [ccodes,i] = min(acodes,bcodes,varargin{:});
        end
    catch ME
        throw(ME);
    end
end

if omitUndefined
    ccodes(ccodes==tmpCode) = categorical.undefCode; % restore undefined code
end

% No need to call castCodes on c, because nothing has been upcast. That's
% because there's either one input, or the two inputs have the exact same
% categories (they're both ordinal), and therefore same codes class.
c.codes = ccodes;
