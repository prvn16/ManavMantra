function plotresults = bfitcheckplotresults(checkon,datahandle,fit)
% BFITCHECKPLOTRESULTS Plot the evaluated results for a given data and fit.

%   Copyright 1984-2014 The MathWorks, Inc.

% plot the fit 
axesh = ancestor(datahandle,'axes');
figh = ancestor(axesh, 'figure');
% save hold state and units and set it
fignextplot = get(figh,'nextplot');
axesnextplot = get(axesh,'nextplot');
axesunits = get(axesh,'units');
set(figh,'nextplot','add');
set(axesh,'units','normalized');

bfitlistenoff(figh)

plotresults = getappdata(double(datahandle),'Basic_Fit_EvalResults');   
% plotresults.handle won't be valid if we get here from a paste axes. 
if ~isempty(plotresults.handle) && ishghandle(plotresults.handle)
    delete(plotresults.handle);
end

if checkon
    axesH  = ancestor(datahandle, 'axes');
    color_order = get(axesH,'colororder');
    colorindex = mod(fit,size(color_order,1)) + 1;

    % some of the new "series", such as barseries do not have marker
    % properties - in those cases, use diamond
    marker = 'diamond';
    if isprop(datahandle, 'marker') && isequal('diamond',get(datahandle,'marker'))
        marker = 'square';
    end
    if ~isempty(plotresults.x) && ~isempty(plotresults.y)

        needtoresethold = true;
        if ishold(axesH)
            needtoresethold = false;
        else
            hold(axesH, 'on');
        end

        tag = createname(fit);
        displayName = getString(message('MATLAB:graph2d:bfit:evaluated', bfitgetdisplayname(fit)));
        plotresults.handle = plot(plotresults.x,plotresults.y,'parent', axesH, ...
            'Tag', tag, 'DisplayName', displayName, 'color',color_order(colorindex,:),...
            'marker',marker,'linestyle','none','LineWidth',2);

        % code generation for plot line
        b = hggetbehavior(plotresults.handle,'MCodeGeneration');
        % typecast to a handle since datahandle is a double
        set(b,'MCodeConstructorFcn',{@bfitMCodeConstructor, 'evalResults', handle(datahandle), fit});
        
        if needtoresethold
            hold(axesH, 'off');
        end

        fitappdata.type = 'evalresults';
        fitappdata.index = fit + 1;
        setappdata(double(plotresults.handle),'bfit',fitappdata);
        setappdata(double(plotresults.handle), 'Basic_Fit_Copy_Flag', 1);
    else
        % No data to plot, so we just assume the user wants to
        % "preset" that checkbox for later.
        % We could put out a status message, but for now we don't.
        plotresults.handle = [];
    end
else
    plotresults.handle = [];
end
appdata_plotresults = plotresults;
if ~isempty(appdata_plotresults.handle)
    appdata_plotresults.handle = handle(appdata_plotresults.handle);
end
setappdata(double(datahandle), 'Basic_Fit_EvalResults',appdata_plotresults);
   
guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
guistate.plotresults = checkon;
setappdata(double(datahandle),'Basic_Fit_Gui_State', guistate);

% update legend
bfitcreatelegend(axesh);

% reset plot: hold and units
set(figh,'nextplot',fignextplot);
set(axesh,'nextplot',axesnextplot);
set(axesh,'units',axesunits);

bfitlistenon(figh)

%----------------------------------
function name = createname(fit)
% CREATENAME  Create tag name for evalresults line.

switch fit
case 0
    name = sprintf('evaluated: spline');
case 1
    name = sprintf('evaluated: shape-preserving');
case 2
    name = sprintf('evaluated: linear'); 
case 3
    name = sprintf('evaluated: quadratic'); 
case 4
    name = sprintf('evaluated: cubic');
otherwise
    name = sprintf('evaluated: %sth degree',num2str(fit-1));
end
