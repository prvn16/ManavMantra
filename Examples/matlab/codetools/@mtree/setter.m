function oo = setter( o )
%SETTER  oo = setter( obj )  returns the setter of node obj

% Copyright 2006-2014 The MathWorks, Inc.

    % ignores the case where the node is the target of an assignment
    if count(o) ~= 1 
        error(message('MATLAB:mtree:setter'));
    end
    J = o.T(o.IX,10);  % 10 is the column with SET information
  
    if ~J || o.T(J,1) == o.K.JOIN
        oo = o;
        return;
    end
    % if J is an ID node, try once more
    if o.T(J,1) == o.K.ID
        JJ = o.T(J,10);
        if JJ 
            if o.T(JJ,1) ~= o.K.JOIN
                J = JJ;
            end
        elseif o.T(J,4)==0
            % J is a simple assignment
            P = o.T(J,9);  % 9 for parent
            % check that P exists, is =, has only one lhs, and the
            % lhs is J  (4 is next, 1 is kind, 2 is left)
            % make this work for [x] = ...  also
            % simple case first: if LHS is J, simple assignment
            if P
                if o.T(P,1) == o.K.EQUALS && o.T(P,2) == J  
                % J is the left descendent of P
                    J = o.T(P,3);  % rhs of =
                % now, do [x] case: parent is [, no next, parent
                % of parent is =
                elseif o.T(P,1) == o.K.LB
                    PP = o.T(P,9);   % 
                    if o.T(PP,1) == o.K.EQUALS && o.T(PP,2)==P
                        J = o.T(PP,3);  % rhs of =
                    end
                end
            end
        end
        oo = makeAttrib( o, J );
    end
end
