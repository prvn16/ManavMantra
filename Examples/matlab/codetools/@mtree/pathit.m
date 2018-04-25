function [I,ipath,flag,rest] = pathit( o, I, ipath )
%PATHIT  [Iset,ipath,flag,rest] = PATHIT( o, I, ipath )  Mtree
%
% This function takes a path and follows the links part
% It returns an index set Iset the same size as the original set
% in o.  I has zeros where the path does not exist, and the 
% resulting node indices where they do exist.
%
% PATHIT also returns the remainder of the path in rest
%
% if * or + or & or | is seen, or their text counterparts List,
% Tree, Full, Any, or All, flag is returned nonzero, with
% bits set as follows:
%     0 if none of the above are seen
%     1 if + or List is seen, 
%     2 if * or Tree, 
%     3 if Full is seen
%     4 if & or All is seen
%     8 if | or Any is seen
%     
% If flag is 0, path is empty, and Iset contains the 
% final index set.
% If flag is nonzero, Iset has the index set before the first link
% that is qualified by one of these operators or links, path has
% the path segment that is qualified by one or more of the 
% operators, and rest has everything else

% Copyright 2006-2014 The MathWorks, Inc.

    if isa( I, 'logical' )
        error(message('MATLAB:mtree:internal2'));
    end
    flag = 0;
    rest = '';
    if isempty( ipath )
        return;
    end
    % chk( o );
    
    % pick up the segments of the path between the dots, if any
    dots = [0 strfind(ipath,'.') (length(ipath)+1)];
    j = 1;
    while j < length(dots)
        j = j + 1;
        ix = dots(j-1)+1;
        jx = dots(j)-1;
        if length(I) ~= o.m
            error(message('MATLAB:mtree:internal3'));
        end
        JX = find(I~=0);  % nonzero I indices
        pth = ipath(ix:jx);  % current path segment
        %  There are two kinds of qualifiers
        %  +, *, &, and | follow a legal path segment
        %  All, Any, List, Tree, and Full are following dot segments
        
        %  The next function collects these qualifiers
        %  If there are any, it sets pth to the current path
        %  segment, collects the qualifiers in flag, and
        %  sets j to read the next segment
        [j,flag,pth] = collect_qualifiers(pth, ipath, dots, j);
        
        if isempty( pth ) || flag >= 4
            rest = ipath( dots(j)+1:end );
            ipath = pth;
            return
        end
        
        if isempty( pth ) || flag >= 4
            rest = ipath( jx+2:end );
            ipath = pth;
            return;
        end
        switch pth   
            case 'L'
                I(JX) = o.T( I(JX), 2 );  % left
            case 'R'
                I(JX) = o.T( I(JX), 3 );  % right
            case {'X','N'}
                I(JX) = o.T( I(JX), 4 );  % next
            case 'P' 
                I(JX) = o.T( I(JX), 9 );  % parent
            case { 'Kind', 'Member', 'String', 'K', 'A', 'E', ...
                   'Empty', 'Regexp', '~Regexp','~Member', ...
                   '~A', 'Fun', 'Var', 'S', 'F', 'SameID', ...
                   'Isvar', 'Isfun', 'Null', 'StringVal' }  
                if flag
                    error(message('MATLAB:mtree:path'));
                end
                rest = ipath(ix:end);
                ipath = '';
                return;
                % agrees with LINK array in nodeinfo
            otherwise
                try
                    lix = o.Linkno.(pth);
                catch x 
                    error(message('MATLAB:mtree:pathIllegal', pth));
                end
                if isempty(JX)
                    continue;  % just find the end of the path
                end
                zok = o.Linkok( lix, o.T( I(JX), 1 ) );
                % this is very subtle!!!
                % zok has a boolean value that is true if the
                % link is OK for the associated JX value
                % If the link is not OK, it means that
                % the associated I index should be zeroed.
                
                I( JX(~zok) ) = 0;  % zero some I values
                JX = JX(zok);       % preserve the rest
                
                MM = o.Lmap{lix};
                lm = length(MM);
                for k=1:lm
                    % run the path
                    I(JX) = o.T( I(JX), MM(k) );
                    if k ~= lm 
                        JX = find(I~=0);
                    end
                end
        end
        ix = jx+2;
        if flag
            ipath = ipath( ix:end );
            return
        end
    end
    ipath = '';
end
