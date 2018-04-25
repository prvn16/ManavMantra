function Vq = imposeextrapval(Xq,gv,Vq, extrapval,iscompact)
% IMPOSEEXTRAPVAL sets the extrapolation value for query points outside domain
%   VQ = IMPOSEEXTRAPVAL(XQ,GV,VQ, EXTRAPVAL) assigns the value EXTRAPVAL to
%   the entries of VQ, if the corresponding query points in XQ lie outside the 
%   domain of the grid defined by the grid vectors GV. XQ is a cell array of 
%   query points; the query points may define a grid in terms of grid vectors.
%   GV is a cell array of grid vectors representing the domain of the grid.
%

%   Copyright 2011 The MathWorks, Inc.

numdimensions = numel(Xq);
if iscompact
  idx = cell(1,numdimensions);
  for i = 1:numdimensions
      idx{i} = ':';
  end
  for i = 1:numdimensions
      idx{i} = Xq{i} < gv{i}(1) | Xq{i} > gv{i}(end);
      Vq(idx{:}) = extrapval;  
      idx{i} = ':';
  end
else
  if isvector(Vq)  % Scattered data query
     idx = false(size(Xq{1}));
  else             % Else full grid query 
      idx = false(size(Vq));
  end
  for i = 1:numdimensions
    idx = idx | Xq{i} < gv{i}(1) | Xq{i} > gv{i}(end);
  end
  Vq(idx) = extrapval;   
end

