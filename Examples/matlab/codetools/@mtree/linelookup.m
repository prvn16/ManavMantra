function L = linelookup( o, P )
%LINELOOKUP  (Mtree internal function to look up lines)

% Copyright 2006-2014 The MathWorks, Inc.

    np = length(P);
    L = zeros( np, 1 );
    if np==0
        return;
    end
    LL = o.lnos;
    ln = length(LL);
    guess = max( floor(ln*(P(1)/LL(end))), 1);  % first guess
    for i=1:np
        if( LL(guess) < P(i) )
            % go up
            if guess >= ln
                guess = ln+1;
            else
                for j=guess+1:ln
                    if( LL(j) >= P(i) )
                        guess = j-1;
                        break
                    end
                    if( j == ln )
                        guess = ln+1;
                        break
                    end
                end
            end
        else
            % go down
            if guess ~= 1
                for j=guess-1:-1:1
                    if( LL(j) < P(i)  )
                        guess = j;
                        break
                    end
                    if j == 1
                        guess = 1;
                        break
                    end
                end
            end
        end
        L(i) = guess;
    end
end
