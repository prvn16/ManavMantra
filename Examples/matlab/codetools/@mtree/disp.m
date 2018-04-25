function disp(o)
%DISP  DISP(obj)  display the Mtree object obj

% Copyright 2006-2014 The MathWorks, Inc.

    if o.m==o.n
        fprintf('  mtree (complete: %d nodes)\n',o.n);
    else
        fprintf('  mtree (subtree: %d of %d nodes)\n',o.m,o.n);
    end
    if o.m<10
        show(o);
    end
end
