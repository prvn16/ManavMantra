function h = fsurf(varargin)
%FSURF   Plot 3-D surface
%   FSURF(FUN) creates a surface plot of the function FUN(X,Y). FUN is plotted over
%   the axes size, with a default interval of -5 < X < 5, -5 < Y < 5.
%
%   FSURF(FUN,INTERVAL) plots FUN over the specified INTERVAL instead of the
%   default interval.  INTERVAL can be the vector [XMIN,XMAX,YMIN,YMAX] or the
%   vector [A,B] (to plot over A < X < B, A < Y < B).
%
%   FSURF(FUNX,FUNY,FUNZ) plots the parametric surface FUNX(U,V),
%   FUNY(U,V), and FUNZ(U,V) over the interval -5 < U < 5 and
%   -5 < V < 5.
%
%   FSURF(FUNX,FUNY,FUNZ,[UMIN,UMAX,VMIN,VMAX]) or
%   FSURF(FUNX,FUNY,FUNZ,[A,B]) uses the specified interval.
%
%   FSURF(AX,...) plots into the axes AX instead of the current axes.
%
%   H = FSURF(...) returns a handle to the surface object in H.
%
%   Examples:
%      fsurf(@(x,y) x.*exp(-x.^2-y.^2))
%      fsurf(@(x,y) besselj(1,hypot(x,y)))
%      fsurf(@(x,y) besselj(1,hypot(x,y)),[-20,20]) % this can take a moment
%      fsurf(@(x,y) sqrt(1-x.^2-y.^2),[-1.1,1.1])
%      fsurf(@(x,y) x./y+y./x)
%      fsurf(@peaks)
%
%      f = @(u) 1./(1+u.^2);
%      fsurf(@(u,v) u, @(u,v) f(u).*sin(v), @(u,v) f(u).*cos(v),[-2 2 -pi pi])
%
%      A = 2/3;
%      B = sqrt(2);
%      xfcn = @(u,v) A*(cos(u).*cos(2*v) + B*sin(u).*cos(v)).*cos(u) ./ (B - sin(2*u).*sin(3*v));
%      yfcn = @(u,v) A*(cos(u).*sin(2*v) - B*sin(u).*sin(v)).*cos(u) ./ (B - sin(2*u).*sin(3*v));
%      zfcn = @(u,v) B*cos(u).^2 ./ (B - sin(2*u).*sin(3*v));
%      h = fsurf(xfcn,yfcn,zfcn,[0 pi 0 pi]);
%
%   If your function has additional parameters, for example k in myfun:
%      %------------------------------%
%      function z = myfun(x,y,k1,k2,k3)
%      z = x.*(y.^k1)./(x.^k2 + y.^k3);
%      %------------------------------%
%   then you may use an anonymous function to specify that parameter:
%      fsurf(@(x,y)myfun(x,y,2,2,4))
%
%   See also FPLOT, FPLOT3, FMESH, FIMPLICIT3, SURF, VECTORIZE, FUNCTION_HANDLE.

%   Copyright 2015-2017 The MathWorks, Inc.

    calledForMesh = false;
    if nargin>0 && isequal(varargin{end},'CalledForMesh')
        calledForMesh = true;
        varargin(end) = [];
    end

    % Parse possible Axes input
    [cax, args] = axescheck(varargin{:});
    args = matlab.graphics.internal.convertStringToCharArgs(args);
    narginchk(1,inf);
    fn = args(1);
    args(1) = [];

    extraOpts = {};
    linespecFound = false;
    function searchLinespec()
        if ~linespecFound && ~isempty(args) && matlab.graphics.internal.isCharOrString(args{1})
            [l,c,m,msg] = colstyle(args{1});
            if isempty(msg)
                linespecFound = true;
                if ~isempty(l)
                    extraOpts = [extraOpts, {'LineStyle'}, l];
                end
                if ~isempty(c)
                    if calledForMesh
                        extraOpts = [extraOpts, {'EdgeColor'}, c];
                    else
                        extraOpts = [extraOpts, {'FaceColor'}, c];
                    end
                end
                if ~isempty(m)
                    extraOpts = [extraOpts, {'Marker'}, m];
                end
                args(1) = [];
            end
        end
    end
    searchLinespec;

    % TODO: vectorization
    if numel(args)>1 && ...
      (isa(args{1},'function_handle') || (isnumeric(args{1}) && isscalar(args{1})) || ...
        isa(args{1}, 'sym') || iscell(args{1})) && ...
      (isa(args{2},'function_handle') || (isnumeric(args{2}) && isscalar(args{2})) || ...
        isa(args{2}, 'sym') || iscell(args{2}))
      fn{end+1} = args(1);
      args(1) = [];
      fn{end+1} = args(1);
      args(1) = [];
      searchLinespec;
    end

    for k=1:numel(fn)
        if iscell(fn{k})
            cellfun(@(f)validateattributes(f,{'function_handle','sym','numeric'},{}),fn{k},'UniformOutput',false);
        else
            validateattributes(fn{k},{'function_handle','sym','numeric'},{});
            if (isa(fn{k}, 'sym') && numel(symvar(fn{k})) > 2) || ...
                (isa(fn{k}, 'function_handle') && nargin(fn{k}) > 2)
                error(message('MATLAB:fsurf:TooManyVariables'));
            end
        end
    end

    if ~isempty(args) && (isa(args{1},'function_handle') || isa(args{1}, 'sym'))
        error(message('MATLAB:fplot:TooManyFunctions'));
    end

    if ~isempty(args) && isnumeric(args{1})
        if numel(args{1})==4
            limits = args{1};
            args(1) = [];
            matlab.graphics.function.internal.checkRangeVector(limits(1:2));
            matlab.graphics.function.internal.checkRangeVector(limits(3:4));
            if numel(fn) == 1
              extraOpts = [extraOpts, {'XRange'}, {limits(1:2)}, {'YRange'}, {limits(3:4)}];
            else
              extraOpts = [extraOpts, {'URange'}, {limits(1:2)}, {'VRange'}, {limits(3:4)}];
            end
        elseif numel(args{1})==2
            limits = args{1};
            args(1) = [];
            matlab.graphics.function.internal.checkRangeVector(limits);
            if numel(fn) == 1
              extraOpts = [extraOpts, {'XRange'}, {limits}, {'YRange'}, {limits}];
            else
              extraOpts = [extraOpts, {'URange'}, {limits}, {'VRange'}, {limits}];
            end
        end
        searchLinespec;
    end

    for k=1:numel(fn)
        if isa(fn{k},'function_handle') && nargin(fn{k}) > 2
            error(message('MATLAB:fplot:TooManyVariables'));
        end
        if isa(fn{k},'sym') && ...
            contains(char(feval(symengine,'symobj::map',formula(fn{k}),'testtype','Type::Arithmetical')),'FALSE')
            error(message('MATLAB:fplot:InvalidExpression'));
        end
    end

    if numel(fn)==1
        validParameters = properties('matlab.graphics.function.FunctionSurface');
    else
        validParameters = properties('matlab.graphics.function.ParameterizedFunctionSurface');
    end

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

    if calledForMesh
        if ~any(cellfun(@(x) isequal(x,'FaceColor'),args)) && ~any(cellfun(@(x) isequal(x,'FaceColor'),extraOpts))
            hparent = get(cax,'Parent');
            fc = get(cax,'Color');
            if strcmpi(fc,'none')
                if isprop(hparent,'Color')
                    fc = get(hparent,'Color');
                elseif isprop(hparent,'BackgroundColor')
                    fc = get(hparent,'BackgroundColor');
                end
            end
            extraOpts = [extraOpts, {'FaceColor'}, {fc}];
        end
        if ~any(cellfun(@(x) isequal(x,'EdgeColor'),args)) && ~any(cellfun(@(x) isequal(x,'EdgeColor'),extraOpts))
            extraOpts = [extraOpts, {'EdgeColor'}, {'interp'}];
        end
    end

    hObj = vectorizeFsurf(cax,fn,extraOpts,args);

    switch nextPlot
        case {'replaceall','replace'}
            view(cax,3);
            grid(cax,'on');
            axis(cax,'tight');
        case {'replacechildren'}
            view(cax,3);
    end

    if nargout > 0
        h = hObj(:);
    end
end

function hObj = vectorizeFsurf(cax,fn,extraOpts,args)
    for i=1:numel(fn)
        if ~iscell(fn{i})
            if isscalar(fn{i}) % TODO: symfun
                fn{i} = fn(i);
            else
                fn{i} = num2cell(fn{i});
            end
        end
    end
    if 1==numel(fn)
        hObj = cellfun(@(f) singleFsurf(cax,{f},extraOpts,args),fn{1},'UniformOutput',false);
    else
        assert(numel(fn)==3);
        wantedSize = max(cellfun(@numel, fn));
        for i=1:3
            if numel(fn{i})==1
                fn{i} = repmat(fn{i},wantedSize);
            end
        end
        hObj = cellfun(@(f1,f2,f3) singleFsurf(cax,{f1,f2,f3},extraOpts,args),fn{:},'UniformOutput',false);
    end
    hObj = [hObj{:}];
end

function hObj=singleFsurf(cax,fn,extraOpts,args)
    % plot an individual function
    ax = cax;
    if ~isempty(ax) && ~ishghandle(ax, 'axes')
        ax = ancestor(ax,'axes');
    end
    if ishghandle(ax,'axes')
        [autostyle,~,automarker] = nextstyle(ax,true,true,false);
        % if ~any(cellfun(@(x) isequal(x,'FaceColor'),args)) && ~any(cellfun(@(x) isequal(x,'FaceColor'),extraOpts))
            % extraOpts = [extraOpts, {'FaceColor'}, {autocolor}];
        % end
        if ~any(cellfun(@(x) isequal(x,'LineStyle'),args)) && ~any(cellfun(@(x) isequal(x,'LineStyle'),extraOpts))
            extraOpts = [extraOpts, {'LineStyle'}, {autostyle}];
        end
        if ~any(cellfun(@(x) isequal(x,'Marker'),args)) && ~any(cellfun(@(x) isequal(x,'Marker'),extraOpts))
            extraOpts = [extraOpts, {'Marker'}, {automarker}];
        end
    end

    if numel(fn) == 1
      hObj = matlab.graphics.function.FunctionSurface(fn,extraOpts{:},args{:});
    else
      hObj = matlab.graphics.function.ParameterizedFunctionSurface(fn,extraOpts{:},args{:});
    end
end
