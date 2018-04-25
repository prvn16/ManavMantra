function varargout = fimplicit(varargin)
%FIMPLICIT   Plot implicit function
%
%   FIMPLICIT(FUN) plots the curves where FUN(X,Y)==0 between the axes limits,
%    with a default range of [-5 5].
%
%   FIMPLICIT(FUN,LIMS) uses the given limits. LIMS can be [XMIN XMAX YMIN YMAX]
%    or [XYMIN XYMAX] with XYMIN <= X <+ XYMAX and XYMIN <= Y <= XYMAX.
%
%   FIMPLICIT(...,'LineSpec') plots with the given line specification.
%
%   H = FIMPLICIT(...) returns a handle to the function line object created by FIMPLICIT.
%
%   FIMPLICIT(AX,...) plots into the axes AX instead of the current axes.
%
%
% Examples:
%   fimplicit(@(x,y) y.^2-x.^2.*(x+1), [-2 2])
%
%   fimplicit(@(x,y) x.*y.*cos(x.^2 + y.^2) - 1, [-10 10])
%
%   The Ampersand curve
%   fimplicit(@(x,y) (y.^2-x.^2).*(x-1).*(2*x-3)-2*(x.^2+y.^2-2*x).^2)
%   axis equal
%
%   Benice equations
%   fimplicit(@(x,y) (x.^2+y.^2-3).*hypot(x,y) + 0.75 + ...
%     sin(8*hypot(x,y)).*cos(6*atan(y./abs(x))) - ...
%     0.75*sin(5*atan(y./abs(x))), [-2 2], 'MeshDensity', 100)
%
%   fimplicit(@(x,y)  (x.^2+y.^2-3).*hypot(x,y) + 0.75 + ...
%     sin(4*hypot(x,y)).*cos(84*atan(y./x)) - cos(6*atan(y./x)),...
%     [-2 2],'MeshDensity',512)
%
%   See also FIMPLICIT3, FPLOT, FCONTOUR, FUNCTION_HANDLE.

% syms x y
% fimplicit(sin(x)^2==y*(y-1.8)*(y-1.8))
% fimplicit(sin(x)^2==y*(y-1)*(y-2))
% fimplicit(625*(x^2+y^2)^3-36450*y*(5*x^4-10*x^2*y^2+y^4)+585816*(x^2+y^2)^2-41620992*(x^2+y^2)+550731776, [-15,15])

%   Copyright 2015-2017 The MathWorks, Inc.

    % Parse possible Axes input
    [cax, args] = axescheck(varargin{:});

    narginchk(1,inf);
    nargoutchk(0,2);
    doPlot = (nargout < 2);
    fn = args{1};
    args(1) = [];

    if isa(fn,'function_handle') && nargin(fn) > 2
        error(message('MATLAB:fimplicit:TooManyVariables'));
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
                    extraOpts = [extraOpts, {'Color'}, c];
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
    if ~isempty(args) && isnumeric(args{1}) && (numel(args{1})==2 || numel(args{1})==4)
        limits = args{1};
        args(1) = [];
        matlab.graphics.function.internal.checkRangeVector(limits(1:2));
        if numel(limits)==4
            matlab.graphics.function.internal.checkRangeVector(limits(3:4));
        end
        searchLinespec;
    end


    validParameters = properties('matlab.graphics.function.ImplicitFunctionLine');

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

    if ismember(nextPlot, {'replace','replaceall'})
        box(cax,'on');
        axis(cax,'tight');
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
        [autostyle,autocolor,automarker] = nextstyle(ax,true,true,false);
        if ~any(cellfun(@(x) isequal(x,'Color'),args)) && ~any(cellfun(@(x) isequal(x,'Color'),extraOpts))
            extraOpts = [extraOpts, {'Color'}, {autocolor}];
        end
        if ~any(cellfun(@(x) isequal(x,'LineStyle'),args)) && ~any(cellfun(@(x) isequal(x,'LineStyle'),extraOpts))
            extraOpts = [extraOpts, {'LineStyle'}, {autostyle}];
        end
        if ~any(cellfun(@(x) isequal(x,'Marker'),args)) && ~any(cellfun(@(x) isequal(x,'Marker'),extraOpts))
            extraOpts = [extraOpts, {'Marker'}, {automarker}];
        end
    end

    nvars = countvars(fn);

    if nvars > 2
        error(message('MATLAB:fplot:TooManyVariables'));
    end
    if ~isempty(limits)
        extraOpts = [extraOpts, {'XRange'}, {limits(1:2)}];
        if numel(limits) > 2
            extraOpts = [extraOpts, {'YRange'}, {limits(3:4)}];
        else
            extraOpts = [extraOpts, {'YRange'}, {limits(1:2)}];
        end
    end
    hObj = matlab.graphics.function.ImplicitFunctionLine(fn,extraOpts{:},args{:});
end
