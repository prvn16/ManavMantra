function varargout = setxor(varargin)
%SETXOR Set exclusive-or.
%   C = SETXOR(A,B) for vectors A and B, returns the values that are not 
%   in the intersection of A and B with no repetitions. C will be sorted. 
%
%   C = SETXOR(A,B,'rows') for matrices A and B with the same number of 
%   columns, returns the rows that are not in the intersection of A and B.
%   The rows of the matrix C will be in sorted order.
%
%   [C,IA,IB] = SETXOR(A,B) also returns index vectors IA and IB such that 
%   C is a sorted combination of the values A(IA) and B(IB). If there 
%   are repeated values that are not in the intersection in A or B then the
%   index of the first occurrence of each repeated value is returned.
%
%   [C,IA,IB] = SETXOR(A,B,'rows') also returns index vectors IA and IB 
%   such that C is the sorted combination of rows A(IA,:) and B(IB,:).
%
%   [C,IA,IB] = SETXOR(A,B,'stable') for arrays A and B, returns the values
%   of C in the same order that they appear in A, then B.
%   [C,IA,IB] = SETXOR(A,B,'sorted') returns the values of C in sorted
%   order.
%   If A and B are row vectors, then C will be a row vector as well,
%   otherwise C will be a column vector. IA and IB are column vectors.
%   If there are repeated values that are not in the intersection of A and
%   B, then the index of the first occurrence of each repeated value is
%   returned.
%
%   [C,IA,IB] = SETXOR(A,B,'rows','stable') returns the rows of C in the
%   same order that they appear in A, then B.
%   [C,IA,IB] = SETXOR(A,B,'rows','sorted') returns the rows of C in sorted
%   order.
%
%   The behavior of SETXOR has changed.  This includes:
%     -	occurrence of indices in IA and IB switched from last to first
%     -	orientation of vector C
%     -	IA and IB will always be column index vectors
%     -	tighter restrictions on combinations of classes
% 
%   If this change in behavior has adversely affected your code, you may 
%   preserve the previous behavior with:
% 
%      [C,IA,IB] = SETXOR(A,B,'legacy')
%      [C,IA,IB] = SETXOR(A,B,'rows','legacy')
%
%   Examples:
%
%      a = [9 9 9 9 9 9 8 8 8 8 7 7 7 6 6 6 5 5 4 2 1]
%      b = [1 1 1 3 3 3 3 3 4 4 4 4 4 10 10 10]
%      [c1,ia1,ib1] = setxor(a,b)
%      % returns
%      c1 = [2 3 5 6 7 8 9 10], ia1 = [20 17 14 11 7 1]', ib1 = [4 14]'
%
%      [c2,ia2,ib2] = setxor(a,b,'stable')
%      % returns
%      c2 = [9 8 7 6 5 2 3 10], ia2 = [1 7 11 14 17 20]', ib2 = [4 14]'
%
%      c = setxor([1 NaN 2 3],[3 4 NaN 1])
%      % NaNs compare as not equal, so this returns
%      c = [2 4 NaN NaN]
%
%   Class support for inputs A and B, where A and B must be of the same
%   class unless stated otherwise:
%      - logical, char, all numeric classes (may combine with double arrays)
%      - cell arrays of strings (may combine with char arrays)
%      -- 'rows' option is not supported for cell arrays
%      - objects with methods SORT (SORTROWS for the 'rows' option), EQ and NE
%      -- including heterogeneous arrays derived from the same root class
%
%   See also UNIQUE, UNION, INTERSECT, SETDIFF, ISMEMBER, SORT, SORTROWS.

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
    [varargout{1:nlhs}] = cellsetxorR2012a(varargin{:});
else
    % acceptable combinations, with optional inputs denoted in []
    % setxor(A,B, ['rows'], ['legacy'/'R2012a']),
    % setxor(A,B, ['rows'], ['sorted'/'stable']),
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
                error(message('MATLAB:SETXOR:UnknownFlag',flag));
            else
                error(message('MATLAB:SETXOR:UnknownInput'));
            end
        end
        % Only 1 occurrence of each allowed flag value
        if flaginds(foundflag)
            error(message('MATLAB:SETXOR:RepeatedFlag',flag));
        end
        flaginds(foundflag) = i;
    end
    
    % Only 1 of each of the paired flags
    if flaginds(2) && flaginds(3)
        error(message('MATLAB:SETXOR:SetOrderConflict'))
    end
    if flaginds(4) && flaginds(5)
        error(message('MATLAB:SETXOR:BehaviorConflict'))
    end
    % 'legacy' and 'R2012a' flags must be trailing
    if flaginds(4) && flaginds(4)~=nrhs
        error(message('MATLAB:SETXOR:LegacyTrailing'))
    end
    if flaginds(5) && flaginds(5)~=nrhs
        error(message('MATLAB:SETXOR:R2012aTrailing'))
    end
    
    if flaginds(2) || flaginds(3) % 'stable'/'sorted' specified
        if flaginds(4) || flaginds(5) % does not combine with 'legacy'/'R2012a'
            error(message('MATLAB:SETXOR:SetOrderBehavior'))
        end
        [varargout{1:nlhs}] = cellsetxorR2012a(varargin{1:2},logical(flaginds(1:3)));
    elseif flaginds(5) % trailing 'R2012a' specified
        [varargout{1:nlhs}] = cellsetxorR2012a(varargin{1:2},logical(flaginds(1:3)));
    elseif flaginds(4) % trailing 'legacy' specified
        [varargout{1:nlhs}] = cellsetxorlegacy(varargin{1:2},logical(flaginds(1)));
    else % 'R2012a' (default behavior)
        [varargout{1:nlhs}] = cellsetxorR2012a(varargin{1:2},logical(flaginds(1:3)));
    end
end
end

function [c,ia,ib] = cellsetxorlegacy(a,b,isrows)
% 'legacy' flag implementation

% handle inputs
if nargin == 3 && isrows
    warning(message('MATLAB:SETXOR:RowsFlagIgnored')); 
end

if ~any([iscellstr(a),iscellstr(b),ischar(a),ischar(b)])
    error(message('MATLAB:SETXOR:InputClass',class(a),class(b)))
end

nOut = nargout;

ia = [];
ib = [];

if isempty(b) 
    [c, ia] = unique(a,'legacy');
    return
end

if isempty(a) 
    [c, ib] = unique(b,'legacy');
    return
end

ambiguous = ((size(a,1)==0 && size(a,2)==0) || length(a)==1) && ...
    ((size(b,1)==0 && size(b,2)==0) || length(b)==1);

% check and set flag if input is a row vector.
if ~iscell(a)
    if isrow(a)
        a = {a};  %refrain from using cellstr to preserve trailing spaces
    else
        a = cellstr(a);
    end
end

if ~iscell(b)
    if isrow(b)
        b = {b};  %refrain from using cellstr to preserve trailing spaces
    else
        b = cellstr(b);
    end
end

%Is input a non-column vector?
isrowa = ismatrix(a) && size(a,1)==1 && size(a,2) ~= 1;
%Is input a non-column vector?
isrowb = ismatrix(b) && size(b,1)==1 && size(b,2) ~= 1;

a = a(:);
b = b(:);

if nOut <= 1
    a = unique(a,'legacy');
    b = unique(b,'legacy');
else
    [a,ia] = unique(a,'legacy');
    [b,ib] = unique(b,'legacy');
end

if ispc && (length(b) == length(a)) && (~isempty(a)) && isequal(a{1},b{1})
	%Sort of two sorted copies of exactly the same array takes a long
	%time on Windows.  This is to work around that issue until we
	%have a quick merge function or rewrite sort for cell arrays.  The code
	%reshuffles the data.
	r = [1:3:length(a), 2:3:length(a), 3:3:length(a)];  
    a = a(r); 
	if nOut > 1
		ia = ia(r);
		ib = ib(r);
	end
    b = b(r); 
end

[c,ndx] = sort([a;b]);

d = ~strcmp(c(1:end-1),c(2:end));
d = [true ;d];
d(end + 1 , 1) = true;

d = ~(d(1:end-1) & d(2:end));

c(d) = [];

if nOut > 1
    n = size(a,1);
    ndx = ndx(~d);
    d = ndx <= n;
    ia = ia(ndx(d));
    ib = ib(ndx(~d) - n);
end

if isrowa || isrowb
    c = c';
    ia = ia';
    ib = ib';
end

if (isempty(c) && ambiguous)
    c = reshape(c,0,0);
    ia = [];
    ib = [];
end
end

function [c,ia,ib] = cellsetxorR2012a(a,b,options)
% 'R2012a' flag implementation

% flagvals = {'rows' 'sorted' 'stable'};
if nargin == 2
    order = 'sorted';
else
    if (options(1) > 0)
        warning(message('MATLAB:SETXOR:RowsFlagIgnored'));
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

if ~iscellstr(a) || ~iscellstr(b)
    error(message('MATLAB:SETXOR:InputClass',class(a),class(b)));
end

% Determine if A and B are both row vectors.
rowvec = isrow(a) && isrow(b);

a = a(:);
b = b(:);

% Make sure a and b contain unique elements.
if nargout <= 1
    uA = unique(a,order);
    uB = unique(b,order);
else
    [uA,ia] = unique(a,order);
    [uB,ib] = unique(b,order);
end

% Sort [uA;uB] in order to find matching entries
catuAuB = [uA;uB];                              
[sortuAuB,indSortuAuB] = sort(catuAuB);

% d indicates the location of matching entries
d = find(strcmp(sortuAuB(1:end-1),sortuAuB(2:end)));   

% Remove all matching entries
indSortuAuB([d;d+1]) = [];        

if strcmp(order, 'stable') % 'stable'
    indSortuAuB = sort(indSortuAuB);    % Sort the indices to get 'stable' order
end

% Find C
c = catuAuB(indSortuAuB);           

% Find indices if needed
if nargout > 1
    lenUA = length(uA);
    d = indSortuAuB <= lenUA;       % Find indices in indSortuAuB that belong to A
    if d == 0                       % Force d to be correct shape if none of the elements
        d = zeros(0,1);             % in A are in C.
    end
    ia = ia(indSortuAuB(d));
    if nargout > 2
        d = indSortuAuB > lenUA;    % Find indices in indSortuAuB that belong to B
        if d == 0;                  % Force d to be correct shape if none of the elements
            d = zeros(0,1);         % in B are in C
        end
        ib = ib(indSortuAuB(d)-lenUA);
    end
end

% If A and B are row vectors, return C as row vector.
if rowvec
    c = c';
end
end

