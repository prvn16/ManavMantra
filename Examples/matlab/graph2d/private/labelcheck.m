function [ax,args,nargs] = labelcheck(propname,varargin)
% Determines if object has text property named propname
% 

%   Copyright 2013 The MathWorks, Inc.

args = varargin{:};
nargs = length(varargin{:});
ax=[];
if (nargs > 0) && (numel(args{1}) == 1) && local_validlabelobj(args{1},propname)
  ax = args{1};
  args = args(2:end);
  nargs = nargs-1;
end
if nargs > 0
  inds = find(strcmpi('parent',args));
  if ~isempty(inds)
    inds = unique([inds inds+1]);
    pind = inds(end);
    if nargs >= pind && local_validlabelobj(args{pind},propname)
      ax = args{pind};
      args(inds) = [];
      nargs = length(args);
    end
  end
end


function out = local_validlabelobj(obj,propname)
out = false;
if isscalar(obj) && ...
   isgraphics(obj) && ...
   isprop(obj,propname)

    tobj = get(obj,propname);
    
    if isscalar(tobj) && ...
       isa(tobj,'matlab.graphics.Graphics') && ...
       isprop(tobj,'String')            
        out = true;
    end
end