function o = sets( o )
%SETS  oo = SETS( obj )  Returns the nodes that set obj's values
%  SETS is defined only on ID nodes, and returns sets of ID nodes

% Copyright 2006-2014 The MathWorks, Inc.

    % expand set based on the setters of JOIN nodes
    % we add the nodes pointed to by JOIN nodes to o
    % we also add indexed nodes that are set
    % we need to run this over the whole nodeset
    % we start with the setters of o
    I = o.T( o.IX, 10 );
    I = I(I>0);     % the ones that are present
    nt = size(o.T,1);
    done = false( 1, nt );
    todo = done;
    todo(I) = I>o.n;
    X = false( 1, o.n );   % the eventual answer
    X(I(I<=o.n)) = true;   % it includes the real nodes of I
    while( any(todo) )
        for i=find(todo)
            todo(i) = false;
            done(i) = true;
            if i <= o.n
                j = o.T( i, 10 );
                if j && ~done(j)
                    if j<=o.n
                        X(j) = true;
                    end
                    todo(j) = true;
                end
                continue
            end
            % its a join node
            jl = o.T(i,2);  % left
            jr = o.T(i,3);  % right
            if jl <= o.n
                X(jl) = true;
            elseif ~done(jl) && ~todo(jl)
                todo(jl) = true;
            end
            if jr <= o.n
                X(jr) = true;
            elseif ~done(jr) && ~todo(jr)
                todo(jr) = true;
            end
        end
    end
    o = makeAttrib( o, X );
    % chk(o);
end
