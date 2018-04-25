function [hh, ax] = pareto(varargin)
    %PARETO Pareto chart.
    %   PARETO(Y,NAMES) produces a Pareto chart where the values in the
    %   vector Y are drawn as bars in descending order.  Each bar will
    %   be labeled with the associated name in the string matrix or
    %   cell array NAMES.
    %
    %   PARETO(Y,X) labels each element of Y with the values from X.
    %   PARETO(Y) labels each element of Y with its index.
    %
    %   PARETO(AX,...) plots into AX as the main axes, instead of GCA.
    %
    %   [H,AX] = PARETO(...) returns a combination of patch and line object
    %   handles in H and the handles to the two axes created in AX.
    %
    %   See also HISTOGRAM, BAR.
    
    %   Copyright 1984-2017 The MathWorks, Inc.

    % Parse possible Axes input
    [cax, args, nargs] = axescheck(varargin{:});
    
    if nargs == 0
        error(message('MATLAB:pareto:NotEnoughInputs'));
    end
    y = args{1};
    y = datachk(y,'numeric');
    if nargs == 1
        m = length(sprintf('%.0f', length(y)));
        names = reshape(sprintf(['%' int2str(m) '.0f'], 1:length(y)), m, length(y))';
    elseif nargs == 2
        names = args{2};
         % We need to consider string arrays and cell array of scalar
         % strings
        if iscell(names) || isstring(names)
            names = matlab.graphics.internal.convertStringToCharArgs(names);
            names = char(names);
        elseif ~matlab.graphics.internal.isCharOrString(names)
            names = num2str(names(:));
        end
    end
    
    if (min(size(y)) ~= 1)
        error(message('MATLAB:pareto:YMustBeVector'));
    end
    
    % If the data is complex, disregard any complex component, and warn the user.
    if (~isreal(y))
        warning(message('MATLAB:specgraph:private:specgraph:UsingOnlyRealComponentOfComplexData'));
        y = real(y);
    end
    
    y = y(:);
    [yy, ndx] = sort(y);
    yy = flipud(yy);
    ndx = flipud(ndx);
    
    cax = newplot(cax);
    fig = ancestor(cax, 'figure');
    
    hold_state = ishold(cax);
    
    h = bar(cax, 1:length(y), yy);
    
    h = [h; line(1:length(y), cumsum(yy), 'Parent', cax)];
    ysum = sum(yy);
    
    if ysum == 0
        ysum = eps;
    end
    k = min(find(cumsum(yy) / ysum > .95, 1), 10);
    
    if isempty(k)
        k = min(length(y), 10);
    end
    
    xLim = [.5 k+.5];
    yLim = [0 ysum];
    set(cax, 'XLim', xLim);
    set(cax, 'XTick', 1:k, 'XTickLabel', mat2cell(names(ndx(1:k), :), ones(1, k)), 'YLim', yLim);
    
    % Hittest should be off for the transparent axes so that click and
    % mouse motion events are attributed to the opaque axes.
    raxis = axes('Position', get(cax, 'Position'), 'Color', 'none', ...
        'XGrid', 'off', 'YGrid', 'off', 'YAxisLocation', 'right', ...
        'XLim', xLim, 'YLim', yLim, 'HitTest', 'off', ...
        'HandleVisibility', get(cax, 'HandleVisibility'), ...
        'Parent', fig);
    yticks = get(cax, 'YTick');
    if max(yticks) < .9 * ysum
        yticks = unique([yticks, ysum]);
    end
    set(cax, 'YTick', yticks)
    s = cell(1, length(yticks));
    for n = 1:length(yticks)
        s{n} = [int2str(round(yticks(n) / ysum * 100)) '%'];
    end
    set(raxis, 'YTick', yticks, 'YTickLabel', s, 'XTick', []);
    set(fig, 'CurrentAxes', cax);
    linkaxes([raxis, cax],'xy');
    
    if ~hold_state
        hold(cax, 'off');
        set(fig, 'NextPlot', 'replacechildren');
    end
    
    if nargout > 0
        hh = h;
        ax = [cax raxis];
    end
end

