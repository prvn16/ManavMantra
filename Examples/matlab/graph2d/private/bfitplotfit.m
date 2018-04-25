function curveH = bfitplotfit(datahandle,axesh,figh,pp,fit)
% BFITPLOTFIT plots a fit.
%    [CURVEH, LEGENDH, EQNTXTH] = BFITPLOTFIT(PP) plots a fit based on PP 
%    (coefficients in a form PPVAL or POLYVAL can understand) and 
%    the residuals.

%   Copyright 1984-2014 The MathWorks, Inc.
%     


bfitlistenoff(figh)

% plot the fit 
% save hold state and units and set it
fignextplot = get(figh,'nextplot');
axesnextplot = get(axesh,'nextplot');
axesunits = get(axesh,'units');
set(figh,'nextplot','add');
set(axesh,'nextplot','add');
set(axesh,'units','normalized');

guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
normalized = getappdata(double(datahandle),'Basic_Fit_Normalizers');

if guistate.normalize
    meanx = normalized(1);
    stdx = normalized(2);
else
    meanx = 0;
    stdx = 1;
end
switch fit
case {0,1} % spline or pchip
    % Y = ppval(pp,newX);
    fun = @bfitppval;
otherwise
    % Y = polyval(pp,newX);
    fun = @bfitpolyval;
end
color_order = get(axesh,'colororder');
colorindex = mod(fit,size(color_order,1)) + 1;
name = createname(fit);

% Parent the line to the right child container dataspace
[~,hParent] = matlab.graphics.internal.plottools.getDataSpaceForChild(handle(datahandle));

curve = matlab.graphics.chart.primitive.FunctionLine(...
    'Function',fun,'Userargs',{pp,meanx,stdx},'Parent',hParent,'Tag',...
    name,'Color',color_order(colorindex,:));
bfitlisten(curve,1); %We need to add object being destroyed listener to this

% code generation for plot line
b = hggetbehavior(curve,'MCodeGeneration');
% Typecast to a handle since datahandle is a double
set(b,'MCodeConstructorFcn',{@bfitMCodeConstructor, 'fit', handle(datahandle), fit});

curveH = double(curve); % Convert to HG number handle.
fitappdata.type = 'fit'; 
fitappdata.index = fit + 1;
setappdata(curveH,'bfit',fitappdata);
setappdata(curveH, 'Basic_Fit_Copy_Flag', 1);

value = double(getappdata(double(datahandle),'Basic_Fit_Handles'));
% we assume this is initialized in setup as an array
value(fit + 1) = curveH;
setgraphicappdata(double(datahandle),'Basic_Fit_Handles', value);
value = getappdata(double(datahandle),'Basic_Fit_Showing');
% we assume this is initialized in setup as a logical array
value(fit + 1) = true;
setappdata(double(datahandle),'Basic_Fit_Showing', value);

% Later we'll upgrade to:
%curveH = curve.cline(func,{pp});

% reset plot: hold and units
set(figh,'nextplot',fignextplot);
set(axesh,'nextplot',axesnextplot);
set(axesh,'units',axesunits);

dlgh = getappdata(double(datahandle),'Basic_Fit_Dialogbox_Handle');
if ishghandle(dlgh) % if error or warning appeared, make sure it is on top
    figure(dlgh);
end
bfitlistenon(figh)

%----------------------------------
function name = createname(fit)
% CREATENAME  Create tag name for fit line.

switch fit
case 0
    name = sprintf('spline');
case 1
    name = sprintf('shape-preserving');
case 2
    name = sprintf('linear');
case 3
    name = sprintf('quadratic');
case 4
    name = sprintf('cubic');
otherwise
    name = sprintf('%sth degree',num2str(fit-1));
end

%--------------------------------------------------------
function Y = bfitppval(X,pp,meanx,stdx)
% BFITPPVAL Call PPVAL with arguments in order and possibly scaled.

newX  = (X - meanx)./(stdx);
Y = ppval(pp,newX);
%--------------------------------------------------------
function Y = bfitpolyval(X,pp,meanx,stdx)
% BFITPOLYVAL Call POLYVAL with arguments in order and possibly scaled.

newX  = (X - meanx)./(stdx);
Y = polyval(pp,newX);
