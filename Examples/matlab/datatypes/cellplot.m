function hh = cellplot(c,lims)
    %CELLPLOT Display graphical depiction of cell array.
    %   CELLPLOT(C) displays the structure of a cell array as nested
    %   colored boxes.
    %
    %   H = CELLPLOT(C) returns a vector of surface, line and text handles.
    %
    %   H = CELLPLOT(C,'legend') also puts a legend next to the plot.
    
    %   Copyright 1984-2012 The MathWorks, Inc.
    
    narginchk(1, 2);
    
    legend = false;
    
    if nargin > 1
        if ~ischar(lims) || ~strcmpi(lims, 'Legend')
            error(message('MATLAB:cellplot:InvalidLegendValue'));
        else
            legend = true;
        end
    end
    
    if isempty(c),if nargout>0, hh = []; end, return, end
    
    if ~iscell(c)
        error(message('MATLAB:cellplot:Arg1NotCellArray'));
    end
    
    % Set the plot parameters
    ax = newplot;
    hold_state = ishold;
    next = get(ax,'NextPlot');
    hold on
    m = size(c,1); n = size(c,2);
    if n==1, xlims = [.5 1.5]; else xlims = [0 n]; end
    if m==1, ylims = [.5 1.5]; else ylims = [0 m]; end
    lims = [xlims ylims];
    set(ax,'xlim',xlims,'ylim',ylims)
    
    % Plot each cell element 
    [h, d]= plotCellElement(c, lims); 
    
    % Post process the plot by removing xtick and ytick from the axes and
    % set corresponding colors to datatypes
    if ~hold_state,
        hold off
        set(ax,'xtick',[],'ytick',[],'nextplot',next)
        axis image, axis ij, axis off
        caxis([1 6]),
        colormap(prism(5))
        if legend,
            hc = colorbar;
            %ticklength size depends on Graphics Version. 
            %Using GET to ensure the correct dimensions.
            tl = get(hc,'ticklength'); 
            set(hc,'ytick',(1:5)+.5,'yticklabel', ...
                {'double','char','sparse','structure','other'},...
                'ticklength',0*tl);
        end
        set(ax,'xlim',get(ax,'xlim')+[0 d],'ylim',get(ax,'ylim')-[d 0])
    end
    
    if nargout>0, hh = h; end
end

function [h, d] = plotCellElement(c, lims)
    m = size(c,1); n = size(c,2);
    X = zeros(m,n);
    
    edgec = get(gca,'xcolor');
    for i=1:m*n,
        contents = c{i};
        X(i) = 2*ischar(contents) + 2*issparse(contents) + ...
            isa(contents,'double') + ...
            4*isstruct(contents); % Values from 1 to 4
        if X(i)==0, X(i)=5; end % Other case
    end
    
    % Draw cell grid
    dx = diff(lims(1:2)/n);
    dy = diff(lims(3:4)/m);
    delta = min(dx,dy);
    [x,y] = meshgrid(((0:n)-n/2)*delta+sum(lims(1:2))/2,...
        ((0:m)-m/2)*delta+sum(lims(3:4))/2);
    if ismatrix(c)
        d = 0;
        h = pcolor(x,y,ones(size(x)));
        set(h,'facecolor',get(gcf,'defaultaxescolor'),'edgecolor',edgec)
    else
        % Draw N-D cell array grid
        d = min(dx,dy)/5;
        [m,n,p] = size(c); h = [];
        for i=p-1:-1:0,
            h = [h;pcolor(x+d*i/(p-1),y-d*i/(p-1),ones(size(x)))]; %#ok<AGROW>
        end
        set(h,'facecolor',get(gcf,'defaultaxescolor'),'edgecolor',edgec)
        c = c(:,:,1); % Only recursively transverse the 1st page
    end
    lims = [([-n/2 n/2])*delta+sum(lims(1:2))/2 ...
        ([-m/2 m/2])*delta+sum(lims(3:4))/2];
    for i=1:m
        for j=1:n,
            contents = c{i,j};
            dx = diff(lims(1:2))/n; dy = diff(lims(3:4))/m;
            xlims = lims(1) + (j-1)*dx + [.1 .9]*dx;
            ylims = lims(3) + (i-1)*dy + [.1 .9]*dy;
            if iscell(contents),
                % Recursively display contents
                h = [h;plotCellElement(contents,[xlims ylims])]; %#ok<AGROW>
            elseif ~isempty(contents),
                mm = size(contents,1); nn = size(contents,2);
                dx = diff(xlims/nn);
                dy = diff(ylims/mm);
                delta = min(dx,dy);
                [x,y] = meshgrid(((0:nn)-nn/2)*delta+sum(xlims)/2,...
                    ((0:mm)-mm/2)*delta+sum(ylims)/2);
                if ismatrix(contents)
                    col = X(i,j)*ones(size(x));
                    hp = pcolor(x,y,col);
                    if ~isempty(contents) && ischar(contents),
                        col = X(i,j)*ones(size(contents));
                        col(contents==' ')=NaN;
                        set(hp,'CData',col)
                    end
                    
                else
                    pp = size(contents,3);
                    hp = [];
                    for ii=pp-1:-1:0,
                        hp = [hp;pcolor(x+delta/5*ii/(pp-1),y-delta/5*ii/(pp-1), ...
                            X(i,j)*ones(size(x)))]; %#ok<AGROW>
                    end
                end
                set(hp,'FaceColor','flat')
                h = [h;hp]; %#ok<AGROW>
                if ischar(contents) && size(contents,1)==1 && ...
                        length(contents)<15 && ismatrix(contents)
                    h = [h;text(sum(xlims)/2,sum(ylims/2),0, ...
                        fliplr(deblank(fliplr(deblank(contents)))),...
                        'horizontalalignment','center',...
                        'verticalalignment','middle','clipping','on')];%#ok
                elseif (isnumeric(contents) || islogical(contents)) && length(contents)==1,
                    h = [h;text(sum(xlims)/2,sum(ylims/2),0,num2str(double(contents)), ...
                        'horizontalalignment','center',...
                        'verticalalignment','middle','clipping','on')]; %#ok<AGROW>
                end
            end
        end
    end
end

