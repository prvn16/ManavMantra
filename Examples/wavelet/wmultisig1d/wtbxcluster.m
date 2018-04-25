function T = wtbxcluster(Z,maxclust,crit)
%WTBXCLUSTER Construct clusters from a hierarchical cluster tree.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 26-Jun-2006.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2010 The MathWorks, Inc.

% Start of algorithm and Check input.
m = size(Z,1)+1;
T = zeros(m,1);
flagCRIT = false;
if nargin>1
    if isinf(maxclust)
        maxclust = m;
    elseif isnan(maxclust) || nargin>2
        flagCRIT = true;
    else
        if (maxclust<1) || (maxclust ~= fix(maxclust))
            error(message('Wavelet:FunctionArgVal:Invalid_CluNum'));
        end
    end
else
    maxclust = m;
end
if flagCRIT
    if nargin==2 , crit = Z(:,3); end
    cutoff = 0.7*max(crit);
    maxclust = sum(crit>cutoff) + 1;
end

% Start of algorithm.
if m <= maxclust
    T = (1:m)';
elseif maxclust==1
    T = ones(m,1);
else
    clsnum = 1;
    for k = (m-maxclust+1):(m-1)
        for j = 1:2
            i = Z(k,j);   % left tree (j=1) or right tree (j = 2)
            if i <= m     % original node, no leafs
                T(i) = clsnum;
                clsnum = clsnum + 1;
            elseif i < (2*m-maxclust+1)
                node = i-m;
                while(~isempty(node))
                    % Get the children of nodes at this level
                    children = Z(node,1:2);
                    children = children(:);
                    % Assign the cluster number to leaf children
                    t = (children <= m);
                    T(children(t)) = clsnum;

                    % Move to next level
                    node = children(~t) - m;
                end
                clsnum = clsnum + 1;
            end
        end
    end
end
