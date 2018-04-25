function varargout = fplot(varargin)
%FPLOT   Plot 2-D function
%   FPLOT(FUN) plots the function FUN between the limits of the current
%   axes, with a default of [-5 5].
%
%   FPLOT(FUN,LIMS) plots the function FUN between the x-axis limits
%   specified by LIMS = [XMIN XMAX]. 
%
%   FPLOT(...,'LineSpec') plots with the given line specification.
%
%   FPLOT(X,Y,LIMS) plots the parameterized curve with coordinates
%   X(T), Y(T) for T between the values specified by LIMS = [TMIN TMAX].
%
%   H = FPLOT(...) returns a handle to the function line object created by FPLOT.
%
%   FPLOT(AX,...) plots into the axes AX instead of the current axes.
%
%   Examples:
%       fplot(@sin)
%       fplot(@(x) x.^2.*sin(1./x),[-1,1])
%       fplot(@(x) sin(1./x), [0 0.1])
%
%   If your function cannot be evaluated for multiple x values at once,
%   you will get a warning and somewhat reduced speed:
%       f = @(x,n) abs(exp(-1j*x*(0:n-1))*ones(n,1));
%       fplot(@(x) f(x,10),[0 2*pi])
%
%   See also FPLOT3, FSURF, FCONTOUR, FIMPLICIT, PLOT, FUNCTION_HANDLE.

%   Copyright 1984-2017 The MathWorks, Inc.

% Convert string arguments, if any, to char.
if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

    % Parse possible Axes input
    [cax, args] = axescheck(varargin{:});
    
    narginchk(1,inf);
    nargoutchk(0,2);
    doPlot = (nargout < 2);
    fn = args(1);
    args(1) = [];

    extraOpts = {};
    linespecFound = false;

    function searchLinespec()
        if ~linespecFound && ~isempty(args) &&  matlab.graphics.internal.isCharOrString(args{1})
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


    % TODO: char that is not an N/V pair thing
    if ~isempty(args) && (isa(args{1},'function_handle') || isa(args{1}, 'sym'))
        fn{end+1} = args(1);
        args(1) = [];
    end

    if ~isempty(args) && (isa(args{1},'function_handle') || isa(args{1}, 'sym'))
        error(message('MATLAB:fplot:TooManyFunctions'));
    end

    searchLinespec;

    limits = [];
    if ~isempty(args) && isnumeric(args{1}) && isequal(size(args{1}), [1,2])
        limits = args{1};
        args(1) = [];
        matlab.graphics.function.internal.checkRangeVector(limits);
    end

    searchLinespec;

    if ~isempty(limits) && ~isempty(args) && isnumeric(args{1}) && isscalar(args{1})
        if round(args{1}) == args{1} && args{1} > 1 && isfinite(args{1})
            extraOpts = [extraOpts, {'MeshDensity', args{1}+1}];
        else
            warning(message('MATLAB:fplot:ToleranceDeprecated'));
        end
        args(1) = [];
    end

    searchLinespec;

    if numel(fn)==1
        if ischar(fn{1})
            fn{1} = str2fn(fn{1});
            if nargin(fn{1}) > 1
                error(message('MATLAB:fplot:TooManyVariables'));
            end
            warning(message('MATLAB:fplot:StringFunctionsDeprecated',func2str(fn{1})));
        end
    end

    for k=1:numel(fn)
        if isa(fn{k},'function_handle') && nargin(fn{k}) > 1
            error(message('MATLAB:fplot:TooManyVariables'));
        end
        if isa(fn{k},'sym') && ...
            contains(char(feval(symengine,'symobj::map',formula(fn{k}),'testtype','Type::Arithmetical')),'FALSE')
            error(message('MATLAB:fplot:InvalidExpression'));
        end
    end

    if numel(fn)==1 && isa(fn{1},'symfun')
        fn{1} = splitSymfun(fn{1});
    end
    if numel(fn)==1 && isa(fn{1},'function_handle')
        fn{1} = splitFunctionHandle(fn{1});
    end

    if numel(fn)==1
        validParameters = properties('matlab.graphics.function.FunctionLine');
    else
        validParameters = properties('matlab.graphics.function.ParameterizedFunctionLine');
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

    if mod(numel(args),2)~=0
        error(message('MATLAB:fplot:InvalidPairs'));
    end

    nextPlot = 'add';
    if doPlot && (isempty(cax) || ishghandle(cax,'axes'))
        cax = newplot(cax);
        nextPlot = cax.NextPlot;
    end
    if nargout < 2
        extraOpts = [extraOpts, {'Parent'}, {cax}];
    end

    hObj = vectorizeFplot(cax,fn,limits,extraOpts,args);

    if ismember(nextPlot, {'replace','replaceall'})
        box(cax,'on');
        axis(cax,'tight');
    end

    if nargout == 1
        varargout = {hObj(:)};
    elseif nargout == 2
        warning(message('MATLAB:fplot:TwoOutputsDeprecated'));
        varargout = {hObj.XData, hObj.YData};
    end
end


function hObj = vectorizeFplot(cax,fn,limits,extraOpts,args) 
   args = matlab.graphics.internal.convertStringToCharArgs(args);
   for i=1:numel(fn)
        if ~iscell(fn{i})
            if matlab.graphics.internal.isCharOrString(fn{i})
                fn{i} = splitString(fn{i});
            elseif isscalar(fn{i}) % TODO: symfun
                fn{i} = fn(i);
            else
                fn{i} = num2cell(fn{i});
            end
        end
    end
    if 1==numel(fn)
        hObj = cellfun(@(f) singleFplot(cax,{f},limits,extraOpts,args),fn{1},'UniformOutput',false);
    else
        if numel(fn{1})==1
            fn{1} = repmat(fn{1},size(fn{2}));
        end
        if numel(fn{2})==1
            fn{2} = repmat(fn{2},size(fn{1}));
        end
        hObj = cellfun(@(f1,f2) singleFplot(cax,{f1,f2},limits,extraOpts,args),fn{1},fn{2},'UniformOutput',false);
    end
    hObj = [hObj{:}];
end

function hObj=singleFplot(cax,fn,limits,extraOpts,args)
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

    if numel(fn) == 1
        if nvars > 1
            error(message('MATLAB:fplot:TooManyVariables'));
        end
        if ~isempty(limits)
            extraOpts = [extraOpts, {'XRange'}, {limits}];
        end
        hObj = matlab.graphics.function.FunctionLine(fn{1},extraOpts{:},args{:});
    else
        assert(numel(fn)==2);
        if nvars > 1
            error(message('MATLAB:fplot:TooManyVariables'));
        end
        if ~isempty(limits)
            extraOpts = [extraOpts, {'TRange'}, {limits}];
        end
        hObj = matlab.graphics.function.ParameterizedFunctionLine(fn{1},fn{2},[],extraOpts{:},args{:});    
    end
end

function fns=splitString(fn)
    % 'cos(x)' -> {'cos(x)'}, '[cos(x),sin(x)]' -> {'cos(x)','sin(x)'}
    fn = strtrim(fn);
    if fn(1)=='[' && fn(end)==']'
        fns = strsplit(fn(2:end-1),',');
        % to not split 'besseli(1,x)', join strings until the number of opening and closing parens matches
        for i=1:numel(fns)-1
            while i<numel(fns) && sum(fns{i}=='(') > sum(fns{i}==')')
                fns{i} = strjoin(fns(i:i+1),',');
                fns(i+1) = [];
            end
        end
        fns = cellfun(@strtrim,fns,'UniformOutput',false);
    else
        fns = {fn};
    end
end

function fn=splitFunctionHandle(fn)
    try
        fnAtZero = fn(0);
        if ~isscalar(fnAtZero)
            if isrow(fnAtZero)
                fn = arrayfun(@(n)splitVectorFunction(fn,n),1:numel(fnAtZero),'UniformOutput',false);
            else
                error(message('MATLAB:fplot:NonScalarFunction'));
            end
        end
    catch
        % ignore; if f(0) throws an error, just assume it's scalar
        % splitting function handles returning vectors is undocumented backward compatibility
    end
end

function fn1=splitVectorFunction(fn,n)
  function res=nthRow(x)
    res = fn(x(:));
    res = res(:,n).';
  end
  fn1 = @nthRow;
end

function fn1=splitSymfun(fn)
    vars = argnames(fn);
    v = formula(fn);
    if isscalar(v)
        fn1 = fn;
    else
        v = num2cell(v);
        fn1 = cellfun(@(f) symfun(f,vars), v, 'UniformOutput', false);
    end
end

function fn=str2fn(str)
  % Check for function vs. identity expression such as 't',
  % and convert to a consistent form
  vars = symvar(str);
  if isempty(vars)
    fn = eval(['@(t)' str '*ones(size(t))']);
  elseif exist(str,'builtin') || exist(str,'file')
    fn = str2func(str);
  else
    str = vectorize(str);
    vars = reshape(vars,1,[]);
    vars = [vars; repmat({','},1,numel(vars))];
    vars{end,end}=')';
    vars = ['@(' vars{:}];
    fn = eval([vars str]);
  end
end
