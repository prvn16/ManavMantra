function varargout = fimplicit3(varargin)
%FIMPLICIT3   Plot implicit surface
%
%   FIMPLICIT3(FUN) plots the surface where FUN(X,Y,Z)==0 between the axes limits,
%    with a default range of [-5 5].
%
%   FIMPLICIT3(FUN,LIMS) uses the given limits. LIMS can be [XYZMIN XYZMAX]
%    with XYZMIN <= X <= XYZMAX, and XYMIN <= Y <= XYMAX, and XYMIN <= Z <= XYMAX,
%    or [XMIN XMAX YMIN YMAX ZMIN ZMAX].
%
%   FIMPLICIT3(...,'LineSpec') plots with the given line specification,
%    using the color for the surface.
%
%   H = FIMPLICIT3(...) returns a handle to the function line object created by FIMPLICIT3.
%
%   FIMPLICIT3(AX,...) plots into the axes AX instead of the current axes.
%
%
% Examples:
%   fimplicit3(@(x,y,z) x.^2+y.^2+z.^2 - 9)
%
%   fimplicit3(@(x,y,z) x.^2-y.^2-z.^2)
%
%   fimplicit3(@(x,y,z) x.^2-y.^2.*z)
%
%   fimplicit3(@(x,y,z) x.^2.*y.*z+y.^3-z.^3)
%
%   fimplicit3(@flow, [-6, 0.25, -10, 10, -10, 10], 'MeshDensity',100)
%
%   fimplicit3(@(x,y,z) 5*x.*(x.^2-5*y.^2)+z.^2.*(1+z)+2*x.*y+2*y.*z, ...
%     [-1 1 -1 1 -1.5 0.5])
%
%     See also FIMPLICIT, FSURF, FPLOT, FCONTOUR, FUNCTION_HANDLE.

%   Copyright 2015-2017 The MathWorks, Inc.

    % Parse possible Axes input
    [cax, args] = axescheck(varargin{:});

    narginchk(1,inf);
    nargoutchk(0,2);
    doPlot = (nargout < 2);
    fn = args{1};
    args(1) = [];

    if isa(fn,'function_handle') && nargin(fn) > 3
        error(message('MATLAB:fimplicit3:TooManyVariables'));
    end

    extraOpts = {};
    linespecFound = false;

    function searchLinespec()
        if ~linespecFound && ~isempty(args) && matlab.graphics.internal.isCharOrString(args{1})
            [l,c,m,msg] = colstyle(args{1},'plot');
            if isempty(msg)
                linespecFound = true;
                if ~isempty(l)
                    extraOpts = [extraOpts, {'LineStyle'}, l];
                end
                if ~isempty(c)
                    extraOpts = [extraOpts, {'FaceColor'}, c];
                end
                if ~isempty(m)
                    extraOpts = [extraOpts, {'Marker'}, m];
                end
                args(1) = [];
            end
        end
    end

    searchLinespec;

    if ~isempty(args) && (isa(args{1},'function_handle') || isa(args{1}, 'sym'))
        error(message('MATLAB:fplot:TooManyFunctions'));
    end

    limits = [];
    if ~isempty(args) && isnumeric(args{1}) && (numel(args{1})==2 || numel(args{1})==6)
        limits = args{1};
        args(1) = [];
        matlab.graphics.function.internal.checkRangeVector(limits(1:2));
        if numel(limits)==6
            matlab.graphics.function.internal.checkRangeVector(limits(3:4));
            matlab.graphics.function.internal.checkRangeVector(limits(5:6));
        end
        searchLinespec;
    end


    validParameters = properties('matlab.graphics.function.ImplicitFunctionSurface');

    for k=1:2:numel(args)
        try
            validatestring(args{k},validParameters);
        catch
            if isnumeric(args{k})
                strArgs = num2str(args{k});
            else
                strArgs = char(args{k});
            end
            if length(strArgs) > 10
                strArgs = [strArgs(1:7) '...'];
            end
            error(message('MATLAB:fplot:InvalidParameter',strArgs));
        end
    end

    if mod(numel(args),2)~=0
        error(message('MATLAB:fplot:InvalidPairs'));
    end

    nextPlot = 'add';
    if doPlot && (isempty(cax) || ishghandle(cax,'axes'))
        cax = newplot(cax);
        nextPlot = cax.NextPlot;
    end
    extraOpts = [extraOpts, {'Parent', cax}];

    hObj = vectorizeFimplicit(cax,fn,limits,extraOpts,args);

    switch nextPlot
        case {'replaceall','replace'}
            view(cax,3);
            grid(cax,'on');
            axis(cax,'tight');
        case {'replacechildren'}
            view(cax,3);
    end

    if nargout > 0
        varargout = {hObj(:)};
    end
end


function hObj = vectorizeFimplicit(cax,fn,limits,extraOpts,args)
    args = matlab.graphics.internal.convertStringToCharArgs(args);
    if ~iscell(fn)
        if isscalar(fn)
            fn = {fn};
        else
            fn = num2cell(fn);
        end
    end
    hObj = cellfun(@(f) singleFimplicit(cax,f,limits,extraOpts,args),fn,'UniformOutput',false);
    hObj = [hObj{:}];
end

function hObj=singleFimplicit(cax,fn,limits,extraOpts,args)
    args = matlab.graphics.internal.convertStringToCharArgs(args);
    % plot an individual function
    ax = cax;
    if ~isempty(ax) && ~ishghandle(ax, 'axes')
        ax = ancestor(ax,'axes');
    end
    if ishghandle(ax,'axes')
        [autostyle,~,automarker] = nextstyle(ax,true,true,false);
        if ~any(cellfun(@(x) isequal(x,'LineStyle'),args)) && ~any(cellfun(@(x) isequal(x,'LineStyle'),extraOpts))
            extraOpts = [extraOpts, {'LineStyle'}, {autostyle}];
        end
        if ~any(cellfun(@(x) isequal(x,'Marker'),args)) && ~any(cellfun(@(x) isequal(x,'Marker'),extraOpts))
            extraOpts = [extraOpts, {'Marker'}, {automarker}];
        end
    end

    nvars = countvars(fn);

    if nvars > 3
        error(message('MATLAB:fimplicit3:TooManyVariables'));
    end
    if ~isempty(limits)
        extraOpts = [extraOpts, {'XRange'}, {limits(1:2)}];
        if numel(limits) > 2
            extraOpts = [extraOpts, {'YRange'}, {limits(3:4)}];
            extraOpts = [extraOpts, {'ZRange'}, {limits(5:6)}];
        else
            extraOpts = [extraOpts, {'YRange'}, {limits(1:2)}];
            extraOpts = [extraOpts, {'ZRange'}, {limits(1:2)}];
        end
    end
    hObj = matlab.graphics.function.ImplicitFunctionSurface(fn,extraOpts{:},args{:});
end
