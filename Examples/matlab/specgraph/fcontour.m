function h = fcontour(varargin)
%FCONTOUR   Plot function contour lines
%   FCONTOUR(F) plots contour lines of F(X,Y) over the axes size,
%   with a default range of -5 < X < 5, -5 < Y < 5.
%
%   FCONTOUR(F,[XYMIN XYMAX]) plots over XYMIN < X < XYMAX, XYMIN < Y < XYMAX.
%   FCONTOUR(F,[XMIN XMAX YMIN YMAX]) plots over XMIN < X < XMAX, YMIN < Y < YMAX.
%
%   H = FCONTOUR(...) returns a handle to the function contour object created by FCONTOUR.
%
%   FCONTOUR(...,'LineSpec') plots with the given line specification.
%
%   FCONTOUR(AX,...) plots into the axes AX instead of the current axes.
%
%   Examples:
%       fcontour(@(x,y) x.^2+y.^2)
%       fcontour(@(x,y) sin(x).*cos(y),[-2*pi,2*pi],'MeshDensity',121)
%
%   See also CONTOUR, FIMPLICIT, FPLOT, FPLOT3, FSURF, FUNCTION_HANDLE.

%   Copyright 2015-2017 The MathWorks, Inc.


    % Parse possible Axes input
    [cax, args] = axescheck(varargin{:});
    
    narginchk(1,inf);
    fn = args{1};
    args(1) = [];

    if iscell(fn)
        cellfun(@(f)validateattributes(f,{'function_handle','sym'},{}),fn,'UniformOutput',false);
    else
        validateattributes(fn,{'function_handle','sym'},{});
    end

    extraOpts = {};
    linespecFound = false;

    function searchLinespec()
        if ~linespecFound && ~isempty(args) && matlab.graphics.internal.isCharOrString(args{1})
            args = matlab.graphics.internal.convertStringToCharArgs(args);
            [l,c,m,msg] = colstyle(args{1},'plot');
            if isempty(msg)
                linespecFound = true;
                if ~isempty(l)
                    extraOpts = [extraOpts, {'LineStyle'}, l];
                end
                if ~isempty(c)
                    extraOpts = [extraOpts, {'LineColor'}, c];
                end
                if ~isempty(m) && ~isequal(m,'none')
                    error(message('MATLAB:fplot:MarkersNotSupported'));
                end
                args(1) = [];
            end
        end
    end

    searchLinespec;

    if ~isempty(args) && (isa(args{1},'function_handle') || isa(args{1}, 'sym'))
        error(message('MATLAB:fplot:TooManyFunctions'));
    end

    if ~isempty(args) && isnumeric(args{1}) && (numel(args{1})==2 || numel(args{1})==4)
        limits = args{1};
        args(1) = [];
        matlab.graphics.function.internal.checkRangeVector(limits(1:2));
        extraOpts = [extraOpts, {'XRange'}, {limits(1:2)}];
        if numel(limits)==4
            matlab.graphics.function.internal.checkRangeVector(limits(3:4));
            extraOpts = [extraOpts, {'YRange'}, {limits(3:4)}];
        else
            extraOpts = [extraOpts, {'YRange'}, {limits(1:2)}];
        end
        searchLinespec;
    end

    if isa(fn,'function_handle') && nargin(fn) > 2
        error(message('MATLAB:fplot:TooManyVariables'));
    end
    if isa(fn,'sym') && ...
        contains(char(feval(symengine,'symobj::map',formula(fn),'testtype','Type::Arithmetical')),'FALSE')
        error(message('MATLAB:fplot:InvalidExpression'));
    end

    validParameters = properties('matlab.graphics.function.FunctionContour');

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

    nextPlot = 'add';
    if isempty(cax) || ishghandle(cax,'axes')
        cax = newplot(cax);
        nextPlot = cax.NextPlot;
    end
    extraOpts = [extraOpts, {'Parent'}, {cax}];

    hObj = vectorizeFContour(cax,fn,extraOpts,args);

    if ismember(nextPlot, {'replace','replaceall'})
        box(cax,'on');
        axis(cax,'tight');
    end

    if nargout > 0
        h = hObj(:);
    end
end


function hObj = vectorizeFContour(cax,fn,extraOpts,args)
    if ~iscell(fn)
        if isscalar(fn) % TODO: symfun
            fn = {fn};
        else
            fn = num2cell(fn);
        end
    end
    hObj = cellfun(@(f) singleFContour(cax,f,extraOpts,args),fn,'UniformOutput',false);
    hObj = [hObj{:}];
end

function hObj=singleFContour(cax,fn,extraOpts,args)
    % plot an individual function
    ax = cax;
    if ~isempty(ax) && ~ishghandle(ax, 'axes')
        ax = ancestor(ax,'axes');
    end
    if ishghandle(ax,'axes')
        [autostyle,autocolor,~] = nextstyle(ax,true,true,false);
        if ~any(cellfun(@(x) isequal(x,'Color'),args)) && ~any(cellfun(@(x) isequal(x,'Color'),extraOpts))
            extraOpts = [extraOpts, {'Color'}, {autocolor}];
        end
        if ~any(cellfun(@(x) isequal(x,'LineStyle'),args)) && ~any(cellfun(@(x) isequal(x,'LineStyle'),extraOpts))
            extraOpts = [extraOpts, {'LineStyle'}, {autostyle}];
        end
    end

    hObj = matlab.graphics.function.FunctionContour(fn,extraOpts{:},args{:});
end
