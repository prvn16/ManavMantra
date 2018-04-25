function h = fplot3(varargin)
%FPLOT3   Plot 3-D parametric curve
%   FPLOT3(FUNX,FUNY,FUNZ) plots the parametric curve FUNX(T), FUNY(T), and
%   FUNZ(T) over the default domain -5 < T < 5.
%
%   FPLOT3(FUNX,FUNY,FUNZ,[TMIN TMAX]) plots the curve FUNX(T), FUNY(T),
%   and FUNZ(T) over TMIN < T < TMAX.
%
%   FPLOT3(...,'LineSpec') plots with the given line specification.
%
%   FPLOT3(AX,...) plots into AX instead of the current axes.
%
%   H = FPLOT3(...) returns handles to the plotted objects in H.
%
%   Examples:
%      fplot3(@sin,@cos,@log)
%      fplot3(@(t) sin(2*t),@(t) cos(t), @(t) sin(3*t+2), [-pi,pi], '--*')
%      fplot3(@cos, @(t) t.*sin(t), @sqrt)
%      fplot3(@(x)x.*cos(x),@(x)x.*sin(x),@log,[0.1 123],'LineWidth',2)   
%
%   If your function has additional parameters, for example k in myfuntk:
%      %-----------------------%
%      function s = myfuntk(t,k)
%      s = t.^k .* sin(t);
%      %-----------------------%
%   then you may use an anonymous function to specify that parameter:
%
%      fplot3(@cos,@(t)myfuntk(t,1),@sqrt)
%
%   See also FPLOT, FCONTOUR, FSURF, PLOT, PLOT3, VECTORIZE, FUNCTION_HANDLE.

%   Copyright 2015-2017 The MathWorks, Inc.


    % Parse possible Axes input
    [cax, args] = axescheck(varargin{:});
    
    narginchk(3,inf);
    fn = args(1:3);
    args(1:3) = [];

    for k=1:3
        if iscell(fn{k})
            cellfun(@(f)validateattributes(f,{'function_handle','sym'},{}),fn{k},'UniformOutput',false);
        else
            validateattributes(fn{k},{'function_handle','sym'},{});
        end
    end

    extraOpts = {};
    linespecfound = false;
    function searchLinespec()
        if ~linespecfound && ~isempty(args) && matlab.graphics.internal.isCharOrString(args{1})
            [l,c,m,msg] = colstyle(args{1});
            if isempty(msg)
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

    nextPlot = 'add';
    if isempty(cax) || ishghandle(cax,'axes')
        cax = newplot(cax);
        nextPlot = cax.NextPlot;
    end
    if ~isempty(args) && isnumeric(args{1}) && numel(args{1})==2
        extraOpts = [extraOpts, {'TRange'}, args(1)];
        args(1) = [];
        searchLinespec;
    end
    extraOpts = [extraOpts, {'Parent'}, {cax}];

    for k=1:numel(fn)
        if isa(fn{k},'function_handle') && nargin(fn{k}) > 1
            error(message('MATLAB:fplot:TooManyVariables'));
        end
    end
    if countvars(fn) > 1
        error(message('MATLAB:fplot:TooManyVariables'));
    end

    hObj = vectorizeFplot3(cax,fn,extraOpts,args);

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

function hObj = vectorizeFplot3(cax,fn,extraOpts,args)
    %Convert any string args to char
    args = matlab.graphics.internal.convertStringToCharArgs(args);
    for i=1:3
        if ~iscell(fn{i})
            if isscalar(fn{i}) % TODO: symfun
                fn{i} = fn(i);
            else
                fn{i} = num2cell(fn{i});
            end
        end
    end
    nfuns = max(cellfun(@numel,fn));
    for i=1:3
      if numel(fn{i})==1
          fn{i} = repmat(fn{i},1,nfuns);
      end
    end
    hObj = cellfun(@(f1,f2,f3) singleFplot3(cax,{f1,f2,f3},extraOpts,args),fn{1},fn{2},fn{3},'UniformOutput',false);
    hObj = [hObj{:}];
end

function hObj=singleFplot3(cax,fn,extraOpts,args)
    %Convert any string args to char
    args = matlab.graphics.internal.convertStringToCharArgs(args);
    % plot an individual function
    [autostyle,autocolor,automarker] = nextstyle(cax,true,true,false);
    if ~any(cellfun(@(x) isequal(x,'Color'),args)) && ~any(cellfun(@(x) isequal(x,'Color'),extraOpts))
        extraOpts = [extraOpts, {'Color'}, {autocolor}];
    end
    if ~any(cellfun(@(x) isequal(x,'LineStyle'),args)) && ~any(cellfun(@(x) isequal(x,'LineStyle'),extraOpts))
        extraOpts = [extraOpts, {'LineStyle'}, {autostyle}];
    end
    if ~any(cellfun(@(x) isequal(x,'Marker'),args)) && ~any(cellfun(@(x) isequal(x,'Marker'),extraOpts))
        extraOpts = [extraOpts, {'Marker'}, {automarker}];
    end

    hObj = matlab.graphics.function.ParameterizedFunctionLine(fn{1},fn{2},fn{3},extraOpts{:},args{:});
end
