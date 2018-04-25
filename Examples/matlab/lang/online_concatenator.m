function concatenator = online_concatenator(g, e)
% This function is undocumented and reserved for internal use.  It may be
% removed in a future release.

% Copyright 2007-2008 The MathWorks, Inc.

% This is not documented in R2007b, but if it were, the help would be ...
% g must be an associative binary function, but need not be commutative.
% (Otherwise, you would use a simpler technique.)  online_concatenator computes
% g(x1,...,xk), for k > 0.  This denotes pairwise application of g, but by
% associativity, the result is independent of the tree of binary applications.
% The terminology comes from the fact that concatenation is associative.
% The interesting part is that the x<i> may arrive in any order.  In particular,
% the interface is:
%
%  C = online_concatentor(f); % f is any function handle
%  C.concat(i, x<i>)          % each i in 1,...,k must appear exactly once
%  x = C.final()              % x = f(x1,...,xk);
%
%  If g has an identity element e, then you can also say, the following, and
%  k is allowed to be 0:
%
%  C = online_concatentor(f, e);
%  C.concat(i, x<i>)
%  x = C.final()
%
%  If k = 0, the result is e; otherwise, it is the same as above.

X = cell(1, 0);    % cell array of arguments to g
I = zeros(1, 0);   % indices of pending or active arguments
L = 0;             % current length of A and I

% Elements of I are in increasing order.  We use the convention that I(0) = 0.
% We say that j is "filled" if I(j-1) < I(j)-1.  If L > 0, then L is filled.
% If j < L, it is never the case that j and j+1 are both filled.  If the x<i>
% arrive roughly in order, this rule ensures that X and I are never very long.
% When j is filled, then X{j} is g(x<I(j-1)+1>,...,x<I(j)-1).  After a call on,
% C.concat(i, x<i>), i < L and I is not among the elements of I.  This forces
% x<i> to be accounted for somewhere in X.

concatenator = struct('concat', @concat, 'final', @final);

    function concat(i, x)
    j = find(i==I);
    if isempty(j)
        assert(i > L);
        if L == 0
            I = [1:i-1, i+1];
            L = i;
        else
            I(L+1:L-I(L)+i) = [I(L)+1:i-1, i+1];
            L = L + i - I(L);
        end
        X{L} = x;
    else
        assert(isscalar(j));
        if j == L % i is the first index unaccounted for
            X{L} = g(X{L}, x);
            I(L) = i+1;
        else
            I(j) = []; % delete the element of I that had i
            % In what follows, i is used for what was I(j),
            % and I(j) for what was I(j+1).
            if i+1 == I(j) % j+1 was not filled
                X(j+1) = []; % delete the element of X for the not-filled index
                % At this point, j is filled, but X{j} is incorrect.
                if i == 1
                    assert(j == 1);
                    X{1} = x;
                elseif j == 1
                    X{1} = g(X{1}, x);
                elseif I(j-1) == i-1 % i.e., I(j)-1, i.e., j was not filled
                    X{j} = x;
                else % j was filled
                    X{j} = g(X{j}, x);
                end
            else % j+1 was filled
                X{j+1} = g(x, X{j+1});
                if j > 1 && I(j-1) < i-1 ... % i.e., j was filled, as above
                   || j == 1 && i > 1        % i.e., 1 was filled
                    X{j+1} = g(X{j}, X{j+1});
                end
                X(j) = [];
            end
            L = L-1; % I and X had one element deleted
        end
    end
    end

    function x = final()
    if L == 0
        x = e;
    else
        x = X{1};
    end
    end
end
