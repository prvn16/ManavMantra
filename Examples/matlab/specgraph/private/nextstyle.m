function [l,c,m] = nextstyle(ax,autoColor,autoStyle,~)
%NEXTSTYLE Get next plot linespec
%   [L,C,M] = NEXTSTYLE(AX) gets the next line style, color
%   and marker for plotting from the ColorOrder and LineStyleOrder
%   of axes AX.
%
%   See also PLOT, HOLD

%   [L,C,M] = NEXTSTYLE(AX,COLOR,STYLE,FIRST) gets the next line
%   style and color and increments the color index if COLOR is true
%   and the line style index if STYLE is true. If FIRST is true
%   then start the cycling from the start of the order unless HOLD
%   ALL is active. FIRST is only used in the 'handlegraphics' branch.

%   Copyright 1984-2016 The MathWorks, Inc.

if nargin == 1
    autoColor = true;
    autoStyle = true;
end

co = get(ax,'ColorOrder');
lo = get(ax,'LineStyleOrder');

ci = [1 1];

ci(1) = get(ax,'ColorOrderIndex');
ci(2) = get(ax,'LineStyleOrderIndex');

cm = size(co,1);
lm = size(lo,1);

if isa(lo,'cell')
  [l,~,m] = colstyle(lo{mod(ci(2)-1,lm)+1});
else
  [l,~,m] = colstyle(lo(mod(ci(2)-1,lm)+1,:));
end
c = co(mod(ci(1)-1,cm)+1,:);

if autoStyle && (~autoColor || ci(1) == cm)
  ci(2) = mod(ci(2),lm) + 1;
end
if autoColor
  ci(1) = mod(ci(1),cm) + 1;
end

set(ax,'ColorOrderIndex',ci(1));
set(ax,'LineStyleOrderIndex',ci(2));

if isempty(l) && ~isempty(m)
  l = 'none';
end
if ~isempty(l) && isempty(m)
  m = 'none';
end
