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
%   If there are common values in A and B, then the index is returned in IA.
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
% Convert string flags to char flags to dispatch to the right method
if (nargin == 3) && isstring(varargin{3})
    varargin{3} = convertFlag(varargin{3});
    [varargout{1:nlhs}] = union(varargin{:});
    return;
end
if (nargin == 4) && (isstring(varargin{3}) || isstring(varargin{4}))
    if isstring(varargin{3})
        varargin{3} = convertFlag(varargin{3});
    end
    if isstring(varargin{4})
        varargin{4} = convertFlag(varargin{4});
    end
    [varargout{1:nlhs}] = union(varargin{:});
    return;
end

if isstring(varargin{1}) || isstring(varargin{2})
    if ~ischar(varargin{1}) && ~iscellstr(varargin{1}) && ~isstring(varargin{1})
        firstInput = getString(message('MATLAB:string:FirstInput'));
        error(message('MATLAB:string:MustBeCharCellArrayOrString', firstInput));
    elseif ~ischar(varargin{2}) && ~iscellstr(varargin{2}) && ~isstring(varargin{2})
        secondInput = getString(message('MATLAB:string:SecondInput'));
        error(message('MATLAB:string:MustBeCharCellArrayOrString', secondInput));
    end
    varargin{1} = string(varargin{1});
    varargin{2} = string(varargin{2});
end
nrhs = nargin;
if nrhs == 2
    [varargout{1:nlhs}] = unionR2012a(varargin{:});
else
    % acceptable combinations, with optional inputs denoted in []
    % union(A,B, ['rows'], ['legacy'/'R2012a']),
    % union(A,B, ['rows'], ['sorted'/'stable']),
    % where the position of 'rows' and 'sorted'/'stable' may be reversed
    flagvals = ["rows" "sorted" "stable" "legacy" "R2012a"];
    % When a flag is found, note the index into varargin where it was found
    flaginds = zeros(1,length(flagvals));
    for i = 3:nrhs
        flag = varargin{i};
        assert(~isstring(flag));
        if ~ischar(flag)
            error(message('MATLAB:UNION:UnknownInput'));
        end
        foundflag = startsWith(flagvals,flag,'IgnoreCase',true);
        if sum(foundflag) ~= 1
            error(message('MATLAB:UNION:UnknownFlag',flag));
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
        [varargout{1:nlhs}] = unionR2012a(varargin{1:2},logical(flaginds(1:3)));
    elseif flaginds(5) % trailing 'R2012a' specified
        [varargout{1:nlhs}] = unionR2012a(varargin{1:2},logical(flaginds(1:3)));
    elseif flaginds(4) % trailing 'legacy' specified
        [varargout{1:nlhs}] = unionlegacy(varargin{1:2},logical(flaginds(1)));
    else % 'R2012a' (default behavior)
        [varargout{1:nlhs}] = unionR2012a(varargin{1:2},logical(flaginds(1:3)));
    end
end
end


function [c,ia,ib] = unionR2012a(a,b,options)
% 'R2012a' flag implementation

% flagvals = {'rows' 'sorted' 'stable'};
if nargin == 2
    byrow = false;
    order = 'sorted';
else
    byrow = (options(1) > 0);
    if options(3) > 0
        order = 'stable';
    else % if options(2) > 0 || sum(options(2:3)) == 0)
        order = 'sorted';
    end
end

% Check that one of A and B is double if A and B are non-homogeneous. Do a
% separate check if A is a heterogeneous object and only allow a B
% that is of the same root class.  
if ~(isa(a,'handle.handle') || isa(b,'handle.handle'))
    if ~strcmpi(class(a),class(b))
        if isa(a,'matlab.mixin.Heterogeneous') && isa(b,'matlab.mixin.Heterogeneous')
            rootClassA = meta.internal.findHeterogeneousRootClass(a);
            if isempty(rootClassA) || ~isa(b,rootClassA.Name)
                error(message('MATLAB:UNION:InvalidInputsDataType',class(a),class(b)));
            end
        elseif ~(strcmpi(class(a),'double') || strcmpi(class(b),'double'))
            error(message('MATLAB:UNION:InvalidInputsDataType',class(a),class(b)));
        end
    end
end

% Determine if A and B are both row vectors.
rowvec = isrow(a) && isrow(b);

numelA = numel(a);

if ~byrow
    
    % Convert to columns.
    a = a(:);
    b = b(:);
    
    if nargout <= 1
        % Call UNIQUE to do all the work.
        c = unique([a;b],order);
    else
        [c,ndx] = unique([a;b],order);
        % Indices determine whether an element was in A or in B.
        d = ndx > numelA;
        ia = ndx(~d);
        ib = ndx(d)-numelA;
    end
    
    % If A and B are both row vectors, return c as row vector.
    if rowvec
        c = c.';
    end
    
else    % 'rows' case
    if ~(ismatrix(a) && ismatrix(b))
        error(message('MATLAB:UNION:NotAMatrix'));
    end
    
    [rowsA,colsA] = size(a);
    [rowsB,colsB] = size(b);
    
    % Automatically pad strings with spaces
    if ischar(a) && ischar(b)
        b = [b repmat(' ',rowsB,colsA-colsB)];
        a = [a repmat(' ',rowsA,colsB-colsA)];
    elseif colsA ~= colsB
        error(message('MATLAB:UNION:AandBColnumAgree'));
    end
    
    if nargout <= 1
        % Call UNIQUE to do all the work.
        c = unique([a;b],order,'rows');
    else
        [c,ndx] = unique([a;b],order,'rows');
        % Indices determine whether an element was in A or in B.
        d = ndx > rowsA;
        ia = ndx(~d);
        ib = ndx(d) - rowsA;
        % When A and B have empty cols and rows, set the indices to columns.
        if colsA == 0 && colsB == 0 
            % 'last'
%             if strcmp(order,'last')    
%                 ia = zeros(0,1);
%             else 
                ib = zeros(0,1);
%             end
            if rowsA ==0 && rowsB ==0
                ia = zeros(0,1);
            end
        end
    end
end
end

function flag = convertFlag(flag)
if isscalar(flag)
    flag = char(flag);
else
    error(message('MATLAB:UNION:UnknownInput'));
end
end