function s = tt2ss( S, ind, top, map, xmap )
%TT2SS  s = tt2ss( S, ind, top, map, xmap )
%  A non-MCOS version of tree2str, rewritten for speed
% Copyright 1984-2017 The MathWorks, Inc.

    kcom = mtree.K.COMMENT;
    kbcom = mtree.K.BLKCOM;
    kcell = mtree.K.CELLMARK;
    T = S.T;
    C = S.C;
    IX = indices(S);
    s = '';
    persistent opclass opinfo KK K
    if isempty( opinfo )
        opclass = zeros( 1, length( mtree.KK ) );
        opinfo = cell( length( mtree.KK ), 3 );
        % expression cases
        %   0:  leaf
        %   1:  unary prefix
        %   2:  binary
        %   3:  unary suffix ('),
        %   4:  indexing, etc.
        %   5:  =
        %   6:  .
        %   7:  [ ] initialization
        %   8:  { } initialization
        %   9:  ROW
        %  10:  ANON
        %  11:  ATTR
        %  12:  ATBASE
        %  13:  illegal
        % two strings supplied as well
        %       opcode    prec case s1      s2
        precs = {
                'ID'        0   0   ''      ''
                'ANONID'    0   0   ''      ''
                'INT'       0   0   ''      ''
                'DOUBLE'    0   0   ''      ''
                'DUAL'      0   0   ''      ''
                'CHARVECTOR' 0   0  ''      ''
                'STRING'    0   0   ''      ''
                'PARENS'   15   1   '('     ')'
                'RP'        1  13   ''      ''
                'RC'        1  13   ''      ''
                'RB'        1  13   ''      ''
                'EQUALS'    2   5   '='     ''
                'ATTR'      2  11   '='     ''
                'OROR'      3   2   ' || '  ''
                'ANDAND'    4   2   ' && '  ''
                'OR'        5   2   ' | '   ''
                'AND'       6   2   ' & '   ''
                'GT'        7   2   '>'     ''
                'LT'        7   2   '<'     ''
                'GE'        7   2   '>='    ''
                'LE'        7   2   '<='    ''
                'EQ'        7   2   '=='    ''
                'NE'        7   2   '~='    ''
                'COLON'     8   2   ':'     ''
                'PLUS'      9   2   ' + '   ''
                'MINUS'     9   2   ' - '   ''
                'MUL'      10   2   '*'     ''
                'DOTMUL'   10   2   ' .* '  ''
                'DIV'      10   2   '/'     ''
                'DOTDIV'   10   2   ' ./ '  ''
                'LDIV'     10   2   '\'     ''
                'DOTLDIV'  10   2   ' .\ '  ''
                'NOT'      11   1   '~'     ''
                'AT'       11   1   '@'     ''
                'UMINUS'   11   1   '-'     ''
                'UPLUS'    11   1   '+'     ''
                'EXP'      12   2   '^'     ''
                'DOTEXP'   12   2   ' .^ '  ''
                'DOTTRANS' 13   1   ''      '.'''
                'QUEST'    13   1   '?'     ''
                'TRANS'    14   3   ''''    ''   % separate line to handle ('abc')'
                'LP'       15   4   '( '    ' )'
                'CALL'     15   4   '( '    ' )'
                'SUBSCR'   15   4   '( '    ' )'
                'CELL'     15   4   '{ '    ' }'
                'LC'       15   8   '{'     '}'
                'LB'       15   7   '['     ']'
                'DOT'      15   6   '.'     ''
                'ATBASE'   15  12   '@'     ''
                'DOTLP'    15   4   '.('	')'
                'ROW'       2   9   ';'     ''
                'ANON'      2  10   '@('    ')'
%                'DOTID'    15   0   ''      ''    % K doesn't define yet
            };
        % statement cases
        %  1:  function
        %  2:  class
        %  3:  properties
        %  4:  methods
        %  5:  events
        %  6:  enumeration
        %  7:  expr and print
        %  8:  if/ifhead/elseif/else
        %  9:  while
        % 10:  for, parfor, distfor
        % 11:  try/catch
        % 12:  break, continue, return
        % 13:  switch
        % 14:  case
        % 15:  otherwise
        % 16:  global / persistent
        % 17:  dual call
        % 18:  bang
        % 19:  CELLMARK
        % 20:  PROTO
        % 21:  SPMD
        % 22:  Comment
        % 23:  Block comment
        % 24:  Typed property declaration
        stmts = {
                'FUNCTION'     -1   1   'function'      ''
                'CLASSDEF'     -1   2   'classdef'      ''
                'PROPERTIES'   -1   3   'properties'    ''
                'METHODS'      -1   4   'methods'       ''
                'EVENTS'       -1   5   'events'        ''
                'ENUMERATION'  -1   6   'enumeration'   ''
                'EXPR'         -2   7   ';'             ''
                'PRINT'        -2   7   ''              ''
                'IF'           -2   8   'if '           ''
                'IFHEAD'       -2   8   'if '           ''
                'ELSEIF'       -2   8   'if '           ''
                'ELSE'         -2   8   'if '           ''
                'WHILE'        -2   9   'while '        ''
                'FOR'          -2  10   'for '          ''
                'PARFOR'       -2  10   'parfor '       ''
                'DISTFOR'      -2  10   'for '          ''
                'TRY'          -2  11   'try'           'catch'
                'BREAK'        -2  12   'break'         ''
                'CONTINUE'     -2  12   'continue'      ''
                'RETURN'       -2  12   'return'        ''
                'SWITCH'       -2  13   'switch '       ''
                'CASE'         -3  14   'case '         ''
                'OTHERWISE'    -3  15   'otherwise'     ''
                'GLOBAL'       -2  16   'global '       ''
                'PERSISTENT'   -2  16   'persistent '   ''
                'DCALL'        -2  17   ''              ''
                'BANG'         -2  18   ''              ''
                'CELLMARK'     -2  19   ''              ''
                'PROTO'        -2  20   ''              ''
                'SPMD'         -2  21   'spmd'          ''
                'COMMENT'      -2  22   ''              ''
                'BLKCOM'       -2  23   ''              ''
                'PROPTYPEDECL' -2  24   ''              ''
            };
        KK = mtree.KK;
        K = mtree.K;
        for ii=1:length( precs )
            ixx = K.(precs{ii,1});
            opclass(ixx) = precs{ii,2};
            [opinfo{ ixx,1:3 }] = deal( precs{ii,3:5} );
        end
        for ii=1:length( stmts )
            ixx = K.(stmts{ii,1});
            opclass(ixx) = stmts{ii,2};
            [opinfo{ ixx,1:3 }] = deal( stmts{ii,3:5} );
        end
    end
    n = size( T, 1 );    % a bit larger than o.n
    if isempty(IX)
        return;
    end    
    if nargin < 2
        ind = 0;
    end
    if nargin < 3
        top = false;
    end
    if nargin < 4
        map = {};
    end
    if nargin < 5
        map = map(:);   % make it one dimensional
        xmap = zeros( 1, n );
        for imp=1:2:length(map)
            xmap( indices( map{imp} ) ) = imp+1;
            if ~ischar( map{imp+1} )
                error(message('MATLAB:mtree:tree2str:mapstr'));
            end
        end
    end
    sout = ' ';
    sout(8*n) = ' ';
    k = 0;
    if top
        % loop over IX, collecting info
        for iix=IX
            stmt2str( iix, ind, true );
        end
    else
        % it's a List, so just pass the first one...
        stmt2str( IX(1), ind, false );
    end
    s = sout(1:k);

    function scat( s, ind )
        n = length(s);
        if nargin > 1 && ind
            if k+4*ind > length(sout)
                sout = [ sout sout ];
            end
            kk = k + 4*ind;
            %if kk > length( sout )
            %    for i=1:4*ind
            %        sout(k+i) = ' ';
            %    end
            %end
            sout( k+1:kk ) = ' ';
            k = kk;
        end
        if n
            kk = k+n;
            if kk > length(sout)
                sout = [ sout sout ];
            end
        %for ij=1:n
        %    sout( k+ij ) = s(ij);
        %end
            sout( (k+1):kk ) = s;
            k = kk;
        end
    end
    function ix = ixpath( ix, s )
        if ~ix
            return;
        end
        switch( s )
            case { 'L' 'Left' 'Arg' 'Try' 'Attr' }
                ix = T(ix,2);
                return;
            case { 'R' 'Right' 'Body' }
                ix = T(ix,3);
                return;
            case { 'Next' 'X' 'N' }
                ix = T(ix,4);
                return;
            case 'P'
                ix = T(ix,9);
                return;
            case {'CatchID' }
                pth = [3 2];
            case {'Catch' }
                pth = [3 3];
            case 'Ins'
                pth = [2 3 3];
            case { 'Outs' 'Index' 'Cattr' }
                pth = [2 2];
            case  { 'Vector' 'Cexpr'}
                pth = [2 3 ];
            case 'L.N'
                pth = [ 2 4 ];
            case 'Fname'
                pth = [2 3 2];
            otherwise
                error(message('MATLAB:mtree:tree2str:ixpath', s));
        end
        ix = T(ix, pth(1) );
        for ixj=2:length(pth)
            if ~ix
                return;
            end
            ix = T(ix,pth(ixj));
        end
    end
    function n = ixlength( ix )
        n = 0;
        while ix
            n = n + 1;
            ix = T( ix, 4 );
        end
    end
    function ss = ixstring( ixt )
        ss = '';
        if ~ixt
            return;
        end
        if xmap(ixt)
            ss = map{xmap(ixt)};
            return;
        end
        six = T(ixt,8);
        if ~six
            return;
        end
        ss = C{six};
    end
    function ixc = followcom( s, ixt, top )
    % We look for a string of comments.  If none, or if we do not find
    % one that follows the current statement (trailing comment) on the
    % same line, we print s and return.
    % Otherwise we print s and the trailing comment, then print all
    % the comments up to the trailing comment, and then return ixc.
    % ixt: index to the current node
    % top: false if we include nodes on the Next link
    % ixc: index to the next comment node (if not, return ixt)
        if top
            % We don't look at the next one, since
            % we aren't allowed to.
            % Print s and return.
            scat( [s 10] );
            ixc = ixt;
            return
        end
        if T(ixt,1)==K.ID
            endpos = T(ixt,5);  % position of the node (for Identifier)
        else
            endpos = T(ixt,7);  % position end of statement
        end
        %fprintf( 'index %d, endpos %d\n', ixt, endpos );

        % Find the first location of possible comment by traverse through Next link
        ixcf = T(ixt,4);
        if ~ixcf || ( T(ixcf,1) ~= kcom && T(ixcf,1) ~= kbcom && ...
                                          T(ixcf,1) ~= kcell )
            % Next node is not a comment.
            % Print s and return.
            ixc = ixt;
            scat( [s 10] );
            return
        end
        
        % The Next node, and possibly following ones, are comments
        % Look for one that follows the statement
        ixc = ixcf;
        last = false;
        while true
            % ixc is a COMMENT, BLKCOM, or CELLMARK
            % cpos is the position of this comment
            cpos = T(ixc,5);
            if cpos > endpos
                % If the position of this comment is after the statement,
                % we will not look at any following comments, because
                % they will never be on the same line of this statement.
                last = true;
            end
            if T(ixc,1) ~= kcom
                % not a COMMENT -- keep going
                ixc = T(ixc,4);
                if last && ~ixc || ( T(ixc,1)~= kcom && ...
                                     T(ixc,1) ~= kbcom && ...
                                     T(ixc,1) ~= kcell )
                    % no trailing comments, Print s and return.
                    ixc = ixt;
                    scat( [s 10] );
                    return
                end
                continue
            end
            % ixc is a COMMENT -- see if it is at the end (on the same line) of ixt
            if cpos > endpos && endpos > 0
                % The statement can be terminated by EOL, in that case
                % endpos is EOL.
                ins = S.str( endpos:cpos );
            elseif cpos > endpos
                ins = S.str( endpos+1:cpos );
            else
                ins = S.str( cpos:endpos-1 );
            end
            if any( ins==10 )
                % If there is a newline between previous statement and
                % comment, look at next comment.
                ixc = T(ixc,4);
                if last || ~ixc || ( T(ixc,1)~= kcom && ...
                                     T(ixc,1) ~= kbcom && ...
                                     T(ixc,1) ~= kcell )
                    % no trailing comments, Print s and return.
                    ixc = ixt;
                    scat( [s 10] );
                    return
                end
                continue;   % just continue
            end
            % We found a comment that is on the same line of the statement.
            scat( [s '  ' ixstring(ixc) 10] );  % put it on the same line of the statement.
            % Before returning ixc, we print all the comments
            % between ixt and ixc
            ix = ixcf;
            while ix ~= ixc
                stmt2str( ix, ind, true );  % print comment
                ix = T(ix,4);
            end
            return
        end
    end

    function ixt = bodycom( s, ixt )
        % this acts like followcom, but looks at the Body (or similar)
        % for the same-line comment.  We don't need to worry about other
        % comments getting in the way...
        pos = T(ixt,5);
        ixt = T(ixt,3);   % the body or right-hand size
        if ~ixt || T(ixt,1)~=kcom
            % complete the previous line, and continue down the body
            scat( [ s 10 ] );
            return
        end
        cpos = T(ixt,5);
        ins = S.str( pos:cpos );
        if any( ins==10 )
            % just finish current, start again on the body
            scat( [ s 10 ] );
            return
        end
        % output the comment, continue on next one
        scat( [s '  ' ixstring(ixt) 10] );
        ixt = T(ixt,4);
    end
    function ixt = trycom( s, ixt )
        % this acts like bodycom, but looks at the left (Try) side
        % for the same-line comment.  We don't need to worry about other
        % comments getting in the way...
        pos = T(ixt,5);
        ixt = T(ixt,2);   % the Try or left-hand size
        if ~ixt || T(ixt,1)~=kcom
            % complete the previous line, and continue down the body
            scat( [ s 10 ] );
            return
        end
        cpos = T(ixt,5);
        ins = S.str( pos:cpos );
        if any( ins==10 )
            % just finish current, start again on the body
            scat( [ s 10 ] );
            return
        end
        % output the comment, continue on next one
        scat( [s '  ' ixstring(ixt) 10] );
        ixt = T(ixt,4);
    end

    function stmt2str( ixt, ind, top )
        if nargin < 3
            top = false;
        end
        while ixt
            if imap( ixt )
                if top
                    return;
                end
                ixt = T(ixt,4);
                continue;
            end
            
            % here is a tree to do
            op = T(ixt,1);
            %kk = KK{op};
            if opclass( op ) >= 0
                % oops, it's an expression.  But that's OK.  The
                % indentation is just the precedence--we ignore top
                expr2str( ixt, ind );
                return;
            end
            switch opinfo{ op, 1 }
                case 1  %'FUNCTION'
                    fix = ixpath( ixt, 'Ins' );
                    fox = ixpath( ixt, 'Outs' );
                    % call tree2str to get mapping
                    if fox
                        if ixlength(fox)==1
                            scat( ['function ' ixstring(fox) ' = ' ], ind );
                        else
                            scat( 'function [', ind );
                            list2str(fox, ',' );
                            scat( '] = ' );
                        end
                    else
                        scat( 'function ', ind );
                    end
                    expr2str( ixpath( ixt, 'Fname' ), 0 );
                    if fix
                        scat( '(' );
                        list2str( fix, ',');
                        ibt = bodycom( ')', ixt );
                    else
                        ibt = bodycom( '', ixt );
                    end
                    stmt2str( ibt, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 2 %'CLASSDEF'      
                    scat( 'classdef ', ind );
                    av = ixpath( ixt, 'Cattr' );
                    if av
                        attrs( av );
                        scat( ' ' );
                    end
                    cx = ixpath( ixt, 'Cexpr' );
                    if ~imap( cx )
                        expr2str( cx );
                    end
                    B = bodycom( '', ixt );
                    stmt2str( B, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 3 %'PROPERTIES'
                    scat( 'properties ', ind );
                    attrs( ixpath( ixt, 'Attr' ) );
                    B = bodycom( '', ixt );
                    props( B, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 4 % 'METHODS'
                    scat( 'methods ', ind );
                    attrs( ixpath( ixt, 'Attr' ) );
                    B = bodycom( '', ixt );
                    stmt2str( B, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 5 % 'EVENTS'
                    scat( 'events ', ind );
                    attrs( ixpath( ixt, 'Attr' ) );
                    B = bodycom( '', ixt );
                    evnts( B, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 6 % 'ENUMERATION'
                    scat( 'enumeration ', ind );
                    attrs( ixpath( ixt, 'Attr' ) );
                    B = bodycom( '', ixt );
                    enums( B, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 7 % 'EXPR' and 'PRINT'
                    scat( '', ind );   % indentation
                    expr2str( T(ixt,2), 1 );
                    ixt = followcom( opinfo{op,2}, ixt, top );
                case 8 % 'IF'            
                    scat( 'if ', ind );
                    ixtt = T(ixt,2);      % find the IFHEAD
                    if ~imap( ixtt )
                        expr2str( T(ixtt,2), 1 );   % condition
                        ibt = bodycom( '', ixtt );
                        % the 'Then' part
                        stmt2str( ibt, ind+1 );
                    end
                    % now, handle ELSEIF and ELSE nodes
                    % we tell the difference because ELSE has left descendent null
                    while true
                        ixtt = T(ixtt, 4 );   % next piece of IF statement
                        if ~ixtt
                            break
                        end
                        if ~imap( ixtt )
                            if T(ixtt,2)  % elseif
                                scat( 'elseif ', ind );
                                expr2str( T(ixtt,2), 1 );
                            else
                                scat( 'else', ind );
                            end
                            ibt = bodycom( '', ixtt );
                            stmt2str( ibt, ind+1 );
                        end
                    end
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 9 % 'WHILE'
                    scat( 'while ', ind  );
                    expr2str( T(ixt,2), 1 );
                    ibt = bodycom( '', ixt );
                    stmt2str( ibt, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 10 % 'FOR', 'PARFOR'          
                    ees = ixpath( ixt, 'L.N' ); % expression list
                    if ees  % parfor with expressions
                        scat( ['parfor( ' ixstring( ixpath( ixt, 'Index' ) ) ' = '], ind );
                        expr2str( ixpath( ixt, 'Vector' ), 1 );
                        scat( ', ' );
                        list2str( ees, ', ' );
                        scat( ' )' );
                    else
                        scat( [opinfo{op,2} ixstring( ixpath( ixt, 'Index' ) ) ' = '], ind );
                        expr2str( ixpath( ixt, 'Vector' ), 1 );
                        scat( [ opinfo{op,3} ] );
                    end
                    ibt = bodycom( '', ixt );
                    stmt2str( ibt, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 11 % 'TRY'
                    scat( 'try', ind );
                    itb = trycom( '', ixt );
                    stmt2str( itb, ind+1 );
                    % there might be a CATCH node with no contents
                    cn = T( ixt, 3 );  
                    if cn
                        scat( 'catch', ind );
                        tcx = T( cn, 2 ); 
                        if tcx
                            scat( [' ' ixstring(tcx)] );
                        end
                        tc = bodycom( '', cn );
                        if tc 
                            stmt2str( tc, ind+1 );
                        end
                    end
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 12 % 'BREAK', 'CONTINUE', 'RETURN'         
                    scat( opinfo{op,2}, ind );
                    ixt = followcom( '', ixt, top );
                case 13 % 'SWITCH'  
                    scat( 'switch ', ind );
                    expr2str( T(ixt,2), 1 );
                    ibt = bodycom( '', ixt );
                    stmt2str( ibt, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 14 % 'CASE'
                    scat( 'case ', ind );
                    TL = ixpath( ixt, 'L' );
                    if ixlength( TL ) > 1
                        scat( '{' );
                        list2str( TL, ', ' );
                        scat( '}' );
                    else
                        expr2str( TL, 1 );
                    end 
                    ibt = bodycom( '', ixt );
                    stmt2str( ibt, ind+1 );
                case 15 % 'OTHERWISE'
                    scat( 'otherwise', ind );
                    ibt = bodycom( '', ixt );
                    stmt2str( ibt, ind+1 );
                case 16 % 'GLOBAL', 'PERSISTENT'        
                    scat( opinfo{ op, 2 }, ind );
                    list2str( T(ixt,2), ' ' );
                    ixt = followcom( '', ixt, top );
                case 17 % 'DCALL'         
                   scat( [ixstring( ixpath( ixt, 'L' ) ) ' '], ind );
                   list2str( ixpath( ixt, 'R' ), ' ' );
                   % if T(ixt,7)  % command dual followed by ;
                   if S.str( T(ixt,7) ) == ';'   % command dual, then ;
                       scat( ' ;' );
                   end
                   ixt = followcom( '', ixt, top );
                case 18 % 'BANG'
                    scat( ixstring( ixt ), ind );
                    ixt = followcom( '', ixt, top );
                case 19 % 'CELLMARK'
                    scat( [strtrim(ixstring( ixt )) 10 ], ind );
                case 20 % 'PROTO'
                    fix = ixpath( ixt, 'Ins' );
                    fox = ixpath( ixt, 'Outs' );
                    if fox
                        if ixlength(fox)==1
                            scat( [ixstring(fox) ' = ' ], ind );
                        else
                            scat( '[', ind );
                            list2str(fox, ',' );
                            scat( '] = ' );
                        end
                    end
                    expr2str( ixpath( ixt, 'Fname' ), 0 );
                    if fix
                        scat( '(' );
                        list2str( fix, ',');
                        scat( ')' );
                    end
                    ixt = followcom( '', ixt, top );
                case 21 % 'SPMD'
                    scat( 'spmd ', ind );
                    TL = ixpath( ixt, 'L' );
                    if TL
                        scat( '( ' );
                        TL = ixpath( ixt, 'L' );
                        list2str( ixpath( TL, 'L' ), ',' );
                        scat( ' )' );
                    end
                    ibt = bodycom( '', ixt );
                    stmt2str( ibt, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 22 % comment
                    comstring = strtrim( ixstring(ixt) );  % strip blanks
                    if isempty(comstring) || comstring(1) ~= '%'
                        comstring = [ '%  ' comstring ];  %#ok<AGROW> % for ... comments
                    end
                    scat( [comstring 10], ind );
                case 23 % block comment
                    scat( [ '%{' 10 ], ind );
                    stmt2str( T(ixt,2), 0, false );
                    scat( [ '%}' 10 ], ind );

                case 24 % typed property decl
                    expr2str( T(ixt,2), 2 );
                    vr = T(ixt, 3);

                    cnode = false; snode = false; vnode = false;
                    if vr ~= 0
                        cnode = T(vr, 2);
                        vr = T(vr, 3);
                        if vr ~= 0
                            snode = T(vr, 2);
                            vr = T(vr, 3);
                            if vr ~= 0
                                vnode = T(vr, 2);
                            end
                        end
                    end
                    if snode
                        scat (' ('); list2str(snode, ', '); scat(')');
                    end
                    if cnode
                        scat( [ ' ' ixstring( cnode ) ] )
                    end
                    if vnode
                        scat (' {'); list2str(vnode, ', '); scat('}');
                    end

                otherwise
                    error(message('MATLAB:mtree:tree2str:badStatement', KK{ op }));
            end
            if top
                return
            end
            ixt = T(ixt,4);
        end
    end
    function attrs( ixt )
        % attribute list is ATTR nodes with attribute on lhs,
        % value on rhs
        if ~ixt || imap( ixt )
            return;
        end
        ixt = T(ixt,2);
        scat( '(' );
        sep = '';
        while ixt
            if ~imap(ixt)
                lhs = T( ixt, 2 );
                rhs = T( ixt, 3 );
                if ~rhs 
                    scat( [sep ixstring( lhs ) ] );
                elseif T(rhs,1)==K.NOT && ~T(rhs,2)
                    scat( [sep '~' ixstring( lhs )] );
                else
                    scat( [sep ixstring( T(ixt,2) ) '='] );
                    expr2str( T(ixt,3) ); 
                end
                sep = ', ';
            end
            ixt = T(ixt,4);
        end
        scat( ')' );
    end
    function props( ixt, ind )
        while ixt
            if ~imap( ixt )
                if T(ixt,1)==kcom || T(ixt,1)==kbcom || T(ixt,1)==kcell
                    stmt2str( ixt, ind, true );
                    ixt = T(ixt,4);
                    continue;
                end
                rt = T(ixt,3);
                scat( '', ind );
                typeop = T(T(ixt, 2), 1);
                if typeop
                    if opclass( typeop ) >= 0
                        expr2str( T(ixt,2) );
                    else
                        stmt2str( T(ixt, 2) );
                    end
                end
                if rt
                    scat( ' = ' );
                    expr2str( rt );
                end
                ixt = followcom( '', ixt, false );
            end
            ixt = T(ixt,4);
        end
    end
    function evnts( ixt, ind )
        while ixt
            if imap( ixt )
                ixt = T(ixt,4);
                continue;
            end
            if T(ixt,1)==kcom||T(ixt,1)==kbcom||T(ixt,1)==kcell
                stmt2str( ixt, ind, true );  % print comment
            else
                rt = T(ixt,3);
                scat( ixstring( T(ixt,2) ), ind );
                if rt
                    scat( '(' );
                    expr2str( rt );
                    scat( ')' );
                end
                ixt = followcom( '', ixt, false );
            end
            ixt = T(ixt,4);
        end
    end
    function enums( ixt, ind )
        while ixt
            if imap( ixt )
                ixt = T(ixt,4);
                continue;
            end
            if T(ixt,1)==kcom || T(ixt,1)==kbcom || T(ixt,1)==kcell
                % print a comment
                stmt2str( ixt, ind, true );
            else
                scat( '', ind );  % just do the indentation
                expr2str( ixt, 1 );
                ixt = followcom( '', ixt, false );
            end
            ixt = T(ixt,4);
        end                
    end

    function b = imap( ixt )
        if xmap(ixt)
            scat( map{xmap(ixt)} );
            b = true;
            return;
        else
            b = false;
        end
    end

    function expr2str( ixt, lev )
        % T is a node
        if ~ixt 
            return;
        end
        if nargin < 2
            lev = 1;
        end
        if imap(ixt)
            return;
        end
        close = '';
        tlev = lev;
        op = T(ixt,1);
        switch( opinfo{ op, 1 } )
            case 0    %  leaf nodes
                scat( [ ixstring( ixt ) close] );
                return;
            case 1    %  unary operators
                scat( opinfo{ op, 2 } );
                expr2str( T(ixt,2), tlev );
                scat( [ opinfo{ op, 3 } close ] );
                return;
            case 2    %  binary operators
                binary( ixt, opinfo{ op, 2 }, tlev );
                scat( [ opinfo{ op, 3 } close ] );
                return;
            case 3    %  unary suffix (')
                a = T( ixt, 2 );
                if T(a,1) == K.CHARVECTOR
                    % need parens
                    scat( '(' );
                    expr2str( a, 0 );
                    scat( [')''' close] );
                else
                    expr2str( a, tlev );
                    scat( ['''' close] );
                end
                return;
          case 4    %  indexing, etc.
                rx = T(ixt,3);
                if ~rx
                    % should only happen for calls
                    lx = T(ixt,2);
                    knd = T(ixt,1);
                    expr2str( lx, tlev );
                    % a MATLAB mess--if the opcode is SUBSCR, print ()
                    % also, if the CALL node does not have the same
                    % position as the LHS, generate ()
                    if knd == K.SUBSCR || knd == K.LP || ...
                            (knd == K.CALL && T(lx,5)~=T(ixt,5))
                        scat( [ '()' close] );   % print a()
                    else
                        scat( close );
                    end
                else
                    expr2str( T(ixt,2), tlev );
                    scat( opinfo{ op, 2 } );
                    list2str( T(ixt,3), ', ' );
                    scat( [ opinfo{ op, 3 } close ] );
                end 
                return
            case 5    %  =
                lhs = T(ixt,2);
                rhs = T(ixt,3);
                if lhs && ~imap( lhs )
                    if T(lhs,1)==K.LB
                        lhslist = T(lhs,2);
                        scat( '[' );
                        list2str( lhslist, ',' );
                        scat( ']' );
                    else
                        expr2str( lhs, tlev );
                    end
                end
                scat( ' = ' );
                if rhs && ~imap( rhs )
                    expr2str( rhs, tlev );
                end
                scat( close );
                return
            case 6	  %  .
                expr2str( T(ixt,2), tlev );
                scat( [ '.' ixstring( T(ixt,3) ) close ] );
                return;
            case 7    %  [] initialization    
                tr = T(ixt,2);
                if ~tr
                    scat( ['[]' close] );
                else
                    scat( '[ ' );
                    list2str( tr, '; ' );
                    scat([ ' ]' close] );
                end
                return;
            case 8	  %  {} initialization
                tr = T(ixt,2);
                if ~tr
                    scat( ['{}' close] );
                else
                    scat( '{ ' );
                    list2str( tr, '; ' ); 
                    scat( [' }' close] );
                end
                return;
            case 9    %  ROW
                ta = T(ixt,2);
                if ta
                    list2str( ta, ', ');
                end
                scat( close );
                return;
            case 10   %  ANON
                scat( '@(' );
                list2str( T(ixt,2), ',' );
                scat( ') ' );
                expr2str( T(ixt,3), 2 );
                scat( close );
                return;
            case 11     %  ATTR
                attrs( ixt );
                return;
            case 12     %  ATBASE
                
                expr2str( T(ixt,2), 2 );
                scat( '@' );
                vr = T(ixt,3);
                sep = '';
                while( vr )
                    scat( [ sep ixstring(vr) ] );
                    vr = T(vr,4);  % next one
                    sep = ' ';
                end
                return
            otherwise   %  other
                error(message('MATLAB:mtree:tree2str:unknownExpr', mtree.KK{ op }));
        end
    end
    % this is more subtle than it looks
    % if we have a*b*c, this naturally parses as
    %     (a*b)*c
    % if we see a tree that looks like
    %     a*(b*c)
    % we need to put parens back in to preserve this
    % we can get this effect by upping the precedence on the rhs
    % TODO:  with PARENS, is this logic still needed?
    % TODO:  what's the best way to make substitutions OK w.r.t. parens?
    function binary( ixt, ss, lev )
        if imap( ixt )
            return;
        end
        vr = T(ixt,3);
        expr2str( T(ixt,2), lev );
        scat( ss );
        expr2str( vr, lev+1 );
    end
    function list2str( ixt, ss )
        later = false;
        while ixt
            if later
                scat( ss );
            end
            later = true;
            if ~imap(ixt)
                expr2str( ixt, 1 );
            end
            ixt=T(ixt,4);
        end
    end
end

