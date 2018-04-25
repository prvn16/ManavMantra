function out = pruneEdges3(skel, thresh)
% pruneEdges3 prunes the branches in the skeleton having a length less than
% THRESH pixels
%
% out = pruneEdges3(skel,THR)
%
% where "skel" is the input 3D binary image, and "THR" is a threshold for 
% the minimum length of branches. A is the adjacency matrix, and node/link
% are structures describing node and link properties
%
% This code is heavily inspired by the following MATLABCentral Post:     
% For more information, see <a
% href="matlab:web('http://uk.mathworks.com/matlabcentral/fileexchange/43527-skel2graph-3d')">Skel2Graph3D</a> at the MATLAB File Exchange.

% Copyright 2017 Mathworks

% return if skel is all zeros
if ~(any(skel(:)))
    out = skel;
    return;
end
% need this for labeling nodes etc.
skel_label = uint16(skel);

% all foreground voxels
canalPtsList=find(skel);

% 26-nh of all canal voxels
nh = logical(pk_get_nh(skel,canalPtsList));

% 26-nh indices of all canal voxels
nhi = pk_get_nh_idx(skel,canalPtsList);

% # of 26-nb of each skel voxel + 1
sum_nh = sum(logical(nh),2);

% all canal voxels with >2 nb are nodes
nodes = canalPtsList(sum_nh>3);

if(isempty(nodes))
    out = skel;
    return;
end

% all canal voxels with exactly one nb are end nodes
ep = canalPtsList(sum_nh==2);

% all canal voxels with exactly 2 nb
cans = canalPtsList(sum_nh==3);

% Nx3 matrix with the 2 nb of each canal voxel
can_nh_idx = pk_get_nh_idx(skel,cans);
can_nh = pk_get_nh(skel,cans);

% remove center of 3x3 cube
can_nh_idx(:,14)=[];
can_nh(:,14)=[];

% keep only the two existing foreground voxels
can_nb = sort(logical(can_nh).*can_nh_idx,2);

% remove zeros
can_nb(:,1:end-2) = [];

% can_nb will have 2 neighbors for each canal point (Nx2)

% add neighbours to canalicular voxel list (this might include nodes)
% cans now contains [canalidx neighbor1idx neighbor2idx]
cans = [cans can_nb];

% group clusters of node voxels to nodes
node=[];
link=[];

tmp=false(size(skel));
tmp(nodes)=1;

%Get pixelIdlist for connected nodes
cc2=bwconncomp(tmp); % number of unique nodes
num_realnodes = cc2.NumObjects;

% create node structure
for i=1:cc2.NumObjects
    node(i).idx = cc2.PixelIdxList{i};
    node(i).links = [];
    node(i).conn = [];
    node(i).ep = 0;
    
    % assign index to node voxels
    skel_label(node(i).idx) = i+1;
end

tmp=false(size(skel));
tmp(ep)=1;
cc3=bwconncomp(tmp); % number of unique nodes

% create node structure
for i=1:cc3.NumObjects
    ni = num_realnodes+i;
    node(ni).idx = cc3.PixelIdxList{i};
    node(ni).links = [];
    node(ni).conn = [];
    node(ni).ep = 1;
    % assign index to node voxels
    skel_label(node(ni).idx) = ni+1;
end

l_idx = 1;

c2n=zeros(numel(skel),1);
c2n(cans(:,1))=1:size(cans,1);

s2n=zeros(numel(skel),1);
s2n(nhi(:,14))=1:size(nhi,1);

% visit all nodes
for i=1:num_realnodes

    % find all canal vox in nb of all node idx
    link_idx = s2n(node(i).idx); %Get link id for pixels in node 1
    
    for j=1:length(link_idx)
        % visit all voxels of this node
        
        % all potential unvisited links emanating from this voxel. Find all neighborhood indices or 'on' pixels in neighborhood of jth element in the node
        link_cands = nhi(link_idx(j),nh(link_idx(j),:)==1);
        link_cands = link_cands(skel_label(link_cands)==1);
        
        for k=1:length(link_cands)
            [vox,n_idx,ep] = pk_follow_link(skel_label,node,i,j,link_cands(k),cans,c2n);
            skel_label(vox(2:end-1))=0;
            if((ep && length(vox)>thresh) || (~ep))%  && i~=n_idx)) This condition to remove loops
                link(l_idx).n1 = i;
                link(l_idx).n2 = n_idx; % node number
                link(l_idx).point = vox;
                node(i).links = [node(i).links, l_idx];
                node(n_idx).links = [node(n_idx).links, l_idx];
                l_idx = l_idx + 1;
            end
        end
    end
        
end

% mark all 1-nodes as end points
ep_idx = find(cellfun('length',{node.links})==1);
for i=1:length(ep_idx)
    node(ep_idx(i)).ep = 1;    
end

out = false(size(skel));

% for all nodes
for i=1:length(node)
    if(~isempty(node(i).links)) % if node has links
        out(node(i).idx)=true; % node voxels
        a = [link(node(i).links(node(i).links>0)).point];
        if(~isempty(a))
            out(a)=1; % edge voxels
        end
    end
end


function nhood = pk_get_nh_idx(img,i)

width = size(img,1);
height = size(img,2);
depth = size(img,3);

[x,y,z]=ind2sub([width height depth],i);

nhood = zeros(length(i),27);

for xx=1:3
    for yy=1:3
        for zz=1:3
            w=sub2ind([3 3 3],xx,yy,zz);
            nhood(:,w) = sub2ind([width height depth],x+xx-2,y+yy-2,z+zz-2);
        end
    end
end



function nhood = pk_get_nh(img,i)

width = size(img,1);
height = size(img,2);
depth = size(img,3);

[x,y,z]=ind2sub([width height depth],i);

nhood = false(length(i),27);

for xx=1:3
    for yy=1:3
        for zz=1:3
            w=sub2ind([3 3 3],xx,yy,zz);
            idx = sub2ind([width height depth],x+xx-2,y+yy-2,z+zz-2);
            nhood(:,w)=img(idx);
        end
    end
end


function [vox,n_idx,ep] = pk_follow_link(skel,node,k,j,idx,cans,c2n)

vox = [];
n_idx = [];
ep = 0;

% assign start node to first voxel
vox(1) = node(k).idx(j);

i=1;
isdone = false;
while(~isdone) % while no node reached
    i=i+1; % next voxel
    next_cand = c2n(idx);
        cand = cans(next_cand,2);
        if(cand==vox(i-1)) % switch direction
            cand = cans(next_cand,3);
        end
        if(skel(cand)>1) % node found
            vox(i) = idx;
            vox(i+1) = cand; % first node
            n_idx = skel(cand)-1; % node #
            if(node(n_idx).ep)
                ep=1;
            end
            isdone = 1;
        else % next voxel
            vox(i) = idx;
            idx = cand;
        end
end





