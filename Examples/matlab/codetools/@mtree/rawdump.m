function rawdump(o)
%RAWDUMP  RAWDUMP(obj)  Dump the full tree, showing all nodes
%    The members of the set obj are highlighted in the dump

% Copyright 2006-2014 The MathWorks, Inc.

    if isnull(o)
        return;
    end
    recdump( 0, 1, '*' );
    function recdump( ind, nix, c )
        % dumps node nix, indenting %d characters w. char c
        % note tail recursion on the 'next' node
        while( nix )
            if( o.IX(nix) )
                fprintf( '%3d===  ', nix );
            else
                fprintf( '%3d     ', nix );
            end
            for i=1:ind
                fprintf( '   ' );
            end
            fprintf( '%s  ', c );
            % dump one node
            sx = o.T(nix,8);
            s = '';
            if sx~=0
                s = [ ' (' o.C{sx} ')' ];
            end
            ln = linelookup( o, o.T(nix,5) );
            ch = o.T(nix,5)-o.lnos(ln);
            fprintf( '%s: %3d/%02d %s\n', o.KK{o.T(nix,1)}, ln, ch, s );
            if o.T(nix,2) % left
                recdump( ind+1, o.T(nix,2), '*' );
            end
            if o.T(nix,3) % right
                recdump( ind+1, o.T(nix,3), '*' );
            end
            nix = o.T(nix, 4);
            c = '>';
        end
    end
end
