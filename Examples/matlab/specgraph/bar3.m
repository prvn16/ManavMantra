function hh = bar3(varargin)
%BAR3   3-D bar graph.
%     BAR3(Z) creates a 3-D bar chart, where each element in Z corresponds
%     to one vertical bar. When Z is a vector, the y-axis scale ranges from
%     1 to length(Z). When Z is a matrix, the y-axis scale ranges from 1 to
%     the number of rows in Z. 
%  
%     BAR3(Y,Z) draws the bars at the locations specified in vector Y.  The 
%     y-values can be nonmonotonic, but cannot contain duplicate values.
%  
%     BAR3(...,WIDTH) controls the separation between bars. A WIDTH value
%     greater than 1 produces overlapped bars. The default WIDTH value is
%     0.8.
%  
%     BAR3(...,STYLE) specifies the bar style, where STYLE is either
%     'detached', 'grouped', or 'stacked'. The default STYLE value is
%     'detached'.
% 
%     BAR3(...,COLOR) specifies the line color. Specify the color as one of
%     these values: 'r', 'g', 'b', 'y', 'm', 'c', 'k', or 'w'.
%  
%     BAR3(AX,...) plots into the axes AX instead of the current axes.
%  
%     S = BAR3(...) returns a vector of Surface objects.
%  
%     Example:
%         subplot(1,2,1) 
%         bar3(peaks(5))
%         subplot(1,2,2) 
%         bar3(rand(5),'stacked')
%  
%   See also BAR, BARH, and BAR3H.

%   Mark W. Reichelt 8-24-93
%   Revised by CMT 10-19-94, WSun 8-9-95
%   Copyright 1984-2017 The MathWorks, Inc.

narginchk(1,inf);
[cax,args] = axescheck(varargin{:});

[msg,x,y,xx,yy,linetype,plottype,barwidth,zz] = makebars(args{:},'3');
if ~isempty(msg)
    if strcmp(msg.identifier,'MATLAB:xychk:XAndYLengthMismatch')
        error(message('MATLAB:bar:YAndZLengthMismatch'));
    else
        error(msg);
    end
end 

m = size(y,2);
% Create plot
cax = newplot(cax);
fig = ancestor(cax,'figure');

nextPlot = cax.NextPlot;
edgec = get(fig,'DefaultAxesXColor');
facec = 'flat';
cc = ones(size(yy,1),4);

if ~isempty(linetype)
    facec = linetype;
end

n = size(yy,2)/4;
h = gobjects(1,n);
for i=1:n
    h(i) = surface('xdata',xx+x(i),...
        'ydata',yy(:,(i-1)*4+(1:4)), ...
        'zdata',zz(:,(i-1)*4+(1:4)),...
        'cdata',i*cc, ...
        'FaceColor',facec,...
        'EdgeColor',edgec,...
        'tag','bar3',...
        'parent',cax);
end

if length(h)==1
    set(cax,'clim',[1 2]);
end

if ~strcmp(nextPlot,'add')
    % Set ticks if less than 16 integers
    if all(all(floor(y)==y)) && (size(y,1)<16)
        set(cax,'ytick',y(:,1));
    end
    
    xTickAmount = sort(unique(x(1,:)));
    if length(xTickAmount)<2
        set(cax,'xtick',[]);
    elseif length(xTickAmount)<=16
        set(cax,'xtick',xTickAmount);
    end  %otherwise, will use xtickmode auto, which is fine
    
    cax.YDir = 'reverse';
    
    if plottype==0
        set(cax,'xlim',[1-barwidth/m/2 max(x)+barwidth/m/2])
    else
        set(cax,'xlim',[1-barwidth/2 max(x)+barwidth/2])
    end
    
    dx = diff(get(cax,'xlim'));
    dy = size(y,1)+1;
    if plottype==2
        set(cax,'PlotBoxAspectRatio',[dx dy (sqrt(5)-1)/2*dy])
    else
        set(cax,'PlotBoxAspectRatio',[dx dy (sqrt(5)-1)/2*dy])
    end
    
    view(cax, 3);
end

if ismember(nextPlot, {'replaceall','replace'})
    grid(cax, 'on');
end

if nargout>0
    hh = h;
end
