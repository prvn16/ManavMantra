function h = barhV6(cax, varargin)
% This function is undocumented and may change in a future release.

%   Copyright 1984-2017 The MathWorks, Inc.

% v6 version of the barh command

narginchk(1,inf);

[msg,x,~,xx,yy,linetype,~,~,equal] = makebars(varargin{:});
if ~isempty(msg), error(msg); end

% Create plot
cax = newplot(cax);
fig = ancestor(cax,'figure');

next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);
edgec = get(fig,'DefaultAxesXColor');
facec = 'flat';
h = [];
cc = ones(size(xx,1),1);
if ~isempty(linetype)
    facec = linetype;
end
for i=1:size(xx,2)
    numBars = (size(xx,1)-1)/5;
    for j=1:numBars
        f(j,:) = (2:5) + 5*(j-1);
    end
    v = [yy(:,i) xx(:,i)];
    h=[h patch('faces', f, 'vertices', v, 'cdata', i*cc, ...
        'FaceColor',facec,'EdgeColor',edgec,'parent',cax)];
end
if length(h)==1
    set(cax,'clim',[1 2]),
end
if ~equal
    hold(cax,'on'),
    plot(zeros(size(x,1),1),x(:,1),'*','parent',cax)
end
if ~hold_state
    % Set ticks if less than 16 integers
    if all(all(floor(x)==x)) && (size(x,1)<16)
        set(cax,'ytick',x(:,1))
    end
    hold(cax,'off'), view(cax,2), set(cax,'NextPlot',next);
    set(cax,'Layer','Bottom','box','on')
    % Switch to SHADING FLAT when the edges start to overwhelm the colors
    if size(xx,2)*numBars > 150
        shading flat,
    end
end