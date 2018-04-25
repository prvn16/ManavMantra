function [L,MAPS,z] = nodeinfo()
%NODEINFO  [L,MAPS,z] = NODEINFO()  Low-level initialization helper fcn

% Copyright 2006-2016 The MathWorks, Inc.

    [~,K] = mtreemex;
    LINK = {
        'Left',            2;
        'Right',           3;
        'Next',            4;
        'Body',            3;
        'Arg',             2;
        'Fname',          [2 3 2];
        'Ins',            [2 3 3];
        'Outs',           [2 2];
        'Index',          [2 2];
        'Vector',         [2 3];
        'Cexpr',          [2 3];
        'Cattr',          [2 2];
        'Attr',            2;
        'Try',             2;
        'Catch',          [3 3];
        'CatchID',        [3 2];
        'VarName',         2;
        'VarType',        [3 2];
        'VarDimensions',  [3 3 2];
        'VarValidators',  [3 3 3 2];
        'Parent',          9
    };

    n = length(LINK);
    lnk = cell( 2, n );
    lnk(1,:) = LINK(:,1)';
    lnk(2,:) = num2cell( 1:n );
    L = struct( lnk{:} );
    
    MAPS = LINK(:,2)';
    
    KN = fieldnames(K);
    k = length(KN);
    z = false( n, k );
    saw_op = false( 1, k );
         
    bops = { 'DOTLP' 'PLUS' 'MINUS' 'MUL' 'DIV' 'LDIV' 'EXP' 'COLON' 'DOT' ...
          'DOTMUL' 'DOTDIV' 'DOTLDIV' 'DOTEXP' 'AND' 'OR' 'ANDAND' 'OROR' ...
          'LT' 'GT' 'LE' 'GE' 'EQ' 'NE' 'EQUALS' 'CELL' 'SUBSCR' 'CALL' ...
          'DCALL' 'LP' 'ANON' 'EVENT' 'ATBASE' 'ATTR' 'JOIN' 'CEXPR' };  
      
    uops = { 'DOTTRANS' 'TRANS' 'NOT' 'QUEST' 'UMINUS' 'UPLUS', ...
             'ROW' 'EXPR' 'PRINT', 'GLOBAL', 'PERSISTENT' 'AT', ...
             'LC', 'LB', 'BLKCOM' 'ATTRIBUTES' 'PARENS' 'IF' };
      
    leaves = { 'ID' 'INT' 'DOUBLE' 'CHARVECTOR' 'STRING' 'DUAL' 'BANG' 'ANONID', ...
               'FIELD', 'ERR', 'BREAK', 'RETURN', 'CONTINUE', 'CELLMARK', ...
               'COMMENT' };
           
    illegal = { 'ERROR' 'COMMA' 'EOL' 'END' 'LIST', 'SEMI', ...
                'RP' 'RB' 'RC', 'ETC', 'BLKEND' 'DISTFOR' };
      
    lbody = { 'WHILE' 'SWITCH' 'CASE' 'CATCH' 'SPMD' 'IFHEAD' 'ELSEIF'};
    
    elother = { 'ELSE', 'OTHERWISE' };
    
    xtry = { 'TRY' };
    
    xfun = { 'FUNCTION' 'PROTO' };
    
    xfor = { 'FOR', 'PARFOR' 'OLDFUN' };
    
    cls = { 'CLASSDEF' };
    
    sect = { 'PROPERTIES' 'METHODS' 'EVENTS' 'ENUMERATION' };
    
    typedProperties = { 'PROPTYPEDECL' };
  
    % links allowed for various types
    % we add Next and Parent later
    ni = {
            bops, { 'Left', 'Right' };
            uops, { 'Arg' };
            leaves, {};
            illegal, {};
            lbody, { 'Left', 'Body' };
            elother, { 'Body' };
            xtry, { 'Try', 'Catch' 'CatchID' };
            xfun, { 'Fname', 'Ins', 'Outs', 'Body' };
            xfor, { 'Index', 'Vector', 'Body' };
            cls, { 'Cexpr', 'Cattr', 'Body' };
            sect, { 'Attr', 'Body' };
            typedProperties, { 'VarName', 'VarType', 'VarDimensions', 'VarValidators' };
         };
    
    for i=1:length(ni)
        ops = ni{i,1};
        links = ni{i,2};
        z1 = zeros( 1, length(links) );
        z2 = zeros( 1, length(ops) );
        for ii=1:length(links)
            z1(ii) = L.(links{ii});
        end
        for ii=1:length(ops)
            z2(ii) = K.(ops{ii});
        end
        if any( saw_op(z2) )
            error(message('MATLAB:mtree:op1', ops{ find( saw_op( z2 ), 1 ) }, i));
        end
        saw_op(z2) = true;
        if any( z(z1,z2)~=0 )
            error(message('MATLAB:mtree:duplicatePair', i));
        end
        z(z1,z2) = true;
    end
    
    % check for missing ones
    if any( ~saw_op )
        soix = find( ~saw_op, 1 );
        error(message('MATLAB:mtree:op2', KN{ soix }, soix));
    end
     
    %  Fix up next and parent
    z(L.Next,:) = true;
    z(L.Parent,:) = true;
    L.L = L.Left;
    L.R = L.Right;
    L.N = L.Next;
    L.P = L.Parent;
    L.X = L.Next;
      
end
