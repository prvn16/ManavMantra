function x = mtree_info(n)
%MTREE_INFO  x = MTREE_INFO(n)  Low-level initialization helper fcn
%   Used to do static initializion of N, K, and KK

% Copyright 2006-2014 The MathWorks, Inc.

    persistent N K KK
    if isempty(N)
        [N,K,v] = mtreemex;
        if ~strcmp( v, mtree.V{2} )
            error(message('MATLAB:mtree:version', mtree.V{ 2 }, v));
        end
        KK = fieldnames( K );
    end
    persistent LNK LMAP LOK
    persistent Uop Bop Stmt
    if isempty(LNK)
        [LNK,LMAP,LOK] = nodeinfo();
    end
    if n==1
        x = N;
    elseif n==2
        x = K;
    elseif n==3
        x = KK;
    elseif n==4   % unary ops
        x = false( 1, length(KK) );
        s = { 'DOTTRANS' 'TRANS' 'NOT' 'QUEST' 'UMINUS' 'UPLUS', ...
                        'ROW' 'AT', 'LC', 'LB' };
        for i=1:length(s)
            x( K.(s{i}) ) = true;
        end
        Uop = x;
    elseif n==5   % binary ops
        x = false( 1, length(KK) );
        s = {'DOTLP' 'PLUS' 'MINUS' 'MUL' 'DIV' 'LDIV' 'EXP' 'COLON' 'DOT', ...
          'DOTMUL', 'DOTDIV', 'DOTLDIV', 'DOTEXP', 'AND', 'OR', ...
          'ANDAND' 'OROR', 'LT', 'GT', 'LE', 'GE', 'EQ', 'NE', ...
          'CELL', 'SUBSCR', 'ANON', 'ATBASE', 'ATTR' };
        for i=1:length(s)
            x( K.(s{i}) ) = true;
        end
        Bop = x;
    elseif n==6   % statements
        x = false( 1, length(KK) );
        s =     {'EXPR' 'PRINT' 'GLOBAL' 'PERSISTENT' 'DCALL' ...
                 'BREAK' 'RETURN', 'CONTINUE' 'WHILE' 'SWITCH' ...
                 'CASE' 'IF' 'TRY' 'FOR' 'PARFOR' 'OTHERWISE' ...
                 'DISTFOR' 'CELLMARK' 'COMMENT' 'BLKCOM' 'SPMD' ...
                 'PROPTYPEDECL' };
        for i=1:length(s)
            x( K.(s{i}) ) = true;
        end
        Stmt = x;
    elseif n==7 % link names
        x = LNK;
    elseif n==8 % link map
        x = LMAP;
    elseif n==9 % is link OK with a node
        x = LOK;
    elseif n==10
        x = Uop | Bop | Stmt;
        x( [K.PARENS K.LP K.RP K.LB K.CALL K.SUBSCR ...
               K.FUNCTION K.CLASSDEF K.PROPERTIES ...
               K.EVENTS K.METHODS K.ENUMERATION K.ETC] ) = true;
    end
end
