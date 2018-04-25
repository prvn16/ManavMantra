function show(o)
%SHOW  SHOW(obj)  show all the members of the Mtree obj

% Copyright 2006-2014 The MathWorks, Inc.

    J = find(o.IX); % indices of selected nodes in table
    Q = o.T(J,1); % "kind" numbers for selected nodes
    KKK = o.KK(Q); % "kind" strings for selected nodes
    SS = strings(o);
    nodeStr = getString(message('MATLAB:mtree:Node'));
    for i=1:numel(J)
        if isempty(SS{i})
            fprintf('     %s %d: %s\n',nodeStr,J(i),KKK{i});
        else
            fprintf('     %s %d: %s "%s"\n',nodeStr,J(i),KKK{i},SS{i});
        end
    end
end
