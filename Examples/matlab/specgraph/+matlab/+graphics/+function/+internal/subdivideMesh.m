function [pointCoords,triangles,edges]=subdivideMesh(pointCoords,triangles,borders,edgeSplit,maxdepth,ds)
  % internal function for adaptive refinement

%   Copyright 2015-2017 The MathWorks, Inc.

  % subdivideMesh(pointCoords,triangles,borders,edgeSplit,maxdepth) -- refine triangle mesh
  %
  %  pointCoords: A matrix such that pointCoords(:,1), pointCoords(:,2), ... is
  %  the coordinates of the points on the initial mesh. For each point
  %  p = pointCoords(:,i), p(1:3) are assumed to be the x,y,z coordinates. Further
  %  entries can be used as desired, e.g., for parameterized surfaces.
  %
  %  triangles: an n*3 int32 array of indices into pointCoords, defining the triangles.
  %  Orientation is preserved.
  %
  %  borders: an m*6 double array, denoting edges that are inner borders,
  %  typically around holes in the definition of the function evaluated.
  %  Each line is of the form [p1,p2,xmin,xmax,ymin,ymax], where p1 and p2 are
  %  indices into pointCoords and xmin through ymax limit where the points may go.
  %
  %  edgeSplit: a function handle. For any two points p1, p2 (of the format given by
  %  pointCoords(:,i)), p3=edgeSplit(p1,p2) must be a point of the same format.
  %  It is meant to be a point roughly centered between p1 and p2 on the surface.
  %
  %  edgeSplit(p1,p2,~) is supposed to return a new point roughly between p1 and p2.
  %  Points are taken to have a(1), a(2), and a(3) as coordinates in space.
  %  Apart from that, their format can be chosen any way that is helpful.
  %  For example for a parameterized surface, you might have a=[x;y;z;u;v] and
  %
  %   function p3=edgeSplit(p1,p2,~,~)
  %     u = (p1(4)+p2(4))/2;
  %     v = (p1(5)+p2(5))/2;
  %     p3 = [x(u,v),y(u,v),z(u,v),u,v].';
  %
  %  edgeSplit(p1,p2,p3,xyminmax) is called with empty p3 for edges that do not border holes.
  %  For border edges (except those at the edge of the parameter space), p3 is the
  %  opposite corner of the (unique) triangle along this edge. The edgeSplit function
  %  can use this to get the triangulation closer to the border of holes.
  %  If p3 is not empty, xyminmax is a 1*4 double indicating how far (in the parameter space)
  %  the new point may go. This is simply forwarded from the input entries in border.
  %
  %  maxdepth: The maximum recursion depth for introducing new points
  %
  %  ds: The DataSpace. Currently ignored unless isa(ds,'matlab.graphics.axis.dataspace.CartesianDataSpace')

% assert(size(triangles,2)==3);

if isempty(triangles)
  edges = zeros(0,6,'int32');
  return;
end

% viewing box size approximation, for refinement decision
vbox = [min(pointCoords(1:3,:),[],2), max(pointCoords(1:3,:),[],2)];
if ~isempty(ds) && isa(ds,'matlab.graphics.axis.dataspace.CartesianDataSpace')
  vbox = [[ds.XLim; ds.YLim; ds.ZLim],vbox];
  vbox = [min(vbox,[],2), max(vbox,[],2)];
end
vbox = vbox(:,2)-vbox(:,1);
vbox(vbox < 100*eps) = 100*eps;
scaleFactors = 1./vbox;

% Each triangle may be split in up to four smaller triangles (which again may be split, recursively).
% Hence, we store, in each row, [e1,e2,e3,t1,t2,t3,t4], with the edges e1-e3 being row indices into
% the edge array and t1-t3 being either 0 or row indices into the triangle array.
% Only those triangles where t1==0,t2==0,t3==0,t4==0 are in the final image.

% First, create edge list and translate from corner points to edge numbers:

edges = [triangles(:,1:2); triangles(:,2:3); triangles(:,[3,1])];

edges = sort(edges,2);
[edges,~,newEdgeNumbers] = unique(edges,'rows');
triangles = reshape(newEdgeNumbers,[],3);

triangles = [triangles,zeros(size(triangles,1),4,'int32')];

borderPointLimits = zeros(0,4);
if ~isempty(borders)
  borderPointLimits = borders(:,3:6);
  borders = sort(borders(:,1:2),2);
  [~,borders] = ismember(borders,edges,'rows');
end

n = size(edges,1);
edgeToSplit = uint32(inf);

% The edge tree is a recursive tree structure, stored in an array,
% with these entries per row:
% [p1, p2, midpoint, error, left, right, level]
% p1 and p2 being the endpoints of the line segment (pointers into pointCoords),
% midpoint the computed subdivision point (or 0 if discarded),
% error being an estimate of the (absolute) error incurred
% by using the straight line segment from p1 to p2 instead of the subdivision,
% and left and right either (both) 0 or (both) row indices of subtrees of the same form.
% If left or right are -1, the edge has not been subdivided yet.
% Levels are counting down: If the level of an edge is n, its children
% have level n-1. An edge with level 0 is not divided further.
edges = [edges, zeros(size(edges,1),5)];
edges(:,7)=maxdepth;

nEdges = size(edges,1);

  function idx=addEdges(p1,p2,level)
    assert(~any(p1==0));
    assert(~any(p2==0));
    idx = nEdges+(1:numel(p1));
    nEdges = nEdges+numel(p1);
    while size(edges,1) < nEdges
      edges = [edges;repmat([0,0,0,0,edgeToSplit,edgeToSplit,0],size(edges,1),1)]; %#ok<AGROW>
    end
    edges(idx,1) = p1;
    edges(idx,2) = p2;
    edges(idx,7) = level;
    edges(idx(level<=0),5:6) = 0;
  end

  function n=scaledNorm(vectors)
    scaledVectors = bsxfun(@times,vectors,scaleFactors);
    n=sqrt(sum(scaledVectors.^2,1)).';
  end

  function subdivideEdges(k)
    depth = edges(k,7);
    k = k(depth>0);
    if isempty(k)
      return
    end

    [borderEdges,borderEdgesIdx] = ismember(k,borders);
    if any(borderEdges) && ~all(borderEdges)
      % indexing gets weird if we mix
      subdivideEdges(k(borderEdges));
      subdivideEdges(k(~borderEdges));
      return;
    end

    borderEdgesIdx = borderEdgesIdx(borderEdges);
    borderEdges = all(borderEdges);

    oppositeCorners = [];
    if borderEdges
      oppositeCorners = zeros(numel(k),1,'uint32');
      for idx=1:numel(k)
        ki = k(idx);
        tri = any(triangles(:,1:3)==ki,2);
        tri = triangles(tri,1:3);
        otherEdges = setdiff(int32(tri),ki);
        oppositeCorners(idx) = intersect(edges(otherEdges(1),1:2),edges(otherEdges(2),1:2));
      end
    end

    a = edges(k,1);
    b = edges(k,2);
    pa = pointCoords(:,a);
    pb = pointCoords(:,b);
    oppositeCorners = pointCoords(:,oppositeCorners);
    p3 = edgeSplit(pa,pb,oppositeCorners,borderPointLimits(borderEdgesIdx,:));
    % assert(isequal(size(pa),size(p3)));
    d = scaledNorm((pa(1:3,:)+pb(1:3,:))/2 - p3(1:3,:));
    edges(k,4) = d;
    maxD = max(0.02*scaledNorm(pa(1:3,:)-pb(1:3,:)), 1e-3);
    subdivide = d > maxD;
    edges(k(~subdivide),5:6) = 0;

    k = k(subdivide);
    a = a(subdivide);
    b = b(subdivide);
    d = d(subdivide);
    depth = edges(k,7);
    pp3 = size(pointCoords,2)+(1:nnz(subdivide)).';
    pointCoords = [pointCoords,p3(:,subdivide)];
    edges(k,3) = pp3;
    edges(k,5) = addEdges(a,pp3,depth-1);
    edges(k,6) = addEdges(pp3,b,depth-1);
    edges(k,4) = max([d,edges(edges(k,5),4),edges(edges(k,6),4)],[],2);

    if borderEdges
      borders = [borders; reshape(edges(k,5),[],1); reshape(edges(k,6),[],1)];
      borderPointLimits = [borderPointLimits; ...
        borderPointLimits(borderEdgesIdx(subdivide),:); ...
        borderPointLimits(borderEdgesIdx(subdivide),:)];
    end
  end

  nTriangles = size(triangles,1);

  function idx=addTriangles(edges)
    idx=nTriangles+(1:size(edges,1));
    nTriangles=nTriangles+size(edges,1);
    while nTriangles >= size(triangles,1)
      triangles = [triangles; 0*triangles]; %#ok<AGROW>
    end
    triangles(idx,:)=[edges,zeros(size(edges,1),4)];
  end

  function subdivideTriangleWithOneNonsimpleEdge(k,triangle,e)
    %        *
    %        |\
    %        | \
    %        |  \ e4
    %        |   \
    %  e(e2) |    *    e(idx)
    %        |   / \
    %        |  /   \ e3
    %        | /(1)  \             (1) = edges(newEdge)
    %        |/       \
    %        *---------*
    %     (2)    e(e1)             (2) = pointCoords(oppositeCorner,:)
    [row,idx] = find(e(:,:,5));
    % reorder idx to have one per row
    idx(row) = idx;
    e1 = mod(idx+1,3)+1; % == idx-1 (mod 3)
    e2 = mod(idx,3)+1;
    firstIdx = (1:numel(k)).';
    lastIdx = ones(size(firstIdx));
    e1LeftIdx = sub2ind(size(e),firstIdx,e1,1*lastIdx);
    e1RightIdx = sub2ind(size(e),firstIdx,e1,2*lastIdx);
    eIdxLeftIdx = sub2ind(size(e),firstIdx,idx,1*lastIdx);
    eIdxRightIdx = sub2ind(size(e),firstIdx,idx,2*lastIdx);

    % find the correct other edges to form triangles
    reverseIdx = (e(e1LeftIdx)~=e(eIdxLeftIdx)) & (e(e1RightIdx)~=e(eIdxLeftIdx));
    reverseE1 = (e(e1RightIdx)~=e(eIdxLeftIdx)) & (e(e1RightIdx)~=e(eIdxRightIdx));
    oppositeCorner = e(sub2ind(size(e),firstIdx,e1,1+reverseE1));

    eCenter = e(sub2ind(size(e),firstIdx,idx,3*lastIdx));
    e3 = e(sub2ind(size(e),firstIdx,idx,5+reverseIdx));
    e4 = e(sub2ind(size(e),firstIdx,idx,6-reverseIdx));
    levels = e(sub2ind(size(e),firstIdx,idx,7*lastIdx));
    newEdges = addEdges(oppositeCorner,eCenter,levels-1).';
    newTriangles = addTriangles([...
      triangle(sub2ind(size(triangle),firstIdx,e1)),e3,newEdges;...
      triangle(sub2ind(size(triangle),firstIdx,e2)),newEdges,e4]);
    triangles(k,4:5) = reshape(newTriangles,[],2);
  end

  function subdivideTriangleWithTwoNonsimpleEdges(k,triangle,e)
    %        *
    %        |\
    %    (4) | \ (3)               (3) = edges(e3)
    %        |  \                  (4) = edges(e4)
    %        |(2)\                 (2) = edges(newEdge2)
    %  e(e2) *----*    e(e1)
    %        |   / \               (5) = edges(e5)
    %    (6) |  /   \ (5)          (6) = edges(e6)
    %        | /(1)  \             (1) = edges(newEdge1)
    %        |/       \
    %        *---------*
    %        e(simpleIdx)
    [row,simpleIdx] = find(e(:,:,5)==0);
    % reorder simpleIdx to have one per row
    simpleIdx(row) = simpleIdx;

    % TODO: Pick the triangles to avoid creating long skinny ones. Arbitrary selection for now:
    e1 = mod(simpleIdx,3)+1;
    e2 = mod(simpleIdx+1,3)+1;

    firstIdx = (1:numel(k)).';
    lastIdx = ones(size(firstIdx));
    e1LeftIdx = sub2ind(size(e),firstIdx,e1,1*lastIdx);
    e1RightIdx = sub2ind(size(e),firstIdx,e1,2*lastIdx);
    % e2LeftIdx = sub2ind(size(e),firstIdx,e2,1*lastIdx);
    e2RightIdx = sub2ind(size(e),firstIdx,e2,2*lastIdx);
    eSimpleIdxLeftIdx = sub2ind(size(e),firstIdx,simpleIdx,1*lastIdx);
    eSimpleIdxRightIdx = sub2ind(size(e),firstIdx,simpleIdx,2*lastIdx);

    reverseSimpleIdx = (e(e1LeftIdx)==e(eSimpleIdxLeftIdx)) | (e(e1RightIdx)==e(eSimpleIdxLeftIdx));
    reverseE1 = (e(e1RightIdx)==e(eSimpleIdxLeftIdx)) | (e(e1RightIdx)==e(eSimpleIdxRightIdx));
    reverseE2 = (e(e2RightIdx)==e(eSimpleIdxLeftIdx)) | (e(e2RightIdx)==e(eSimpleIdxRightIdx));

    oppositeCorner = e(sub2ind(size(e),firstIdx,simpleIdx,1+reverseSimpleIdx));

    e1Center = e(sub2ind(size(e),firstIdx,e1,3*lastIdx));
    e2Center = e(sub2ind(size(e),firstIdx,e2,3*lastIdx));

    e1Levels = e(sub2ind(size(e),firstIdx,e1,7*lastIdx));
    e2Levels = e(sub2ind(size(e),firstIdx,e2,7*lastIdx));

    newEdges1 = addEdges(oppositeCorner,e1Center,e1Levels-1).';
    newEdges2 = addEdges(e1Center,e2Center,e2Levels-1).';

    e3 = e(sub2ind(size(e),firstIdx,e1,6-reverseE1));
    e5 = e(sub2ind(size(e),firstIdx,e1,5+reverseE1));
    e4 = e(sub2ind(size(e),firstIdx,e2,6-reverseE2));
    e6 = e(sub2ind(size(e),firstIdx,e2,5+reverseE2));

    newTriangles = addTriangles([...
      triangle(sub2ind(size(triangle),firstIdx,simpleIdx)),e5,newEdges1;...
      newEdges1,newEdges2,e6;...
      newEdges2,e3,e4]);
    triangles(k,4:6) = reshape(newTriangles,[],3);
  end

  function subdivideTriangleWithThreeNonsimpleEdges(k,~,e)
    % Deviating from the paper, more symmetrical:
    %
    %              *
    %          (1)/ \(2)
    %            /(3)\
    %   e(1)    *-----*      e(3)
    %       (4)/ \   / \(7)
    %         /  5\ /6  \
    %        *-----*-----*
    %          (8)   (9)
    %             e(2)
    if any(e(1,1)==e(2,1:2))
      e1 = e(1,6);
      e4 = e(1,5);
    else
      e1 = e(1,5);
      e4 = e(1,6);
    end
    if any(e(3,1)==e(1,1:2))
      e2 = e(3,5);
      e7 = e(3,6);
    else
      e2 = e(3,6);
      e7 = e(3,5);
    end
    if any(e(2,1)==e(1,1:2))
      e8 = e(2,5);
      e9 = e(2,6);
    else
      e8 = e(2,6);
      e9 = e(2,5);
    end
    newEdges = addEdges(e([3;2;1],3),e([1;3;2],3),e([3;2;1],7)-1);
    e3 = newEdges(1);
    e6 = newEdges(2);
    e5 = newEdges(3);
    triangles(k,4:7) = addTriangles([...
      e8,e5,e4;...
      e9,e7,e6;...
      e6,e3,e5;...
      e3,e2,e1]);
  end

  function subdivideTriangles(k)
    % Assume that the edges of triangle k have been subdivided,
    % now subdivide the triangle.
    % Does not yet perform an inner-point check on undivided triangles.
    batchTriangles = triangles(k,:);
    e = reshape(edges(batchTriangles(:,1:3),:),numel(k),3,size(edges,2));
    assert(~any(any(e(:,:,5)==edgeToSplit)));
    nonSimpleEdges = sum(e(:,:,5)~=0,2);
    pos=find(nonSimpleEdges==1);
    subdivideTriangleWithOneNonsimpleEdge(k(pos),batchTriangles(pos,:),e(pos,:,:));
    pos=find(nonSimpleEdges==2).';
    subdivideTriangleWithTwoNonsimpleEdges(k(pos),batchTriangles(pos,:),e(pos,:,:));
    for pos=find(nonSimpleEdges==3).'
      subdivideTriangleWithThreeNonsimpleEdges(k(pos),batchTriangles(pos,:),reshape(e(pos,:,:),3,7));
    end
  end

subdivideEdges(1:n);

k=1;
while k<=nTriangles
  endOfThisBatch = nTriangles;
  subdivideTriangles(k:endOfThisBatch);
  k = endOfThisBatch+1;
  subdivideEdges(find(edges(:,5)==edgeToSplit));
end

triangles = triangles(1:nTriangles,:);

% And translate the triangles back to indexing into the point coordinates:
function tri=edgesToPoints(tri)
  e = edges(tri,1:2);
  if e(1,1)==e(2,1)
    tri = [e(1,2), e(2,1), e(2,2)];
  elseif e(1,2)==e(2,1)
    tri = [e(1,1), e(2,1), e(2,2)];
  elseif e(1,1)==e(2,2)
    tri = [e(1,2), e(2,2), e(2,1)];
  else
    % assert(e(1,2)==e(2,2));
    tri = [e(1,1), e(2,2), e(2,1)];
  end
end

triangles(triangles(:,4)~=0,:) = []; % remove all subdivided triangles
triangles = num2cell(triangles(:,1:3),2);
triangles = cellfun(@edgesToPoints,triangles,'UniformOutput',false);
triangles = vertcat(triangles{:});
% triangles(1:2:end,:) = fliplr(triangles(1:2:end,:));

edges(edges(:,5)~=0,:) = []; % remove subdivided edges

end

