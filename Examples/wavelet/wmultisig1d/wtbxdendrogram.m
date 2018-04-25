function [h,T,perm,theGroups] = wtbxdendrogram(Z,varargin)
%WTBXDENDROGRAM Generate dendrogram plot.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 26-Jun-2006.
%   Last Revision: 20-Jul-2010.
%   Copyright 1995-2010 The MathWorks, Inc.

m = size(Z,1)+1;
p = varargin{1};
if nargin > 2
    color = true;
    threshold = varargin{3};
else
    color = false;
    threshold = 0.7 * max(Z(:,3));
end
                    
% For each node currently labeled m+k, replace its index by
% min(i,j) where i and j are the nodes under node m+k.
Z = transz(Z);
T = (1:m)';

% If there are more than p nodes, the dendrogram looks crowded.
% The following code will make the last p link nodes into leaf nodes,
% and only these p nodes will be visible.
if (m > p) && (p ~= 0)
    Y = Z((m-p+1):end,:);         % get the last nodes
    R = unique(Y(:,1:2)); 
    Rlp = R(R<=p);
    Rgp = R(R>p);
    W(Rlp) = Rlp;                 % use current node number if <=p
    W(Rgp) = setdiff(1:p, Rlp);   % otherwise get unused numbers <=p
    W = W(:);
    T(R) = W(R);
    % Assign each leaf in the original tree to one of the new node numbers
    for i = 1:p
        c = R(i);
        T = clusternum(Z,T,W(c),c,m-p+1,0); % assign to its leaves.
    end
    % Create new, smaller tree Z with new node numbering
    Y(:,1) = W(Y(:,1));
    Y(:,2) = W(Y(:,2));
    Z = Y;
    m = p; % reset the number of node to be 30 (row number = 29).
end
A = zeros(4,m-1);
B = A;
n = m;
X = 1:n;
Y = zeros(n,1);
r = Y;

% arrange Z into W so that there will be no crossing in the dendrogram.
W = zeros(size(Z));
W(1,:) = Z(1,:);
nsw = zeros(n,1); rsw = nsw;
nsw(Z(1,1:2)) = 1; rsw(1) = 1;
k = 2; s = 2;
while (k < n)
    i = s;
    while rsw(i) || ~any(nsw(Z(i,1:2)))
        if rsw(i) && i == s, s = s+1; end
        i = i+1;
    end
    W(k,:) = Z(i,:);
    nsw(Z(i,1:2)) = 1;
    rsw(i) = 1;
    if s == i, s = s+1; end
    k = k+1;
end
g = 1;
for k = 1:m-1 % initialize X
    i = W(k,1);
    if ~r(i) , X(i) = g;  g = g+1;  r(i) = 1;  end
    i = W(k,2);
    if ~r(i),  X(i) = g;  g = g+1;  r(i) = 1;  end
end
[~,perm] = sort(X);   % perm is the third output value
label = num2str(perm');

% set up the color
theGroups = 1;
groups = 0;
cmap = [0 0 1];
if color
    groups = sum(Z(:,3)< threshold);
    if groups > 1 && groups < (m-1)
        theGroups = zeros(m-1,1);
        numColors = 0;
        for count = groups:-1:1
            if (theGroups(count) == 0)
                P = zeros(m-1,1);
                P(count) = 1;
                P = colorcluster(Z,P,Z(count,1),count);
                P = colorcluster(Z,P,Z(count,2),count);
                numColors = numColors + 1;
                theGroups(logical(P)) = numColors;
            end
        end 
        cmap = hsv(numColors);
        cmap(end+1,:) = [0 0 0]; 
    else
        groups = 1;
    end
end  
newplot;

col = zeros(m-1,3);
h = zeros(m-1,1);
for n = 1:(m-1)
    i = Z(n,1); j = Z(n,2); w = Z(n,3);
    A(:,n) = [X(i) X(i) X(j) X(j)]';
    B(:,n) = [Y(i) w w Y(j)]';
    X(i) = (X(i)+X(j))/2; Y(i)  = w;
    if n <= groups
        col(n,:) = cmap(theGroups(n),:);
    else
        col(n,:) = cmap(end,:);
    end
end
ymin = min(Z(:,3));
ymax = max(Z(:,3));
margin = (ymax - ymin) * 0.05;
n = size(label,1);
for count = 1:(m-1)
    h(count) = line(A(:,count),B(:,count),'Color',col(count,:));
end
lims = [0 m+1 max(0,ymin-margin) (ymax+margin)];
set(gca,'XLim',[.5 ,(n +.5)],'XTick',1:n, 'XTickLabel',label,'Box','off');
mask = logical([0 0 1 1]);
if margin==0
    if ymax~=0
        lims(mask) = ymax * [0 1.25];
    else
        lims(mask) = [0 1];
    end
end
axis(lims);
%--------------------------------------------------------------------------
function T = clusternum(X, T, c, k, m, d)
% assign leaves under cluster c to c.
d = d+1;
n = m; flag = 0;
while n > 1
    n = n-1;
    if X(n,1) == k % node k is not a leave, it has subtrees
        T = clusternum(X, T, c, k, n,d); % trace back left subtree
        T = clusternum(X, T, c, X(n,2), n,d);
        flag = 1; break;
    end
end
if flag == 0 && d ~= 1 % row m is leaf node.
    T(X(m,1)) = c;
    T(X(m,2)) = c;
end
%--------------------------------------------------------------------------
function T = colorcluster(X, T, k, m)
% find local clustering
n = m; 
while n > 1
    n = n-1;
    if X(n,1) == k % node k is not a leave, it has subtrees
        T = colorcluster(X, T, k, n); % trace back left subtree
        T = colorcluster(X, T, X(n,2), n);
        break;
    end
end
T(m) = 1;
%--------------------------------------------------------------------------
function Z = transz(Z)
%TRANSZ Translate output of LINKAGE into another format.
%   This is a helper function used by DENDROGRAM and COPHENET.  
%   In LINKAGE, when a new cluster is formed from cluster i & j, it is
%   easier for the latter computation to name the newly formed cluster
%   min(i,j). However, this definition makes it hard to understand
%   the linkage information. We choose to give the newly formed
%   cluster a cluster index M+k, where M is the number of original
%   observation, and k means that this new cluster is the kth cluster
%   to be formed. This helper function converts the M+k indexing into
%   min(i,j) indexing.
m = size(Z,1)+1;
for i = 1:(m-1)
    if Z(i,1) > m ,      Z(i,1) = traceback(Z,Z(i,1)); end
    if Z(i,2) > m ,      Z(i,2) = traceback(Z,Z(i,2)); end
    if Z(i,1) > Z(i,2) , Z(i,1:2) = Z(i,[2 1]);        end
end
%----------------------------------------------------------
function a = traceback(Z,b)
m = size(Z,1)+1;
if Z(b-m,1) > m , a = traceback(Z,Z(b-m,1));  else  a = Z(b-m,1); end
if Z(b-m,2) > m , c = traceback(Z,Z(b-m,2));  else  c = Z(b-m,2); end
a = min(a,c);
%--------------------------------------------------------------------------
