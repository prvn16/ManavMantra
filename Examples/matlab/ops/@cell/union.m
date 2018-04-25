function varargout = union(varargin)
%UNION  Set union.
%   C = UNION(A,B) for vectors A and B, returns the combined values of the 
%   two vectors with no repetitions. C will be sorted.
%  
%   C = UNION(A,B,'rows') for matrices A and B with the same number of
%   columns, returns the combined rows from the two matrices with no 
%   repetitions. The rows of the matrix C will be in sorted order.
% 
%   [C,IA,IB] = UNION(A,B) also returns index vectors IA and IB such
%   that C is a sorted combination of the values A(IA) and B(IB).
%   If there are common values in A and B, then the index is returned in IB.
%   If there are repeated values in A or B, then the index of the first
%   occurrence of each repeated value is returned.  
%  
%   [C,IA,IB] = UNION(A,B,'rows') also returns index vectors IA and IB 
%   such that C is the sorted combination of the rows A(IA,:) and B(IB,:).
% 
%   [C,IA,IB] = UNION(A,B,'stable') for arrays A and B, returns the values
%   of C in the same order that they appear in A, then B.
%   [C,IA,IB] = UNION(A,B,'sorted') returns the values of C in sorted order.
%   If A and B are row vectors, then C will be a row vector as well,
%   otherwise C will be a column vector. IA and IB are column vectors.
%   If there are common values in A and B, then the index is returned in
%   IA. If there are repeated values in A or B, then the index of the
%   first occurrence of each repeated value is returned.
% 
%   [C,IA,IB] = UNION(A,B,'rows','stable') returns the rows of C in the
%   same order that they appear in A, then B.
%   [C,IA,IB] = UNION(A,B,'rows','sorted') returns the rows of C in sorted
%   order.
% 
%   The behavior of UNION has changed.  This includes:
%     -	occurrence of indices in IA and IB switched from last to first
%     -	orientation of vector C
%     -	IA and IB will always be column index vectors
%     -	tighter restrictions on combinations of classes
% 
%   If this change in behavior has adversely affected your code, you may 
%   preserve the previous behavior with:
% 
%      [C,IA,IB] = UNION(A,B,'legacy')
%      [C,IA,IB] = UNION(A,B,'rows','legacy')
%
%   Examples:
%
%      a = [9 9 9 9 9 9 8 8 8 8 7 7 7 6 6 6 5 5 4 2 1]
%      b = [1 1 1 3 3 3 3 3 4 4 4 4 4 10 10 10]
%
%      [c1,ia1,ib1] = union(a,b)
%      % returns
%      c1 = [1 2 3 4 5 6 7 8 9 10]
%      ia1 = [21 20 19 17 14 11 7 1]'
%      ib1 = [4 14]'
%
%      [c2,ia2,ib2] = union(a,b,'stable')
%      % returns
%      c2 = [9 8 7 6 5 4 2 1 3 10]
%      ia2 = [1 7 11 14 17 19 20 21]'
%      ib2 = [4 14]'
%
%      c = union([1 NaN],[NaN 2])
%      % NaNs compare as not equal, so this returns
%      c = [1 2 NaN NaN]
%
%   Class support for inputs A and B, where A and B must be of the same
%   class unless stated otherwise:
%      - logical, char, all numeric classes (may combine with double arrays)
%      - cell arrays of strings (may combine with char arrays)
%      -- 'rows' option is not supported for cell arrays
%      - objects with methods SORT (SORTROWS for the 'rows' option) and NE
%      -- including heterogeneous arrays derived from the same root class
%
%   See also UNIQUE, INTERSECT, SETDIFF, SETXOR, ISMEMBER, SORT, SORTROWS.

%   Copyright 1984-2017 The MathWorks, Inc.

% Determine the number of outputs requested.
if nargout == 0
    nlhs = 1;
else
    nlhs = nargout;
end

narginchk(2,4);
nrhs = nargin;
if nrhs == 2
    [varargout{1:nlhs}] = cellunionR2012a(varargin{:});
else
    % acceptable combinations, with optional inputs denoted in []
    % union(A,B, ['rows'], ['legacy'/'R2012a']),
    % union(A,B, ['rows'], ['sorted'/'stable']),
    % where the position of 'rows' and 'sorted'/'stable' may be reversed
    nflagvals = 5;
    flagvals = ["rows" "sorted" "stable" "legacy" "R2012a"];
    % When a flag is found, note the index into varargin where it was found
    flaginds = zeros(1,nflagvals);
    for i = 3:nrhs
        flag = varargin{i};
        foundflag = matlab.internal.math.partialMatchString(flag,flagvals);
        if ~any(foundflag)
            if ischar(flag)
                error(message('MATLAB:UNION:UnknownFlag',flag));
            else
                error(message('MATLAB:UNION:UnknownInput'));
            end
        end
        % Only 1 occurrence of each allowed flag value
        if flaginds(foundflag)
            error(message('MATLAB:UNION:RepeatedFlag',flag));
        end
        flaginds(foundflag) = i;
    end
    
    % Only 1 of each of the paired flags
    if flaginds(2) && flaginds(3)
        error(message('MATLAB:UNION:SetOrderConflict'))
    end
    if flaginds(4) && flaginds(5)
        error(message('MATLAB:UNION:BehaviorConflict'))
    end
    % 'legacy' and 'R2012a' flags must be trailing
    if flaginds(4) && flaginds(4)~=nrhs
        error(message('MATLAB:UNION:LegacyTrailing'))
    end
    if flaginds(5) && flaginds(5)~=nrhs
        error(message('MATLAB:UNION:R2012aTrailing'))
    end
    
    if flaginds(2) || flaginds(3) % 'stable'/'sorted' specified
        if flaginds(4) || flaginds(5) % does not combine with 'legacy'/'R2012a'
            error(message('MATLAB:UNION:SetOrderBehavior'))
        end
        [varargout{1:nlhs}] = cellunionR2012a(varargin{1:2},logical(flaginds(1:3)));
    elseif flaginds(5) % trailing 'R2012a' specified
        [varargout{1:nlhs}] = cellunionR2012a(varargin{1:2},logical(flaginds(1:3)));
    elseif flaginds(4) % trailing 'legacy' specified
        [varargout{1:nlhs}] = cellunionlegacy(varargin{1:2},logical(flaginds(1)));
    else % 'R2012a' (default behavior)
        [varargout{1:nlhs}] = cellunionR2012a(varargin{1:2},logical(flaginds(1:3)));
    end
end
end

function [c,ia,ib] = cellunionlegacy(a,b,isrows)
% 'legacy' flag implementation

if nargin == 3 && isrows
    warning(message('MATLAB:UNION:RowsFlagIgnored')); 
end

if ischar(a)
    if isrow(a)
        a = {a};  %refrain from using cellstr to preserve trailing spaces
    else
        a = cellstr(a);
    end
end
if ischar(b)
    if isrow(b)
        b = {b};  %refrain from using cellstr to preserve trailing spaces
    else
        b = cellstr(b);
    end
end

ambiguous = ((size(a,1)==0 && size(a,2)==0) || length(a)==1) && ...
            ((size(b,1)==0 && size(b,2)==0) || length(b)==1);

isrowab = ~((size(a,1)>1 && size(b,2)<=1) || (size(b,1)>1 && size(a,2)<=1));
a = a(:); b = b(:);

% Only return required arguments from UNIQUE.
if nargout > 1
    [c,ndx] = unique([a;b],'legacy');    
else
    c = unique([a;b],'legacy');
    ndx = [];
end
if (isempty(c) && ambiguous)
  c = reshape(c,0,0);
  ia = [];
  ib = [];
elseif isrowab
  c = c'; ndx = ndx';
end

if nargout > 1 % Create index vectors.
  n = length(a);
  d = ndx > n;
  ia = ndx(~d);
  ib = ndx(d)-n;
end
end

function [c,ia,ib] = cellunionR2012a(a,b,options)
% 'R2012a' flag implementation

% flagvals = {'rows' 'sorted' 'stable'};
if nargin == 2
    order = 'sorted';
else
    if (options(1) > 0)
        warning(message('MATLAB:UNION:RowsFlagIgnored'));
    end
    if options(3) > 0
        order = 'stable';
    else % if options(2) > 0 || sum(options(2:3)) == 0)
        order = 'sorted';
    end
end

% Double empties are accepted and converted to empty cellstrs to maintain
% current behavior.
if isequal(class(a),'double') && isequal(a,zeros(0,0))
    a = {};
end
if isequal(class(b),'double') && isequal(b,zeros(0,0))
    b = {};
end

% Only non-homogeneous A and B allowed are char and cellstr.  If A or B is
% char, convert it to a cellstr.
if ischar(a)
    if isrow(a)
        a = {a};  %refrain from using cellstr to preserve trailing spaces
    else
        a = cellstr(a);
    end
end
if ischar(b)
    if isrow(b)
        b = {b};  %refrain from using cellstr to preserve trailing spaces
    else
        b = cellstr(b);
    end
end

% Make sure that A and B are cellstrs and not cell arrays that are not
% cellstrs.
if ~iscellstr(a) || ~iscellstr(b)
    error(message('MATLAB:UNION:InputClass',class(a),class(b)));
end

% Determine if A and B are both row vectors.
rowvec = isrow(a) && isrow(b);

% Convert to columns.
a = a(:);
b = b(:);

% Call UNIQUE to do all the work.
if nargout <= 1
    c = unique([a;b],order);
else
    [c,indUAB] = unique([a;b],order);
    % Indices determine whether an element was in A or in B.
    lenA = length(a);
    indB = indUAB > lenA;
    ia = indUAB(~indB);
    if indB == false
        ib = zeros(0,1);
    else
        ib = indUAB(indB)-lenA;
    end
end

% If A and B are both row vectors, return c as row vector.
if rowvec
    c = c.';
end
end
