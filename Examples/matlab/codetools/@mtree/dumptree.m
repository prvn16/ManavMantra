function dumptree(o)
%DUMPTREE  DUMPTREE(obj)  Dump the tree with link names

% Copyright 2006-2016 The MathWorks, Inc.

    persistent linknames pno nxtno prtord
    if isempty( linknames )
        linknames = fieldnames( o.Linkno );
        % Clean this up.  Get rid of single letters
        for ii=1:length(linknames)
            linknames{ii} = [ '*' linknames{ii} ':' ];
        end
        pno = o.Linkno.Parent;
        nxtno = o.Linkno.Next;
        printorder = { 'Left', 'Right', 'Arg',  'Fname', 'Ins', ...
                       'Outs', 'Index', 'Vector', 'Cattr', ...
                       'Attr', 'Cexpr', 'Try', 'CatchID', ...
                       'Catch', 'Body', 'Next', 'VarName', 'VarType', ...
                       'VarDimensions', 'VarValidators' };
        prtord = zeros( 1, length(printorder) );
        for ii=1:length(prtord)
            prtord(ii) = o.Linkno.(printorder{ii});
        end
    end
    if isnull(o)
        return;
    end
    ix = find( o.IX, 1 );  % find the root of the first subtree
    recdump( 0, ix, '*<root>:' );
    function recdump( ind, nix, c )
        % dumps node nix, indenting %d characters w. char c
        % note: we do tail recursion on 'Next' links
        while( nix )
            if( o.IX(nix) )
                fprintf( '%3d  ', nix );
            else
                fprintf( '%3d  ', nix );
            end
            for i=1:ind
                fprintf( '   ' );
            end
            fprintf( '%s  ', c );
            % dump the current node
            sx = o.T(nix,8);
            s = '';
            if sx~=0
                s = [ ' (' o.C{sx} ')' ];
            end
            ln = linelookup( o, o.T(nix,5) );
            ch = o.T(nix,5)-o.lnos(ln);
            fprintf( '%s: %3d/%02d %s\n', o.KK{o.T(nix,1)}, ln, ch, s );
            % now, determine the links that are legal for the node
            OK = o.Linkok(:,o.T(nix,1));  % logical array
            
            for i=prtord( OK(prtord) )
                switch( i )
                    case { nxtno, pno }
                        % don't do parent, do Next specially
                    otherwise
                        % apply the link, see if anything is there
                        M = o.Lmap{ i };
                        jx = nix;
                        for j=1:length(M)
                            jx = o.T( jx, M(j) );
                            if jx == 0
                                break;
                            end
                        end
                        if jx ~= 0
                            % print the link recursively
                            recdump( ind+1, jx, linknames{i} );
                        end
                end
            end
            % now, do next node
            % note the tail recursion
            nix = o.T(nix, 4);
            c = '>Next:';
        end
    end
end
