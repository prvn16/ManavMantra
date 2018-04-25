function findfigs
%FINDFIGS Position figures on to screen.
%   FINDFIGS will find all visible figures that are positioned 
%   completely off-screen and make them visible on screen at the top
%   left corner of the screen.
%
%   Example:
%       fig = figure; 
%       fig.Position = [2000 2000 500 500];
%       findfigs  %This should bring figure window to the top left of screen
%
%   See also ALLCHILD, FINDALL, FINDOBJ, GCA, GCF

%   Loren Dean
%   Copyright 1984-2015 MathWorks, Inc.

narginchk(0,0);
nargoutchk(0,0);

openFigures=findobj(allchild(0),'flat','Visible','on');

if isempty(openFigures)
  return
end % if isempty

workingUnits='points';

screenUnits=get(0,'Units');
set(0,'Units',workingUnits);
screenSize=get(0,'ScreenSize');
set(0,'Units',screenUnits);

figUnits=get(openFigures,{'Units'});
set(openFigures,'Units',workingUnits);
figPos=get(openFigures,{'Position'});
figPos=cat(1,figPos{:});

fLeft   = figPos(:,1)+figPos(:,3);
fRight  = figPos(:,1);
fTop    = figPos(:,2)+figPos(:,4);
fBottom = figPos(:,2)+figPos(:,4);

% Check Left, Right, Top, Bottom
insideBorderChk=5;
sLeft  = insideBorderChk;
sRight = screenSize(3)-insideBorderChk;
sTop   = screenSize(4)-insideBorderChk;
sBottom= insideBorderChk;

Loc=find(fLeft<sLeft | fRight>sRight | fTop>sTop | fBottom<sBottom);
% Create 20,75 point border inside of screen
insideBorderX=20;
insideBorderY=75;
if ~isempty(Loc)
  figPos(Loc,1)=insideBorderX;
  figPos(Loc,2)=screenSize(4)-figPos(Loc,4)-insideBorderY;
end

figPos=num2cell(figPos,2);
set(openFigures,{'Position'},figPos);
set(openFigures,{'Units'},figUnits);

