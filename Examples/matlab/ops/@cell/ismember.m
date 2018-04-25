function [lia,locb] = ismember(a,b,flag1,flag2)
%ISMEMBER True for set member.
%   LIA = ISMEMBER(A,B) for cell arrays A and B returns an array of the same
%   size as A containing true where the elements of A are in B and false 
%   otherwise.
%
%   [LIA,LOCB] = ISMEMBER(A,B) also returns an array LOCB containing the
%   lowest absolute index in B for each element in A which is a member of 
%   B and 0 if there is no such index.
%
%   Inputs A and B must be strings or cell arrays of strings.
%
%     The behavior of ISMEMBER has changed.  This includes:
%       - occurrence of indices in LOCB switched from highest to lowest
%     If this change in behavior has adversely affected your code, you may 
%     preserve the previous behavior with:
%        [LIA,LOCB] = ISMEMBER(A,B,'legacy')
%
%   Example:
%
%      a = {'red','green'}
%      b = {'gray','blue','red','orange'}
%      [lia,locb] = ismember(a,b)
%
%      % returns  lia = [1 0]  and  locb = [3 0]
%
%   See also UNIQUE, UNION, INTERSECT, SETDIFF, SETXOR, SORT, SORTROWS.

%   Copyright 1984-2014 The MathWorks, Inc.

if nargin <= 2
    % The only A and B allowed are character arrays or cellstr.
    if ~((ischar(a) || iscellstr(a)) && (ischar(b) || iscellstr(b)))
        error(message('MATLAB:ISMEMBER:InputClass',class(a),class(b)));
    end
    % Scalar A: no sort needed
    if (ischar(a) && isrow(a)) || isscalar(a)
        match = strcmp(a,b);
        lia = any(match(:));
        if nargout > 1
            if lia
                locb = find(match,1,'first');
            else
                locb = 0;
            end
        end
    % Scalar B: no sort needed
    elseif (ischar(b) && isrow(b)) || isscalar(b)
        lia = strcmp(a,b);
        if nargout > 1
            locb = double(lia);
        end
    else
        % If A or B is char, convert it to a cellstr and remove trailing spaces
        if ischar(a)
            a = cellstr(a);
        end
        if ischar(b)
            b = cellstr(b);
        end
        % Duplicates within the sets are eliminated
        [uA,~,icA] = unique(a(:),'sorted');
        if nargout <= 1
            uB = unique(b(:),'sorted');
        else
            [uB,ib] = unique(b(:),'sorted');
        end
        % Sort the unique elements of A and B, duplicate entries are adjacent
        [sortuAuB,IndSortuAuB] = sort([uA;uB]);
        % d indicates the indices matching entries
        d = strcmp(sortuAuB(1:end-1),sortuAuB(2:end));
        indReps = IndSortuAuB(d);                  % Find locations of repeats
        if nargout <= 1
            lia = ismember(icA,indReps);           % Find repeats among original list
        else
            szuA = size(uA,1);
            d = find(d);
            [lia,locb] = ismember(icA,indReps);    % Find locb by using given indices
            newd = d(locb(lia));                   % NEWD is D for non-unique A
            where = ib(IndSortuAuB(newd+1)-szuA);
            locb(lia) = where;
        end
        lia = reshape(lia,size(a));
        if nargout > 1
            locb = reshape(locb,size(a));
        end
    end
elseif nargin == 3
    % ISMEMBER(a,b,'legacy'), ISMEMBER(a,b,'R2012a')
    if nargout < 2
        lia = cellismemberlegacy(a,b,flag1);
    else
        [lia,locb] = cellismemberlegacy(a,b,flag1);
    end
else
    % ISMEMBER(a,b,'rows','legacy'), ISMEMBER(a,b,'rows','R2012a')
    if nargout < 2
        lia = cellismemberlegacy(a,b,flag1,flag2);
    else
        [lia,locb] = cellismemberlegacy(a,b,flag1,flag2);
    end
end


