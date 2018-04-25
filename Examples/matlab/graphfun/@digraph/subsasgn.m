function G = subsasgn(G, S, V)

%   Copyright 2014-2017 The MathWorks, Inc.

% Only dot assignment is permitted.
if ~strcmp(S(1).type, '.')
    error(message('MATLAB:graphfun:digraph:ScalarObject'));
end
% Only allow access of public properties/methods.
if ~any(strcmp(S(1).subs, {'Nodes', 'Edges'}))
    if ~ismethod(G, S(1).subs)
        if ~isprop(G, S(1).subs)
            error(message('MATLAB:noPublicFieldForClass', S(1).subs, class(G)));
        else
            error(message('MATLAB:class:SetProhibited', S(1).subs, class(G)));
        end
    end
end
% Do not allow assignment of edges here.
if numel(S) == 1
    if strcmp(S(1).subs, 'Edges')
        error(message('MATLAB:graphfun:digraph:SetEdges'));
    end
end
% Short-circuit to EdgeProperties if appropriate.
if numel(S) > 1 && strcmp(S(1).subs, 'Edges')
  if strcmp(S(2).type, '.')
      if strcmp(S(2).subs, 'EndNodes')
          error(message('MATLAB:graphfun:digraph:EditEdges'));
      end
      if ~strcmp(S(2).subs, 'Properties')
          S(1).subs = 'EdgeProperties';
      end
  else
      if numel(S(2).subs) == 2
          secondInd = S(2).subs{2};
          if isnumeric(secondInd) && any(secondInd == 1)
              error(message('MATLAB:graphfun:digraph:EditEdges'));
          elseif islogical(secondInd) && ~isempty(secondInd) && secondInd(1)
              error(message('MATLAB:graphfun:digraph:EditEdges'));
          elseif ischar(secondInd) || iscellstr(secondInd)
              if ismember('EndNodes', secondInd)
                  error(message('MATLAB:graphfun:digraph:EditEdges'));
              elseif isequal(secondInd, ':')
                  error(message('MATLAB:graphfun:digraph:EditEdges'));
              end
          end
      end
  end
end
G = builtin('subsasgn', G, S, V);

if size(G.EdgeProperties, 1) ~= numedges(G.Underlying)
    error(message('MATLAB:graphfun:digraph:SetEdges'));
end