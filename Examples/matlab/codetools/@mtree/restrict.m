function a = restrict( o, ipath, s )
%RESTRICT  a = restrict( o, ipath, s )    Mtree internal function
% this is very tricky.  At each stage, we need to keep
% track of the original index set so we can zero out the
% elements that do not match.  a must be a subset of o

% Copyright 2006-2014 The MathWorks, Inc.

    % chk(o);
    a = o;
    I = find( a.IX );
    if length(I) ~= o.m
        error(message('MATLAB:mtree:internal4'));
    end
    [II,ipath,flag,rest] = pathit( o, I, ipath );
    % II has the set of nodes you get by following the path
    % everything we learn from II must be reflected back to I
    if length(II) ~= length( I )
        error(message('MATLAB:mtree:internal5'));
    end
    if flag 
        if flag<4
            error(message('MATLAB:mtree:restrict'));
        end
        % first, apply the path qualifier with no & or |
        [II,pth,flag1,rest1] = pathit( o, II, ipath );
        if flag1 ~= 0 || ~isempty(rest1) || ~isempty(pth)
            error(message('MATLAB:mtree:internal6'));
        end
        if flag < 8
            % used an & qualifier
            % we go through the elements one by one, recursively
            for i=1:o.m
                ii = II(i);
                if ii == 0
                    I(i) = 0;
                    continue;
                end
                aa = o;
                aa.IX = false(1,o.n);
                aa.IX(ii) = true;  % one element set
                aa.m = 1;
                if bitand( flag, 1 )
                    aa = List(aa);
                end
                if bitand( flag, 2 )
                    aa = Tree(aa);
                end
                aaa = restrict( aa, rest, s );
                if aaa ~= aa
                    I(i) = 0;
                end
            end
        else
            % we used an | qualifier
            % we go through the elements one by one, recursively
            for i=1:o.m
                ii = II(i);
                if ii == 0
                    I(i) = 0;
                    continue;
                end
                aa = o;
                aa.IX = false(1,o.n);
                aa.IX(ii) = true;  % one element set
                aa.m = 1;
                if bitand( flag, 1 )
                    aa = List(aa);
                end
                if bitand( flag, 2 )
                    aa = Tree(aa);
                end
                aaa = restrict( aa, rest, s );
                if isnull(aaa)
                    I(i) = 0;
                end
            end
        end
        % we've done the real work recursively
        a.IX = false(1,o.n);
        a.IX(I(I~=0)) = true;
        a.m = sum(a.IX);
        if any( a.IX & ~o.IX )
            error(message('MATLAB:mtree:internal7'));
        end
        return
    end
    % flag == 0, so no + or |
    % all the path should be consumed
    if ~isempty( ipath )
        error(message('MATLAB:mtree:internal8'));
    end
    if length(II) ~= o.m
        error(message('MATLAB:mtree:internal9'));
    end
    JX = find(II~=0);  % which elements are nonzero
    J = II(JX);  % nonzero elements
    a.IX = false( 1, a.n );  % the resulting index set
    switch rest
        
        case { 'S', 'String' }  
            % no symbol table stuff yet
            % 8 is the index for strings
            for i=1:length(J)
                % J(i) corresponds to I(JX(i))
                k = o.T(J(i),8);
                if k && any( strcmp( o.C{k}, s ) )
                    a.IX( I(JX(i)) ) = true;
                end
            end
        
        case 'StringVal'
            for i=1:length(J)
                % J(i) corresponds to I(JX(i))
                k = o.T(J(i),8);
                if k && any( strcmp( dequote(o.C{k}), s ) )
                    a.IX( I(JX(i)) ) = true;
                end
            end
            
        case { 'F', 'Fun', 'V', 'Var' }
            % no symbol table stuff yet
            % 8 is the index for strings
            % 7 is the symbol table index
            % In the symbol table, 5 is column with type flags
            id = o.K.ID;
            for i=1:length(J)
                % J(i) corresponds to I(JX(i))
                if o.T(J(i),1) ~= id
                    % not an ID
                    continue;
                end
                sx = o.T( J(i), 7 );
                if ~sx
                    continue;
                end
                % check the type bits from the symbol table...
                % The 5th column of symbol table only use three bits,
                % and using uint8 is faster than double.
                sb = bitand(uint8(o.S( sx, 5 )), uint8(6) );
                if (rest(1)=='F' && sb~=2) || (rest(1)=='V' && sb~=4)
                    continue;  % not the right kind of name
                end
                k = o.T(J(i),8);
                if k && any( strcmp( o.C{k}, s ) )
                    a.IX( I(JX(i)) ) = true;
                end
            end
            
        case 'SameID'
            % return ID's in A which agree with those in s
            % s is an object
            % 7 is the index for the symbol table
            % first, create an index set from s
            id = o.K.ID;
            xx = false( 1, size(o.S,1) );
            Q = find( s.IX );
            Q = Q( o.T( Q, 1 ) == id ); % ID's in Q
            Q = Q( o.T( Q, 7 ) ~= 0 );  % nonzero table entries
            xx( o.T( Q, 7 ) ) = true;  % true if ID is in set s
            % now, strip out indices that aren't ID's or zero table
            % entries (this can happen because the code is
            % unreachable.
            ok = o.T( II(JX), 1 ) == id & o.T( II(JX), 7) ~= 0;
            ok(ok) = xx( o.T( II(JX(ok)), 7 ) );
            a.IX( I(ok) ) = true;
            
        case {'K','Kind'}
            if isa( s, 'cell' )
                for j=1:length(s)
                    try
                        k = o.K.(s{j});  % a desired kind
                    catch x 
                        error(message('MATLAB:mtree:kind'));
                    end
                    
                    % set the elements corresponding to those
                    % elements where J has kind k
                    matches = o.T(J,1) == k;
                    a.IX( I(JX(matches)) ) = true;
                end
            else
                try
                    k = o.K.(s);
                catch x 
                      error(message('MATLAB:mtree:kind'));
                end
                % this is subtle!
                % The matches are tagged to the J vector
                % J(i) corresponds to I(JX(i))
                matches = o.T(J,1)==k;
                a.IX( I(JX(matches)) ) = true;
            end
            
        case {'A','Member'}  % another attribute
            a.IX( I( JX(s.IX(II(JX))) ) ) = true;
            
        case {'~A','~Member', 'Nonmember'} % attribute is false
            % this can succeed because II is zero, or because
            % II is nonzero and it's not in the set
            a.IX( [I( JX(~s.IX(II(JX))) ) I(II==0)] ) = true;
            
        case {'E','Empty','Null'}  % empty
            if s 
                % looking for empty stuff
                a.IX( I(II==0) ) = true;
            else
                % looking for nonempty stuff
                a.IX( I(II~=0) ) = true;
            end
            
        case { 'Isvar', 'Isfun' } % look for a variable (resp. fun)
            id = o.K.ID;
            for i=1:length(J)
                % J(i) corresponds to I(JX(i))
                if o.T(J(i),1) ~= id
                    if ~s
                        a.IX( I(JX(i)) ) = true;
                    end
                    continue;  % it's not an ID node
                end
                sx = o.T( J(i), 7 );
                if ~sx
                    if ~s
                        a.IX( I(JX(i)) ) = true;
                    end
                    continue;
                end
                % check the type bits from the symbol table...
                % The 5th column of symbol table only use three bits,
                % and using uint8 is faster than double.
                sb = bitand(uint8(o.S( sx, 5 )), uint8(6) );
                if (rest(3)=='f' && sb~=2) || (rest(3)=='v' && sb~=4)
                    if ~s
                        a.IX( I(JX(i)) ) = true;
                    end
                    continue;  % not the right kind of name
                end
                a.IX( I(JX(i)) ) = s;
            end
        case { 'Regexp', '~Regexp' }
            % no symbol table stuff yet
            % 8 is the index for strings
            % note that this is done on the StringVal
            for i=1:length(J)
                % J(i) corresponds to I(JX(i))
                k = o.T(J(i),8);
                if k 
                    ix = regexp( dequote(o.C{k}), s, 'once' );
                    if isempty(ix) 
                        if rest(1)=='~'
                            a.IX( I(JX(i)) ) = true;
                        end
                    else
                        if rest(1)=='R'
                            a.IX( I(JX(i)) ) = true;
                        end
                    end
                end
            end
            
            
        otherwise
            error(message('MATLAB:mtree:badpath', ipath));
    end
        
    a.m = sum( a.IX );
    % chk( a );
end
