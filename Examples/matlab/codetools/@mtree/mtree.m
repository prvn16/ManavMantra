classdef mtree
%MTREE  Create and manipulate M parse trees
%   This is an experimental program whose behavior and interface is likely
%   to change in the future.

% Copyright 2006-2016 The MathWorks, Inc.

    properties (SetAccess='protected', GetAccess='protected', Hidden)
        T    % parse tree array
                 % column 1: kind of node
                 % column 2: index of left child
                 % column 3: index of right child
                 % column 4: index of next node
                 % column 5: position of node
                 % column 6: size of node
                 % column 7: symbol table index (V)R/
                 % column 8: string table index
                 % column 9: index of parent node
                 % column 10: setting node
                 % column 11: lefttreepos
                 % column 12: righttreepos
                 % column 13: true parent
                 % column 14: righttreeindex
                 % column 15: rightfullindex
        S    % symbol table
        C    % character strings
        IX   % index set (default is true for everything)
        n    % number of nodes
        m    % sum(IX)
        lnos % line number translation
        str  % input string that created the tree
    end
    properties (SetAccess='private', GetAccess='public')
        % The type of the code file represented by the tree
        % This will be one of the values of the mtree.Type
        % enum, such as mtree.Type.ScriptFile, etc.
        FileType
    end
    properties (GetAccess='public', Constant, Hidden)
        N  = mtree_info(1)  % node names
        K  = mtree_info(2)  % node key
        KK = mtree_info(3)  % the internal names (for debugging)
        Uop = mtree_info(4) % true if node is a unary op
        Bop = mtree_info(5) % true if node is a binary op
        Stmt = mtree_info(6) % true if node is a statement
        Linkno = mtree_info(7) % maps link to index
        Lmap = mtree_info(8) % link map
        Linkok = mtree_info(9) % is link OK for a given node
        PTval = mtree_info(10) % array of nodes whose V is a position value
        V  = { '2.50', '2.50' };   % version array
    end
    methods
        [v1,v2] = version(o)
    end
    methods (Access='protected')
        % housekeeping methods
        L = linelookup( o, P )
    end
    methods
        % CONSTRUCTOR
        function o = mtree( text, varargin )
        %MTREE  o = MTREE( text, options ) constructs an mtree object
        %
        % Options include:
        %     -file:  the text argument is treated as a filename
        %     -comments:   comments are included in the tree
        %     -cell:  cell markers are included in the tree
            try
                [text, args] = validateInput(text, varargin);
            catch E
                throw(E)
            end
            opts = {};
            for i=1:nargin-1
                if strcmp( args{i}, '-file' )
                    try
                        fname = text;
                        text = matlab.internal.getCode(text);
                    catch x
                        error(message('MATLAB:mtree:input', fname));
                    end
                else
                    switch args{i}
                      case '-comments'
                        opts{end+1} = '-com'; %#ok<AGROW>
                      otherwise
                        opts{end+1} = args{i}; %#ok<AGROW>
                    end
                end
            end
            o.str = text;
            [o.T, o.S, o.C, o.FileType, o.lnos] = mtreemex( text, opts{:} );
            o = wholetree( o );
        end
        o = wholetree( o )
    end
    methods (Hidden)
        b = eq( o, oo )
        b = ne( o, oo )
        b = le( o, oo )
        o = subtree(o) % Deprecated.
        o = fullsubtree( o ) % Deprecated.
        function o = list(o)
        %LIST  list is deprecated -- use List
            o = List(o);
        end

        function o = full(o)
        %full  full is deprecated -- use wholetree
            o = wholetree(o);
        end
        b = isfull(o) % Deprecated.
    end
    methods
        m = count( o )
        oo = root( o )
        oo = null( o )
    end
    methods (Access='protected',Hidden)
        oo = makeAttrib( o, I )
        [I,ipath,flag,rest] = pathit( o, I, ipath )
        a = restrict( o, ipath, s )
    end
    methods
        a = path(o, pth ) % Deprecated since it interferes with the builtin.
        a = mtpath(o, pth )

        c = strings( o )
        c = stringvals( o )
        s = string( o )
        s = stringval( o )
        a = find( o, varargin ) % Deprecated.
        a = mtfind( o, varargin )
        o = sets( o )
    end
    methods   % methods for following paths...
        o = Left(o)
        o = Arg(o)
        o = Try(o)
        o = Attr(o)
        o = Right(o)
        o = Body(o)
        o = Catch(o)
        o = CatchID(o)
        o = Next(o)
        o = Parent(o)
        o = Outs(o)
        o = Index(o)
        o = Cattr(o)
        o = Vector(o)
        o = Cexpr(o)
        o = Ins(o)
        o = Fname(o)
        o = lhs( o )
        o = previous( o )
        oo = first( o )
        o = last( o )
    end

    properties(Dependent)
        VarName;
        VarType;
        VarDimensions;
        VarValidators;
    end

    methods
        function name = get.VarName(o)
            name = varName(o);
        end
        function type = get.VarType(o)
            type = varType(o);
        end
        function dims = get.VarDimensions(o)
            dims = varDimensions(o);
        end
        function vals = get.VarValidators(o)
            vals = varValidators(o);
        end
    end

    methods(Access=private, Hidden)
        function o = varName(o)
        %VARNAME returns the Name node of a typed variable.

        % fast for single nodes...
            lix = o.Linkno.VarName;
            J = o.T( o.IX, 2 ); % go to name node
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end

        function o = varType(o)
        %VARTYPE returns the Type node of a typed variable.

        % fast for single nodes...
            lix = o.Linkno.VarType;
            J = o.T( o.IX, 3 ); % go to ETC node
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            J = o.T( J, 2 );  % go to type node
            J = J(J~=0);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end

        function o = varDimensions(o)
        %VARDIMENSIONS returns the Size node of a typed variable.

        % fast for single nodes...
            lix = o.Linkno.VarDimensions;
            J = o.T(o.IX, 3); % go to first ETC
            KKK = o.Linkok(lix, o.T(o.IX, 1)) & (J ~= 0)';
            J = J(KKK);
            for next = [3 2] % then ETC -> Size
                J = o.T(J, next);
                J = J(J ~= 0);
            end
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end

        function o = varValidators(o)
        %VARVALIDATOR returns the Validators node of a typed variable.

        % fast for single nodes...
            lix = o.Linkno.VarValidators;
            J = o.T(o.IX, 3); % go to ETC
            KKK = o.Linkok(lix, o.T(o.IX, 1)) & (J ~= 0)';
            J = J(KKK);
            for next = [3 3 2] % then ETC -> ETC -> Validators
                J = o.T(J, next);
                J = J(J ~= 0);
            end
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
    end

    methods
        oo = setter( o )
    end
    methods (Hidden)
        % Low-level methods that are used for testing or special purposes
        % and will not be documented.
        b = sametree( o, oo )
        oo = rawset( o )
        T = newtree( o, varargin )
        s = getpath( o, r )

        function o = L(o)
        %L  o = L(o)  Raw Left operation

        % fast for single nodes...
            J = o.T( o.IX, 2 );
            J = J(J~=0);
            o.IX(o.IX) = false;
            o.IX(J)= true;
            o.m = length(J);
        end

        function o = R(o)
        %R  o = R(o)  Raw Right operation
            J = o.T( o.IX, 3 );
            J = J(J~=0);
            o.IX(o.IX) = false;
            o.IX(J)= true;
            o.m = length(J);
        end

        function o = P(o)
        %P  o = P(o)  Raw Parent operation
            J = o.T( o.IX, 9 );
            J = J(J~=0);
            o.IX(o.IX) = false;
            o.IX(J)= true;
            o.m = length(J);
        end

        function o = X(o)
        %X  o = X(o)  Raw Next operation
            J = o.T( o.IX, 4 );
            o.m = o.m - sum( J==0 );
            J = J(J~=0);
            o.IX(o.IX) = false;
            o.IX(J)= true;
        end

        o = or( o, o2 )
        o = and( o, o2 )
        o = not( o )
        o = minus( o, o2 )
    end
    methods
        oo = allsetter( o, o2 ) % Deprecated.
        oo = anysetter( o, o2 ) % Deprecated.
        disp(o)
        show(o)
        dump(o)  % Deprecated.
        dumptree(o)
        rawdump(o)

        o = List( o )
        o = Full( o )
        o = Tree( o )
        oo = asgvars( o )
        oo = geteq( o )
        oo = dominator( o )
        ooo = dominates( oo, o )
        b = isbop( o )
        b = isuop( o )
        b = isop( o )
        b = isstmt( o )
        o = ops( o )
        o = bops( o )
        o = uops( o )
        o = stmts( o )
        o = operands( o )
        oo = depends( o )
        o = setdepends( o )
        o = growset( o, fh )
        o = fixedpoint( o, fh )
        L = lineno( o )
        C = charno( o )
        P = position( o )
        [l,c] = pos2lc( o, pos )
        pos = lc2pos( o, l, c )
        EP = endposition( o )
        LP = leftposition(o)
        RP = rightposition(o)
        RP = righttreepos(o)
        LP = lefttreepos(o)
        RP = righttreeindex(o)
        RP = rightfullindex(o)
        oo = trueparent(o)
        b = isempty( o )
        b = isnull( o )
        a = kinds( o )
        a = kind( o )
        b = iskind( o, kind )
        b = anykind( o, kind )
        b = allkind( o, kind )
        b = isstring( o, strs )
        b = allstring( o, strs )
        b = anystring( o, strs )
        b = ismember( o, a )
        b = allmember( o, a )
        b = anymember( o, a )
        o = select( o, ix )
        ln = getlastexecutableline( o )
        [ln,ch] = lastone( o )
        n = nodesize( o )
        I = indices(o)
        b = iswhole( o )
        s = tree2str( S, varargin )
    end
    methods % (Hidden)
            % these methods are only for the very well informed...
            % I wanted to make them protected and Hidden, but the Simulink
            % dependency analysis test explicitly tests for this method
            % being visible.  TODO: track down why this is so....

        o = setIX( o, I )
        I = getIX( o )
    end
    methods (Access=protected,Hidden)
        chk( o )
    end
end

function [file, args] = validateInput(file, args)
    if nargin == 0 || ~(ischar(file) || (isstring(file) && isscalar(file)))
        error(message('MATLAB:mtree:usage'));
    end

    if isstring(file)
        file = char(file);
    end

    for idx=1:length(args)
        if(isstring(args{idx}) && isscalar(args{idx}))
            args{idx} = char(args{idx});
        elseif(isstring(args{idx}) && ~isscalar(args{idx}))
            args{idx} = cellstr(args{idx}); 
        end
    end    
end
