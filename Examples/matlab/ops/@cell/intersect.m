function varargout = intersect(varargin)
%INTERSECT Set intersection.
%   C = INTERSECT(A,B) for vectors A and B, returns the values common to 
%   the two vectors with no repetitions. C will be sorted.
%
%   C = INTERSECT(A,B,'rows') for matrices A and B with the same 
%   number of columns, returns the rows common to the two matrices. The
%   rows of the matrix C will be in sorted order.
%
%   [C,IA,IB] = INTERSECT(A,B) also returns index vectors IA and IB such 
%   that C = A(IA) and C = B(IB). If there are repeated common values in
%   A or B then the index of the first occurrence of each repeated value is
%   returned.
%
%   [C,IA,IB] = INTERSECT(A,B,'rows') also returns index vectors IA and IB 
%   such that C = A(IA,:) and C = B(IB,:). 
%
%   [C,IA,IB] = INTERSECT(A,B,'stable') for arrays A and B, returns the
%   values of C in the same order that they appear in A.
%   [C,IA,IB] = INTERSECT(A,B,'sorted') returns the values of C in sorted
%   order.
%   If A and B are row vectors, then C will be a row vector as well,
%   otherwise C will be a column vector. IA and IB are column vectors.
%   If there are repeated common values in A or B then the index of the
%   first occurrence of each repeated value is returned.
%
%   [C,IA,IB] = INTERSECT(A,B,'rows','stable') returns the rows of C in the
%   same order that they appear in A.
%   [C,IA,IB] = INTERSECT(A,B,'rows','sorted') returns the rows of C in
%   sorted order.
%
%   The behavior of INTERSECT has changed.  This includes:
%     -	occurrence of indices in IA and IB switched from last to first
%     -	orientation of vector C
%     -	IA and IB will always be column index vectors
%     -	tighter restrictions on combinations of classes
% 
%   If this change in behavior has adversely affected your code, you may 
%   preserve the previous behavior with:
% 
%      [C,IA,IB] = INTERSECT(A,B,'legacy')
%      [C,IA,IB] = INTERSECT(A,B,'rows','legacy')
%
%   Examples:
%
%      a = [9 9 9 9 9 9 8 8 8 8 7 7 7 6 6 6 5 5 4 2 1]
%      b = [1 1 1 3 3 3 3 3 4 4 4 4 4 10 10 10]
%
%      [c1,ia1,ib1] = intersect(a,b)
%      % returns
%      c1 = [1 4], ia1 = [21 19]', ib1 = [1 9]'
%
%      [c2,ia2,ib2] = intersect(a,b,'stable')
%      % returns
%      c2 = [4 1], ia2 = [19 21]', ib2 = [9 1]'
%
%      c = intersect([1 NaN 2 3],[3 4 NaN 1])
%      % NaNs compare as not equal, so this returns
%      c = [1 3]
%
%   Class support for inputs A and B, where A and B must be of the same
%   class unless stated otherwise:
%      - logical, char, all numeric classes (may combine with double arrays)
%      - cell arrays of strings (may combine with char arrays)
%      -- 'rows' option is not supported for cell arrays
%      - objects with methods SORT (SORTROWS for the 'rows' option), EQ and NE
%      -- including heterogeneous arrays derived from the same root class
%
%   See also UNIQUE, UNION, SETDIFF, SETXOR, ISMEMBER, SORT, SORTROWS.

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
    [varargout{1:nlhs}] = cellintersectR2012a(varargin{:}); 
else
    % acceptable combinations, with optional inputs denoted in []
    % intersect(A,B, ['rows'], ['legacy'/'R2012a']),
    % intersect(A,B, ['rows'], ['sorted'/'stable']),
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
                error(message('MATLAB:INTERSECT:UnknownFlag',flag));
            else
                error(message('MATLAB:INTERSECT:UnknownInput'));
            end
        end
        % Only 1 occurrence of each allowed flag value
        if flaginds(foundflag)
            error(message('MATLAB:INTERSECT:RepeatedFlag',flag));
        end
        flaginds(foundflag) = i;
    end
    
    % Only 1 of each of the paired flags
    if flaginds(2) && flaginds(3)
        error(message('MATLAB:INTERSECT:SetOrderConflict'))
    end
    if flaginds(4) && flaginds(5)
        error(message('MATLAB:INTERSECT:BehaviorConflict'))
    end
    % 'legacy' and 'R2012a' flags must be trailing
    if flaginds(4) && flaginds(4)~=nrhs
        error(message('MATLAB:INTERSECT:LegacyTrailing'))
    end
    if flaginds(5) && flaginds(5)~=nrhs
        error(message('MATLAB:INTERSECT:R2012aTrailing'))
    end
    
    if flaginds(2) || flaginds(3) % 'stable'/'sorted' specified
        if flaginds(4) || flaginds(5) % does not combine with 'legacy'/'R2012a'
            error(message('MATLAB:INTERSECT:SetOrderBehavior'))
        end
        [varargout{1:nlhs}] = cellintersectR2012a(varargin{1:2},logical(flaginds(1:3)));
    elseif flaginds(5) % trailing 'R2012a' specified
        [varargout{1:nlhs}] = cellintersectR2012a(varargin{1:2},logical(flaginds(1:3)));
    elseif flaginds(4) % trailing 'legacy' specified
        [varargout{1:nlhs}] = cellintersectlegacy(varargin{1:2},logical(flaginds(1)));
    else % 'R2012a' (default behavior)
        [varargout{1:nlhs}] = cellintersectR2012a(varargin{1:2},logical(flaginds(1:3)));
    end
end
end

function [c,ia,ib] = cellintersectlegacy(a,b,isrows)
% 'legacy' flag implementation

% handle inputs
nOut = nargout;
if nargin == 3 && isrows
    warning(message('MATLAB:INTERSECT:RowsFlagIgnored')); 
end

if ~any([iscellstr(a),iscellstr(b),ischar(a),ischar(b)])
   error(message('MATLAB:INTERSECT:InputClass',class(a),class(b)))
end

ia = [];
ib = [];

if isempty(a) || isempty(b)
    c = {};
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

if ispc && (length(b) == length(a)) && ~isempty(a) && isequal(a{1},b{1})
	%Sort of two sorted copies of exactly the same array takes a long
	%time on Windows.  This is to work around that issue until we
	%have a quick merge function or rewrite sort for cell arrays.
	r  = [1:3:length(a), 2:3:length(a), 3:3:length(a)];
	a = a(r); 
	b = b(r); 
	if (nOut > 1)
		ia = ia(r);
		ib = ib(r);
	end			
end

if nOut <= 1
	c = sort([a;b]);
else
	[c,ndx] = sort([a;b]);
end

d = strcmp(c(1:end-1),c(2:end));

c = c(d);
if nOut > 1
    ia = ia(ndx(d));
    ib = ib(ndx([false; d])-length(a));
end

if isrowa || isrowb
    c = c';
    ia = ia';
    ib = ib';
end

if (ambiguous && isempty(c))
    c = reshape(c,0,0);
    ia = [];
    ib = [];
end
end

function [c,ia,ib] = cellintersectR2012a(a,b,options)
% 'R2012a' flag implementation

% flagvals = {'rows' 'sorted' 'stable'};
if nargin == 2
    order = 'sorted';
else
    if (options(1) > 0)
        warning(message('MATLAB:INTERSECT:RowsFlagIgnored'));
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
    error(message('MATLAB:INTERSECT:InputClass',class(a),class(b)));
end

% Determine if A and B are both row vectors.
rowvec = isrow(a) && isrow(b);

% The two iscellstr() calls above verify that both a and b are cell arrays
% of strings. If either of them are empty, then we can return an empty
% cell array without continuing.
if isempty(a) || isempty(b)
    % If the inputs are both row vectors, then we return an empty row
    % vector, otherwise we return an empty column vector.
    if rowvec
        c = cell(1, 0);
    else
        c = cell(0, 1);
    end
    
    ia = zeros(0, 1);
    ib = zeros(0, 1);
    return
end

numelA = numel(a);

% Convert to columns.
a = a(:);
b = b(:);

if strcmp(order, 'stable') % stable
    [uB,uib] = unique(b,'sorted');                  % Find the unique elements of B in sorted 
                                                    % first order.  This is done to extract the
     numeluB = numel(uB);                           % indices of B in first order so one can later 
                                                    % rearrange them to stable order of A.   
    [c,ia,ic] = unique([a;uB],'stable');  
    
    % Find the number of unique elements in A.
    numUA = sum(ia <= numelA); 
    
    % Cut down ic to only include the "uB part"
    ic = ic(numelA+1:numelA+numeluB); 
    
    % Force ic to be a col if row
    if isequal(ic, zeros(1,0))
        ic = ic.';
    end
    
    logIcInterAB = ic <= numUA;             % Find the elements in uB that intersect with 
                                            % unique A.  This is done by looking at the 
    indIcInterAB = ic(logIcInterAB);        % uB part of ic and if the index in that is <= numUA
                                            % that implies that the number represented by the 
                                            % index in ic is in the intersect.    
    [sortIndIcInterAB, indSortIndIcInterAB] = sort(indIcInterAB);
    
    % Find C, sometimes have to force c to be the correct shape
    if logIcInterAB == 0
        c = cell(0,1);
    else
        c = c(sortIndIcInterAB);                
    end
    
    % Find IA and IB if needed.
    if nargout > 1
        % Force IA and IB to be the correct shape when logIcInterAB is 0.
        if logIcInterAB == 0               
            ia = zeros(0,1);
            ib = zeros(0,1);
        else
            ia = ia(sortIndIcInterAB);          
            uib = uib(logIcInterAB);            % First pull out the indices in unique B that 
            ib = uib(indSortIndIcInterAB);      % are in the intersection then reorder them so
        end                                     % they represent the 'stable' order of A.
    end
else % sorted 
    [uA,ia] = unique(a,order);
    [b,ib] = unique(b,order);
    
    % Find matching entries
    [sortab,indSortab] = sort([uA;b]);
    indInterAB = strcmp(sortab(1:end-1),sortab(2:end));
    
    % Force indInterAB to be the correct shape if empty row is produced.
    if isequal(indInterAB, zeros(1,0))                  
        indInterAB = indInterAB.';
    end
    % Find C, force c to be correct shape if indInterAB ==0
    if indInterAB == 0                                  
        c = cell(0,1);
    else
        c = sortab(indInterAB);                         
    end
    
    % Find indices if needed.
    if nargout > 1
        lenA = length(uA);                                
        % Force IA and IB to be the correct empty shape.
        if indInterAB == 0
            ia = ia(indSortab([false; indInterAB]));    
        else
            ia = ia(indSortab(indInterAB));
        end
        ib = ib(indSortab([false; indInterAB])-lenA);
        if isequal(ib, [])
            ib = zeros(0,1);
        end
    end
end

% If A and B are both row vectors, return c as row vector.
if rowvec
    c = c.';
end
end

