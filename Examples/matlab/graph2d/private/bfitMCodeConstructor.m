function bfitMCodeConstructor(~, hCode, linetype, datahandle, fit, stattype, xon)
% BFITMCODECONSTRUCTOR code generation constructor for basic fitting and data stats

%   Copyright 2006-2016 The MathWorks, Inc.

BFDSFigure = ancestor(datahandle, 'figure');

% Check whether we have created code that gets the data that basic
% fit/stats relies on.  The first time it is called, this will also
% initialize the total item counter.
checkCreateGetData(hCode, linetype, BFDSFigure);

switch linetype
    case{'fit'}
        fitsMCodeConstructor(hCode, datahandle, fit);
    case{'stat'}
        GenInfo = getGenMfileInfo(BFDSFigure);
        hDSXdata = codegen.codeargument('Value', GenInfo.DataStats.xName, 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xdata');
        hDSYdata = codegen.codeargument('Value', GenInfo.DataStats.yName, 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'ydata');
        statsMCodeConstructor(hCode, datahandle, stattype, xon, hDSXdata, hDSYdata);
    case{'evalResults'}
        evalResultsMCodeConstructor(hCode, datahandle, fit);
    otherwise
        error(message('MATLAB:bfitMCodeConstructor:UnknownLineType'));
end

itemsLeft = getAppdataOrDefault(BFDSFigure, 'Basic_Fit_Data_Stats_Gen_MFile_Item_Counter',0);
if itemsLeft>1
    itemsLeft = itemsLeft - 1;
    setappdata(BFDSFigure, 'Basic_Fit_Data_Stats_Gen_MFile_Item_Counter', itemsLeft);
else
     % last fit: clean up appdata that is no longer required
    removeAppdataIfExists(BFDSFigure, 'Basic_Fit_Data_Stats_Gen_MFile_Item_Counter');
    removeAppdataIfExists(BFDSFigure, 'Basic_Fit_Data_Stats_Gen_MFile_Info');
end


%--------------------------------------------------------------
function evalResultsMCodeConstructor(hCode, datahandle, fit)

% get axes
hAxes = ancestor(datahandle, 'axes');
hAxesArg = codegen.codeargument('Value',hAxes,'IsParameter',true);

guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
normalize = guistate.normalize;

hXdata = codegen.codeargument('Value', 'BFDSxdata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xdata');
hYdata = codegen.codeargument('Value', 'BFDSydata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'ydata');
 
% Assigning a value here to work around a code gen bug (without this the 
% input argument is repeated as many times as it is referenced in the
% generated code
hXArg = codegen.codeargument('Value', rand(1,1), 'IsParameter',true,'Name', 'valuesToEvaluate');
hCode.addComment(message('MATLAB:graph2d:bfit:CommentEvaluateInput'));

hYArg = codegen.codeargument('IsParameter',true,'Name', 'Y', 'IsOutputArgument',true);

hCode.addText('if ~isa(', hXArg, ', ''double'')');
hCode.addText('    error(''GeneratedCode:InvalidInput'', ...');
hCode.addText('        ''', message('MATLAB:graph2d:bfit:InputValueMustEvaluateToReal'), ''');');
hCode.addText('end');

hCode.addText('if ~isreal(', hXArg, ')');
hCode.addText('    warning(''GeneratedCode:ImaginaryPartIgnored'', ...');
hCode.addText('        ''', message('MATLAB:graph2d:bfit:ImaginaryPartOfInputIgnored'), ''');');
hCode.addText('    ', hXArg, ' = real(', hXArg, ');');
hCode.addText('end');

hCode.addComment(message('MATLAB:graph2d:bfit:CommentMakeSureInputArgumentIsAColumn'));
hCode.addText(hXArg, ' = ', hXArg, '(:);');

hCode.addText(' ');

hFitResults = codegen.codeargument('Value', 'BFDSFitResults', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'fitResults');
hMu = codegen.codeargument('Value', 'BFDSmu', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'mu');
hNormalizedXdata = codegen.codeargument('Value', 'BFDSNormalizedXdata', ...
    'IsParameter',true, 'IsOutputArgument', true, 'Name', 'normalizedXdata');
hNormalizedValues = codegen.codeargument('Value', 'BFDSNormalizedValues', ...
    'IsParameter',true, 'IsOutputArgument', true, 'Name', 'normalizedValues');

generateFitAndEvaluateCode(hCode, hXdata, hYdata, ...
    hFitResults, hMu, hNormalizedXdata, hNormalizedValues, ...
    hXArg, hYArg, fit, normalize);

hCode.addComment(message('MATLAB:graph2d:bfit:CommentMakeSureValueIsAColumn'));
hCode.addText(hYArg, ' = ', hYArg, '(:);');

% plot (the Constructor)
setConstructorName(hCode, 'plot');
con = getConstructor(hCode);
set(con,'Comment', message('MATLAB:graph2d:bfit:CommentPlotTheEvaluatedResults'));
hEvalResultsLine = codegen.codeargument('IsParameter',true, 'Name', 'evalResultsLine', 'IsOutputArgument',true);
addConstructorArgout(hCode, hEvalResultsLine);
% plot input argument: x
addConstructorArgin(hCode,hXArg);
% plot input argument: y
addConstructorArgin(hCode,hYArg);
hDisplayName = codegen.codeargument('Value', 'DisplayName', 'IsParameter', false, 'ArgumentType', codegen.ArgumentType.PropertyName);
% get the length of the longest legend entry and add 3 for the indent;
legendStringLength = bfitgetmaxlegendlength() + 3;
legendString = bfitgetlegendstring('eval results', 0, legendStringLength);
hDisplayNameArg = codegen.codeargument('Value', legendString, 'IsParameter', false, 'ArgumentType', codegen.ArgumentType.PropertyValue);
addConstructorArgin(hCode, hDisplayName);
addConstructorArgin(hCode, hDisplayNameArg);
%%% end plot 

% Reorder lines so the legend is correct
hSetLineOrder = getLineOrderSubFunc(hCode);

% find the plot
hPlot = datahandle;
hPlotArg = codegen.codeargument('Value',hPlot,'IsParameter',true);

hCode.addPostConstructorText(' ');
hCode.addPostConstructorFunction(hSetLineOrder, {hAxesArg, hEvalResultsLine, hPlotArg}, ...
    message('MATLAB:graph2d:bfit:CommentResetLineOrderForLegend'));

% Mark properties that we've handled here as ignored
ignoreProperty(hCode,{'xdata','ydata','zdata', 'DisplayName'});

% Generate param-value syntax for remainder of properties
generateDefaultPropValueSyntaxNoOutput(hCode);

%--------------------------------------------------------
function statsMCodeConstructor(hCode, datahandle, stattype, xon, hDSXdata, hDSYdata)

% get axes
hAxes = ancestor(datahandle, 'axes');
hAxesArg = codegen.codeargument('Value',hAxes,'IsParameter',true);

hAxYLimArg = codegen.codeargument('Value', 'BFDSAxYLim', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'axYLim');
hAxXLimArg = codegen.codeargument('Value', 'BFDSAxXLim', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'axXLim');

xfitsshowing = getappdata(datahandle, 'Data_Stats_X_Showing');
numxfits = sum(xfitsshowing);
yfitsshowing = getappdata(datahandle, 'Data_Stats_Y_Showing');
numyfits = sum(yfitsshowing);

if ~isappdata(datahandle, 'Data_Stats_Gen_MFile_Fit_Counter') %first time
    fitsleft = numxfits + numyfits;
    setappdata(datahandle, 'Data_Stats_Gen_MFile_Fit_Counter', fitsleft);
    
    if numxfits > 0
        % Get axes ylim
        hCode.addPreConstructorFunction('get', {hAxesArg, 'ylim'}, {hAxYLimArg}, ...
            message('MATLAB:graph2d:bfit:CommentGetAxesYlim'));
    end
    if numyfits > 0
        % Get axes xlim
        hCode.addPreConstructorFunction('get', {hAxesArg, 'xlim'}, {hAxXLimArg}, ...
            message('MATLAB:graph2d:bfit:CommentGetAxesYlim'));
    end
    hCode.addText(' ');
    setappdata(datahandle, 'Data_Stats_Gen_MFile_Fit_Counter', fitsleft);
end

fitsleft = getappdata(datahandle, 'Data_Stats_Gen_MFile_Fit_Counter');

if fitsleft == 1 % last fit
    removeAppdataIfExists(datahandle, 'Data_Stats_Gen_MFile_Fit_Counter');
else
   fitsleft = fitsleft - 1;
   setappdata(datahandle, 'Data_Stats_Gen_MFile_Fit_Counter', fitsleft);
end

hPlot = datahandle;
hPlotArg = codegen.codeargument('Value',hPlot,'IsParameter',true);

argName = [stattype 'Value'];
hStatValueArg = codegen.codeargument('IsParameter',true, 'Name', argName, 'IsOutputArgument',true);

% Generate call to 'stat' e.g. "xmean = mean(x1)" %

if xon
    statArgName = ['x' stattype];
    meanName = 'xmean';
    statdata = hDSXdata;
    hLimsVar = hAxYLimArg;
    legendtype = 'xstat';
else
    statArgName = ['y' stattype];
    meanName = 'ymean';
    statdata = hDSYdata;
    hLimsVar = hAxXLimArg;
    legendtype = 'ystat';
end

% Calculate the statistic
hStat = codegen.codeargument('Value', '', 'IsParameter',true, 'IsOutputArgument', true, 'Name', statArgName);
hCode.addPreConstructorFunction(stattype, {statdata}, {hStat}, ...
    message('MATLAB:graph2d:bfit:CommentFindTheString', stattype));

if strcmp(stattype, 'std')
    hCode.addText(' ');
    
    % Calculate the mean and create XData for two lines to indicate upper/lower std.
    hMean= codegen.codeargument('Value', 'BFDSxmean', 'IsParameter',true, 'IsOutputArgument', true, 'Name', meanName);
    hCode.addPreConstructorFunction('mean', {statdata}, {hMean}, ...
        message('MATLAB:graph2d:bfit:CommentPrepareValuesToPlotStdFirstFindTheMean'));

    hCode.addComment(message('MATLAB:graph2d:bfit:CommentComputeBoundsAsMeanStd'));
    hLowVal = codegen.codeargument('Value', 'BFDSLowVal', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'lowerBound');
    hCode.addText(hLowVal, ' = ', hMean, ' - ', hStat, ';');
    hHighVal = codegen.codeargument('Value', 'BFDSHighVal', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'upperBound');
    hCode.addText(hHighVal, ' = ', hMean, ' + ', hStat, ';');
    hCode.addComment(message('MATLAB:graph2d:bfit:CommentGetCoordinatesForTheStdBoundsLine'));
    hCode.addText(hStatValueArg,' = [', hLowVal, ' ', hLowVal, ' NaN ', hHighVal, ' ',  hHighVal, ' NaN];'); 
    
    % Create input data
    hAxYStdLimArg = codegen.codeargument('IsParameter',true, 'Name', 'axYStdLim', 'IsOutputArgument',true);
    hCode.addText(hAxYStdLimArg, ' = [', hLimsVar,  ' NaN ',  hLimsVar, ' NaN];');
    hCode.addText(' ');
    hStatInputArg = hAxYStdLimArg;
else
    % Create XData at the statistic's value
    hCode.addComment(message('MATLAB:graph2d:bfit:CommentGetCoordinatesForLine', stattype));
    hCode.addText(hStatValueArg, ' = [', hStat, ' ',  hStat, '];');
    
    % Use YLim variable as the input data input
    hStatInputArg = hLimsVar;
end
% End generate code to "stat" %

% plot (the Constructor)
setConstructorName(hCode, 'plot');
con = getConstructor(hCode);
if strcmp(stattype, 'std')
    set(con,'Comment', message('MATLAB:graph2d:bfit:CommentPlotTheBounds'));
else
    set(con,'Comment', message('MATLAB:graph2d:bfit:CommentPlotTheString', stattype));
end

hStatLine = codegen.codeargument('IsParameter',true, 'Name', 'statLine', 'IsOutputArgument',true);
addConstructorArgout(hCode, hStatLine);

if xon
    % plot input argument: x
    addConstructorArgin(hCode,hStatValueArg);
    % plot input argument: y
    addConstructorArgin(hCode,hStatInputArg);
else
    % plot input argument: x
    addConstructorArgin(hCode,hStatInputArg);
    % plot input argument: y
    addConstructorArgin(hCode,hStatValueArg);
end

% get the length of the longest legend entry and add 3 for the indent;
legendStringLength = bfitgetmaxlegendlength() + 3;
legendString = bfitgetlegendstring(legendtype, getlegendstrtype(stattype), legendStringLength);

hDisplayName = codegen.codeargument('Value', 'DisplayName', 'IsParameter', false, 'ArgumentType', codegen.ArgumentType.PropertyName);
hDisplayNameArg = codegen.codeargument('Value', legendString, 'IsParameter', false, 'ArgumentType', codegen.ArgumentType.PropertyValue);
addConstructorArgin(hCode, hDisplayName);
addConstructorArgin(hCode, hDisplayNameArg);

% Reorder lines so the legend is correct
hSetLineOrder = getLineOrderSubFunc(hCode);

hCode.addPostConstructorText(' ');
hCode.addPostConstructorFunction(hSetLineOrder, {hAxesArg, hStatLine, hPlotArg}, ...
    message('MATLAB:graph2d:bfit:CommentSetNewLineInProperPosition'));

% For generating plot command with constant line, adding 'Value' to the list of ignoring properties:
ignoreProperty(hCode,{'xdata','ydata','zdata', 'DisplayName','Value'});

% Generate param-value syntax for remainder of properties
generateDefaultPropValueSyntaxNoOutput(hCode);

% -------------------------------------------------------------------------
function strtype = getlegendstrtype(stattype)

strtype = 0;
switch stattype
    case {'min'}
        strtype = 1;
    case {'max'}
        strtype = 2;
    case {'mean'}
        strtype = 3;
    case {'median'}
        strtype = 4;
    case {'mode'}
        strtype = 5;
    case {'std'}
        strtype = 6;
end

%--------------------------------------------------------
function fitsMCodeConstructor(hCode, datahandle, fit)

guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
plotresids = guistate.plotresids;
plottype = guistate.plottype;
subplot = guistate.subplot;
showresid = guistate.showresid;
showequations = guistate.equations;

fitsshowing = find(getappdata(datahandle,'Basic_Fit_Showing'));

% find the plot
hPlot = datahandle;
hPlotArg = codegen.codeargument('Value',hPlot,'IsParameter',true);
    
% get the axes
hAxes = ancestor(datahandle, 'axes');
hAxesArg = codegen.codeargument('Value',hAxes,'IsParameter',true);

% create variables for xdata and ydata
hXdata = codegen.codeargument('Value', 'BFDSxdata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xdata');
hYdata = codegen.codeargument('Value', 'BFDSydata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'ydata');    

hFittypesArray = codegen.codeargument('Value', 'BFDSfittypesArray', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'fittypesArray');
hXPlotArg = codegen.codeargument('Value', 'BFDSXPlotArg', 'IsParameter',true,'IsOutputArgument', true, 'Name', 'xplot');

if plotresids
    % create variable for resid axis
    hResidAxes = codegen.codeargument('Value', 'BFDSResidAxes', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'residAxes'); 
    hResidPlot = codegen.codeargument('Value', 'BFDSResidPlot', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'residPlot'); 
    hSortedXdata = codegen.codeargument('Value', 'BFDSSortedXdata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'sortedXdata'); 
    hXind = codegen.codeargument('Value', 'BFDSXind', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xInd'); 
end

if showequations
    hCoeffs = codegen.codeargument('Value', 'BFDSCoeffs', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'coeffs'); 
end

if ~isappdata(datahandle, 'Basic_Fit_Gen_MFile_Fit_Counter') % first fit
    fitsleft = length(fitsshowing);
    setappdata(datahandle, 'Basic_Fit_Gen_MFile_Fit_Counter', fitsleft);
   
    % Remove NaN values and warn
    hCode.addComment(message('MATLAB:graph2d:bfit:CommentRemoveNaNValuesAndWarn'));
    hNanMask = codegen.codeargument('Value', 'BFDSNanMask', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'nanMask');
    hCode.addText(hNanMask,' = isnan(', hXdata, '(:)) | isnan(', hYdata, '(:));');
    hCode.addText('if any(', hNanMask, ')');
    hCode.addText('warning(''GeneratedCode:IgnoringNaNs'', ...');
    hCode.addText('        ''', message('MATLAB:graph2d:bfit:WarningPointsWithNaNCoordsIgnored'), ''');');
    hCode.addText(hXdata, '(', hNanMask, ') = [];');
    hCode.addText(hYdata, '(', hNanMask, ') = [];');
    hCode.addText('end');
    hCode.addText(' ');

    hCode.addComment(message('MATLAB:graph2d:bfit:CommentFindXValuesForPlottingTheFitBasedOnXlim'));
    hAxesLimits = codegen.codeargument('Value', 'BFDSaxesLimits', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'axesLimits');
    hCode.addText(hAxesLimits, ' = xlim(', hAxesArg, ');');
    hCode.addText(hXPlotArg, ' = linspace(', hAxesLimits, '(1), ', hAxesLimits, '(2));');
    hCode.addText(' ');

    if plotresids
        hCode.addComment(message('MATLAB:graph2d:bfit:CommentPrepareForPlottingResiduals'));
        % subplot values refer to the position in the drop down,
        % therefore 0 = subplot, 1 = separate figure
        if subplot == 0 % subplot
            hCode.addText('set(', hAxesArg,',''position'',[0.1300    0.5811    0.7750    0.3439]);');
            hCode.addText(hResidAxes, ' = axes(''position'', [0.1300    0.1100    0.7750    0.3439], ...');
            hCode.addText('      ''parent'', gcf);');
        else % separate figure
            hResidFigure = codegen.codeargument('Value', 'BFDSResidFigure', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'residFigure');
            hResidPos = codegen.codeargument('Value', 'BFDSResidPos', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'residPos');    
            hCode.addComment(message('MATLAB:graph2d:bfit:CommentCreateASeparateFigureForResiduals'));
            hCode.addText(hResidFigure, ' = figure();');
            hCode.addComment(message('MATLAB:graph2d:bfit:CommentRepositionResidualFigure'));
            hCode.addText('set(', hResidFigure, ',''units'',''pixels'');');
            hCode.addText(hResidPos, ' = get(', hResidFigure, ',''position'');');
            hCode.addText('set(', hResidFigure, ',''position'', ', hResidPos, ' + [50 -50 0 0]);');
            hCode.addText(hResidAxes, ' = axes(''parent'', ', hResidFigure, ');'); 
        end
        hNumFits = codegen.codeargument('Value', length(fitsshowing),'IsParameter',false);
        % By setting the value here and using the same handle with the same
        % value elsewhere makes code generator treat all the variables as
        % the same.
        hSavedResids = codegen.codeargument('Value', 'BFDSSavedResiduals', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'savedResids');
        hCode.addText(hSavedResids, ' = zeros(length(', hXdata, '), ', hNumFits, ');');
        hCode.addComment(message('MATLAB:graph2d:bfit:CommentSortResiduals'));
        hCode.addText('[', hSortedXdata, ', ', hXind, '] = sort(', hXdata, ');');
        hCode.addText(' ');
    end
    if showequations
        hCode.addComment(message('MATLAB:graph2d:bfit:CommentPreallocateForShowEquationsCoefficients'));
        hNumFits = codegen.codeargument('Value', length(fitsshowing),'IsParameter',false);
        hCode.addText(hCoeffs, ' = cell(', hNumFits, ',1);');
        hCode.addText('  ');
    end
end

fitsleft = getappdata(datahandle, 'Basic_Fit_Gen_MFile_Fit_Counter');

% Calculate the fit and plot it.
genmfilecalcfitandplot(hCode, datahandle, fit, hAxesArg, hPlotArg)

if fitsleft == 1 % last fit
    if plotresids
        hSavedResids = codegen.codeargument('Value', 'BFDSSavedResiduals', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'savedResids');
        hCode.addPostConstructorText(' ');
        switch plottype
            case(0) % barplot
                hCode.addPostConstructorComment(message('MATLAB:graph2d:bfit:CommentPlotResidualsInABarPlot'));
                hCode.addPostConstructorText(hResidPlot, ' = bar(', hResidAxes, ', ', hSortedXdata, ', ', hSavedResids, ');');
            case(1) % scatterplot
                hCode.addPostConstructorComment(message('MATLAB:graph2d:bfit:CommentPlotResidualsInAScatterPlot'));
                hCode.addPostConstructorText(hResidPlot, ' = plot(', hSortedXdata, ',', hSavedResids, ',''.'',''parent'', ', hResidAxes, ');');
            case(2) % lineplot
                hCode.addPostConstructorComment(message('MATLAB:graph2d:bfit:CommentPlotResidualsInALinePlot'));
                hCode.addPostConstructorText(hResidPlot, ' = plot(', hSortedXdata, ',', hSavedResids, ',''parent'', ', hResidAxes, ');');
            otherwise
                error(message('MATLAB:bfitMCodeConstructor:UnknownPlotType'));
        end
        setresidcolorsandnames(hCode, fitsshowing, plottype, hAxes, subplot);
        hCode.addPostConstructorComment(message('MATLAB:graph2d:bfit:CommentSetResidualPlotAxisTitle'));
        hCode.addPostConstructorText('title(', hResidAxes, ', ''', message('MATLAB:graph2d:bfit:TitleResiduals'), ''');');
        % if separate figure turn on legend
        if (subplot == 1)
            hCode.addPostConstructorComment(message('MATLAB:graph2d:bfit:CommentShowLegendOnResidualPlot'));
            hCode.addPostConstructorText('legend(', hResidAxes, ', ''show'');');
        end
        if showresid
            hCode.addPostConstructorText(' ');
            hSubFun = createShowNormOfResiduals(hCode);
            hSavedNormResids = codegen.codeargument('Value', 'BFDSSavedNormResiduals', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'savedNormResids');
            
            
            hCode.addPostConstructorFunction(hSubFun, {hResidAxes, hFittypesArray, hSavedNormResids}, ...
                message('MATLAB:graph2d:bfit:CommentShowNormOfResidualsWasSelected'));
        end
    end
    
    if showequations
        hCode.addPostConstructorText(' ');
        normalized = guistate.normalize && any(fitsshowing>2);
        
        % Create subfunction that we will call
        hSubFun = createShowEquations(hCode, normalized);
        
        % Create a commented call to the showEquations subfunction
        hInputs = {hFittypesArray, hCoeffs, guistate.digits, hAxesArg};
        if normalized
            % Add input to normalize
            hInputs{end+1}= hXdata;
        end
        hCode.addPostConstructorFunction(hSubFun, hInputs, message('MATLAB:graph2d:bfit:CommentShowEquationsWasSelected'));
    end

    removeAppdataIfExists(datahandle, 'Basic_Fit_Gen_MFile_Fit_Counter');
else
    fitsleft = fitsleft - 1;
    setappdata(datahandle, 'Basic_Fit_Gen_MFile_Fit_Counter', fitsleft);
end

% ----------------------------------------------------------------
function genmfilecalcfitandplot(hCode, datahandle, fit, hAxesArg, hPlotArg)
% GENMFILECALCFIT Calculate fits and residuals and plot.

guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
normalized = guistate.normalize;
plotresids = guistate.plotresids;
showequations = guistate.equations;
showresid = guistate.showresid;

hXPlotArg = codegen.codeargument('Value', 'BFDSXPlotArg', 'IsParameter',true,'IsOutputArgument', true, 'Name', 'xplot');
hYPlotArg = codegen.codeargument('IsParameter',true,'Name', 'yplot', 'IsOutputArgument',true);

hXdata = codegen.codeargument('Value', 'BFDSxdata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xdata');
hYdata = codegen.codeargument('Value', 'BFDSydata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'ydata');
hFitResults = codegen.codeargument('Value', 'BFDSFitResults', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'fitResults');
hMu = codegen.codeargument('Value', 'BFDSmu', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'mu');
hNormalizedXdata = codegen.codeargument('Value', 'BFDSNormalizedXdata', ...
    'IsParameter',true, 'IsOutputArgument', true, 'Name', 'normalizedXdata');
hNormalizedValues = codegen.codeargument('Value', 'BFDSNormalizedXPlot', ...
    'IsParameter',true, 'IsOutputArgument', true, 'Name', 'normalizedXplot');

generateFitAndEvaluateCode(hCode, hXdata, hYdata, ...
    hFitResults, hMu, hNormalizedXdata, hNormalizedValues, ...
    hXPlotArg, hYPlotArg, fit, normalized);

if plotresids || showequations
    fitsshowing = find(getappdata(datahandle,'Basic_Fit_Showing'));
    index = find(fitsshowing == fit+1);
    hIndexArg = codegen.codeargument('Value', index, 'IsParameter',false);
end
if (plotresids && showresid) || showequations
    hCode.addText(' ');
    if (plotresids && showresid) && ~showequations  % only show norm of resids
        hCode.addComment(message('MATLAB:graph2d:bfit:CommentSaveTypeOfFitForShowNormOfResiduals'));
    elseif ~(plotresids && showresid) && showequations % only show equations
        hCode.addComment(message('MATLAB:graph2d:bfit:CommentSaveTypeOfFitForShowEquations'));
    else % both show norm of resids and show equations
        hCode.addComment(message('MATLAB:graph2d:bfit:CommentSaveTypeOfFitForShowNormOfResidualsAndShowEquations'));
    end
    hFittypesArray = codegen.codeargument('Value', 'BFDSfittypesArray', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'fittypesArray');
    hFittype = codegen.codeargument('Value', fit,'IsParameter',false);
    hCode.addText(hFittypesArray, '(', hIndexArg, ') = ', hFittype, ';');
end
if plotresids
    %% Calculate resid
    hCode.addText(' ');
    comment = message('MATLAB:graph2d:bfit:CommentCalculateAndSaveResidualsEvaluateUsingOriginalXdata');
    hYfit = codegen.codeargument('Value', 'BFDSYfit', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'Yfit');
    if fit == 0 || fit == 1 %% spline or pchip
        if normalized
            hCode.addPreConstructorFunction('ppval', {hFitResults, hNormalizedXdata}, {hYfit}, comment);
        else
            hCode.addPreConstructorFunction('ppval', {hFitResults, hXdata}, {hYfit}, comment);
        end
    else
        if normalized
            hCode.addPreConstructorFunction('polyval', {hFitResults, hXdata, [], hMu}, {hYfit}, comment);
        else
            hCode.addPreConstructorFunction('polyval', {hFitResults, hXdata}, {hYfit}, comment);
        end
    end
    
    % Find the index to store the resid in the matrix used to plot resids
    % We want the resids to be in the same order that fits are plotted
    % Fitsshowing has the order we want; fits are numbered one higher than
    % fit 
     
    hResid = codegen.codeargument('Value', 'BFDSresid', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'resid');
    hCode.addText(hResid, ' = ', hYdata, ' - ', hYfit, '(:);');
    hSavedResids = codegen.codeargument('Value', 'BFDSSavedResiduals', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'savedResids');
    hXind = codegen.codeargument('Value', 'BFDSXind', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xInd'); 
    hCode.addText(hSavedResids, '(:,', hIndexArg, ') = ', hResid, '(', hXind, ');');
    if showresid
        hSavedNormResids = codegen.codeargument('Value', 'BFDSSavedNormResiduals', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'savedNormResids');
        hCode.addText(hSavedNormResids, '(', hIndexArg, ') = norm(', hResid, ');');
    end
end
if showequations
    hCode.addText(' ');
    hCode.addComment(message('MATLAB:graph2d:bfit:CommentSaveCoefficientsForShowEquation'));
    hCoeffs = codegen.codeargument('Value', 'BFDSCoeffs', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'coeffs'); 
    hCode.addText(hCoeffs, '{', hIndexArg, '} = ', hFitResults, ';');
    hCode.addText(' ');
end

% plot (the Constructor)
setConstructorName(hCode, 'plot');
con = getConstructor(hCode);
set(con,'Comment', message('MATLAB:graph2d:bfit:CommentPlotTheFit'));

hFitLine = codegen.codeargument('IsParameter',true, 'Name', 'fitLine', 'IsOutputArgument',true);
addConstructorArgout(hCode, hFitLine);

% plot x
addConstructorArgin(hCode,hXPlotArg);
% plot y
addConstructorArgin(hCode,hYPlotArg);
hDisplayName = codegen.codeargument('Value', 'DisplayName', 'IsParameter', false, 'ArgumentType', codegen.ArgumentType.PropertyName);
% get the length of the longest legend entry and add 3 for the indent;
legendStringLength = bfitgetmaxlegendlength() + 3;
legendString = bfitgetlegendstring('fit', fit, legendStringLength);
hDisplayNameArg = codegen.codeargument('Value', legendString, 'IsParameter', false, 'ArgumentType', codegen.ArgumentType.PropertyValue);
addConstructorArgin(hCode, hDisplayName);
addConstructorArgin(hCode, hDisplayNameArg);

% Reorder the lines for the legend
hSetLineOrder = getLineOrderSubFunc(hCode);

hCode.addPostConstructorText(' ');
hCode.addPostConstructorFunction(hSetLineOrder, {hAxesArg, hFitLine, hPlotArg}, ...
    message('MATLAB:graph2d:bfit:CommentSetNewLineInProperPosition'));

ignoreProperty(hCode,{'xdata','ydata','zdata','DisplayName'});

% Generate param-value syntax for remainder of properties
generateDefaultPropValueSyntaxNoOutput(hCode);
% ---------------------------------------------------
function setresidcolorsandnames(hCode, fitsshowing, plottype, hAxes, subplot)

if (subplot == 0) % subplot
    hCode.addPostConstructorComment(message('MATLAB:graph2d:bfit:CommentSetColorsToMatchFitLines'));
else % separate figure 
    hCode.addPostConstructorComment(message('MATLAB:graph2d:bfit:CommentSetColorsToMatchFitLinesAndSetDisplayNames'));
end

hResidPlot = codegen.codeargument('Value', 'BFDSResidPlot', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'residPlot');

for i = 1:length(fitsshowing)
    name = bfitgetdisplayname(fitsshowing(i)-1);
    % the following is the same as in bfitplotfit so color coincides
    color_order = get(hAxes,'colororder');
    % minus one to fitsshowing(i) so fit type is correct
    colorindex = mod(fitsshowing(i)-1,size(color_order,1)) + 1;
    color = color_order(colorindex,:);
    hColorArg = codegen.codeargument('Value',color,'IsParameter',false);
    hNameArg = codegen.codeargument('Value',name,'IsParameter',false);
    % Don't bother to set the display name if resid are in a subplot
    hIndexArg = codegen.codeargument('Value',i,'IsParameter',false);
    if (plottype == 0) % barplot
        if (subplot == 0) % subplot
            hCode.addPostConstructorText('set(', hResidPlot, '(', hIndexArg, '), ''facecolor'', ', hColorArg, ',''edgecolor'', ', hColorArg, ');');
        else % separate figure
            hCode.addPostConstructorText('set(', hResidPlot, '(', hIndexArg, '), ''facecolor'', ', hColorArg, ',''edgecolor'', ', hColorArg, ', ...');
            hCode.addPostConstructorText('   ''DisplayName'', ', hNameArg, ');');
        end
    else
        if (subplot == 0) % subplot
            hCode.addPostConstructorText('set(', hResidPlot, '(', hIndexArg, '), ''color'', ', hColorArg, ');');
        else % separate figure
            hCode.addPostConstructorText('set(', hResidPlot, '(', hIndexArg, '), ''color'', ', hColorArg, ', ...');
            hCode.addPostConstructorText('   ''DisplayName'', ', hNameArg, ');');
        end
    end
end
   

%---------------------------------------------------
function generateFitAndEvaluateCode(hCode, hXDataVar, hYDataVar, ...
    hFitVar, hMu, hNormalizedXdata, hNormalizedXplot, ...
    hEvalXDataVar, hEvalYDataVar, fit, normalized)

if fit == 0 || fit== 1  %spline/pchip
    if fit==0
        % spline 
        fitcomment = message('MATLAB:graph2d:bfit:CommentFindCoefficientsForSplineInterpolant');
        fitfunc = 'spline';
    else
        % pchip
        fitcomment = message('MATLAB:graph2d:bfit:CommentFindCoefficientsForShapepreservingInterpolant');
        fitfunc = 'pchip';
    end
    evalcomment = message('MATLAB:graph2d:bfit:CommentEvaluatePiecewisePolynomial');
    evalfunc = 'ppval';
    
    if normalized
        % Generate code to find the mean of x, e.g. "meanx = mean(x)"
        addNormalizeCodeLine(hCode, message('MATLAB:graph2d:bfit:CommentNormalizeXdata'), ...
            hNormalizedXdata, hXDataVar)
        addNormalizeCodeLine(hCode, message('MATLAB:graph2d:bfit:CommentNormalizeValue'), ...
            hNormalizedXplot, hEvalXDataVar)
         
        fitinputs = {hNormalizedXdata, hYDataVar};   
        evalinputs = {hFitVar, hNormalizedXplot};
    else
        fitinputs = {hXDataVar, hYDataVar};
        evalinputs = {hFitVar, hEvalXDataVar};
    end
    
    fitoutputs = {hFitVar};
    
else
    order = fit-1;
    
    fitcomment = message('MATLAB:graph2d:bfit:CommentFindCoefficientsForPolynomial', order);
    fitfunc = 'polyfit';
    
    evalcomment = message('MATLAB:graph2d:bfit:CommentEvaluatePolynomial');
    evalfunc = 'polyval';
    
    fitinputs = {hXDataVar, hYDataVar, order};
        
    if normalized
        % Capture the mu output
        hIgnoreArg = codegen.codeargument('Value', 'BFDSIgnoreArg', 'IsParameter',true, 'IsOutputArgument', true, 'Name', '~');
        fitoutputs = {hFitVar, hIgnoreArg, hMu};
        evalinputs = {hFitVar, hEvalXDataVar, [], hMu};
    else
        fitoutputs = {hFitVar};
        evalinputs = {hFitVar, hEvalXDataVar};
    end
end
    
hCode.addPreConstructorFunction(fitfunc, fitinputs, fitoutputs, fitcomment);

hCode.addPreConstructorFunction(evalfunc, evalinputs, {hEvalYDataVar}, evalcomment);


%---------------------------------------------------
function addNormalizeCodeLine(hCode, comment, hNormVar, hVar)
if ~isempty(comment)
    hCode.addComment(comment);
end
hCode.addText(hNormVar, ' = (', hVar, ' - mean(', hVar, '))./(std(', hVar, '));');


%---------------------------------------------------
function hSetLineOrder = getLineOrderSubFunc(hCode)
% Look for an existing SetLineOrder subfunction and create it if it doesn't
% exist
hCodeParent = hCode.getParent();
hSetLineOrder = hCodeParent.findSubFunction('SetLineOrder');
if isempty(hSetLineOrder)
    hSetLineOrder = createSetLineOrder(hCodeParent);
end

% ---------------------------------------------------
function hSubFun = createSetLineOrder(hCode)
hSubFun = codegen.coderoutine;
hSubFun.Name = 'setLineOrder';
hSubFun.Comment = message('MATLAB:graph2d:bfit:CommentSetLineOrder');

% Create the input arguments
hAxes = codegen.codeargument;
hAxes.IsParameter = true;
hAxes.Name = 'axesh';
hAxes.Comment = message('MATLAB:graph2d:bfit:CommentAxes');

hNewLine = codegen.codeargument;
hNewLine.IsParameter = true;
hNewLine.Name = 'newLine';
hNewLine.Comment = message('MATLAB:graph2d:bfit:CommentNewLine');

hAssociatedLine = codegen.codeargument;
hAssociatedLine.IsParameter = true;
hAssociatedLine.Name = 'associatedLine';
hAssociatedLine.Comment = message('MATLAB:graph2d:bfit:CommentAssociatedLine');

hSubFun.addArgin(hAxes);
hSubFun.addArgin(hNewLine);
hSubFun.addArgin(hAssociatedLine);



hSubFun.addComment(message('MATLAB:graph2d:bfit:CommentGetTheAxesChildren'));
hSubFun.addText('hChildren = get(', hAxes, ',''Children'');');

hSubFun.addComment(message('MATLAB:graph2d:bfit:CommentRemoveTheNewLine'));
hSubFun.addText('hChildren(hChildren==', hNewLine, ') = [];');

hSubFun.addComment(message('MATLAB:graph2d:bfit:CommentGetTheIndexToTheAssociatedLine'));
hSubFun.addText('lineIndex = find(hChildren==', hAssociatedLine, ');');

hSubFun.addComment(message('MATLAB:graph2d:bfit:CommentReorderLinesSoTheNewLineAppearsWithAssociatedData'));
hSubFun.addText('hNewChildren = [hChildren(1:lineIndex-1);', hNewLine, ';hChildren(lineIndex:end)];');

hSubFun.addComment(message('MATLAB:graph2d:bfit:CommentSetTheChildren'));
hSubFun.addText('set(', hAxes, ',''Children'',hNewChildren);');

hCode.addSubFunction(hSubFun);

%---------------------------------------------------
function hSubFun = createShowEquations(hCode, normalized)

hSubFun = codegen.coderoutine;
hSubFun.Name = 'showEquations';
hSubFun.Comment = message('MATLAB:graph2d:bfit:CommentShowEquations');

% Create the input arguments
hFittypes = codegen.codeargument;
hFittypes.IsParameter = true;
hFittypes.Name = 'fittypes';
hFittypes.Comment = message('MATLAB:graph2d:bfit:CommentTypesOfFits');

hCoeffs = codegen.codeargument;
hCoeffs.IsParameter = true;
hCoeffs.Name = 'coeffs';
hCoeffs.Comment = message('MATLAB:graph2d:bfit:CommentCoefficients');

hDigits = codegen.codeargument;
hDigits.IsParameter = true;
hDigits.Name = 'digits';
hDigits.Comment = message('MATLAB:graph2d:bfit:CommentNumberOfSignificantDigits');

hAxesh = codegen.codeargument;
hAxesh.IsParameter = true;
hAxesh.Name = 'axesh';
hAxesh.Comment = message('MATLAB:graph2d:bfit:CommentAxes');

if normalized
    hXdata = codegen.codeargument;
    hXdata.IsParameter = true;
    hXdata.Name = 'xdata';
    hXdata.Comment = message('MATLAB:graph2d:bfit:CommentXData');
end

hSubFun.addArgin(hFittypes);
hSubFun.addArgin(hCoeffs);
hSubFun.addArgin(hDigits);
hSubFun.addArgin(hAxesh);
if normalized
    hSubFun.addArgin(hXdata);
end

hSubFun2 = createGetEquationString(hSubFun, normalized);

hSubFun.addText('n = length(', hFittypes, ');');
if normalized
    hSubFun.addText('txt = cell(length(n + 2) ,1);');
else
    hSubFun.addText('txt = cell(length(n + 1) ,1);');
end
hSubFun.addText('txt{1,:} = '' '';');
hSubFun.addText('for i = 1:n');
hSubFun.addText('    txt{i + 1,:} = ', hSubFun2, '(', hFittypes, '(i),', hCoeffs, '{i},', hDigits,',', hAxesh,');');
hSubFun.addText('end');
if normalized
    hSubFun.addText('meanx = mean(', hXdata, ');');
    hSubFun.addText('stdx = std(', hXdata, ');');
    hSubFun.addText('format = [''where z = (x - %0.'', num2str(', hDigits, '), ''g)/%0.'', num2str(', hDigits, '), ''g''];');
    hSubFun.addText('txt{n + 2,:} = sprintf(format, meanx, stdx);');
end
hSubFun.addText('text(.05,.95,txt,''parent'',', hAxesh, ', ...');
hSubFun.addText('    ''verticalalignment'',''top'',''units'',''normalized'');');

hCode.addSubFunction(hSubFun);

%---------------------------------------------------
function hSubFun = createGetEquationString(hCode, normalized)
% Create the subfunction object
hSubFun = codegen.coderoutine;

% Set the name
hSubFun.Name = 'getEquationString';

% Set the comment 
hSubFun.Comment = message('MATLAB:graph2d:bfit:CommentGetShowEquationString');

% Create the input arguments
hFittype = codegen.codeargument;
hFittype.IsParameter = true;
hFittype.Name = 'fittype';
hFittype.Comment = message('MATLAB:graph2d:bfit:CommentTypeOfFit');

hCoeffs = codegen.codeargument;
hCoeffs.IsParameter = true;
hCoeffs.Name = 'coeffs';
hCoeffs.Comment = message('MATLAB:graph2d:bfit:CommentCoefficients');

hDigits = codegen.codeargument;
hDigits.IsParameter = true;
hDigits.Name = 'digits';
hDigits.Comment = message('MATLAB:graph2d:bfit:CommentNumberOfSignificantDigits');

hAxesh = codegen.codeargument;
hAxesh.IsParameter = true;
hAxesh.Name = 'axesh';
hAxesh.Comment = message('MATLAB:graph2d:bfit:CommentAxes');

% Create the output argument
hString = codegen.codeargument;
hString.IsOutputArgument = true;
hString.IsParameter = true;
hString.Name = 's';

hSubFun.addArgin(hFittype);
hSubFun.addArgin(hCoeffs);
hSubFun.addArgin(hDigits);
hSubFun.addArgin(hAxesh);
hSubFun.addArgout(hString);

hSubFun.addText('if isequal(', hFittype, ', 0)');
hSubFun.addText('    ', hString, ' = ''', message('MATLAB:graph2d:bfit:CubicSplineInterpolant'), ''';');
hSubFun.addText('elseif isequal(', hFittype,', 1)');
hSubFun.addText('    ', hString,' = ''', message('MATLAB:graph2d:bfit:ShapePreservingInterpolant'), ''';');
hSubFun.addText('else');
hSubFun.addText('    op = ''+-'';');
if normalized
   hSubFun.addText('    format1 = [''%s %0.'',num2str(', hDigits, '),''g*z^{%s} %s''];');
else
   hSubFun.addText('    format1 = [''%s %0.'',num2str(', hDigits, '),''g*x^{%s} %s''];');
end
hSubFun.addText('    format2 = [''%s %0.'',num2str(', hDigits, '),''g''];');
hSubFun.addText('    xl = get(', hAxesh,', ''xlim'');');
hSubFun.addText('    fit =  ', hFittype, ' - 1;');
hSubFun.addText('    ', hString, ' = sprintf(''y ='');');
hSubFun.addText('    th = text(xl*[.95;.05],1,', hString, ',''parent'',', hAxesh, ', ''vis'',''off'');');
hSubFun.addText('    if abs(', hCoeffs, '(1) < 0)');
hSubFun.addText('        ', hString, ' = [', hString, ' '' -''];'); 
hSubFun.addText('    end');
hSubFun.addText('    for i = 1:fit');
hSubFun.addText('        sl = length(', hString, ');');
hSubFun.addText('        if ~isequal(', hCoeffs, '(i),0) % if exactly zero, skip it ');
hSubFun.addText('            ', hString, ' = sprintf(format1,', hString, ',abs(', hCoeffs, '(i)),num2str(fit+1-i), op((', hCoeffs, '(i+1)<0)+1));');
hSubFun.addText('        end');
hSubFun.addText('        if (i==fit) && ~isequal(', hCoeffs, '(i),0)');
hSubFun.addText('            ', hString, '(end-5:end-2) = []; % change x^1 to x.');
hSubFun.addText('        end');
hSubFun.addText('        set(th,''string'',', hString, ');');
hSubFun.addText('        et = get(th,''extent'');');
hSubFun.addText('        if et(1)+et(3) > xl(2)');
hSubFun.addText('            ', hString, ' = [', hString, '(1:sl) sprintf(''\n     '') ', hString, '(sl+1:end)];');
hSubFun.addText('        end');
hSubFun.addText('    end');
hSubFun.addText('    if ~isequal(', hCoeffs, '(fit+1),0)');
hSubFun.addText('        sl = length(', hString, ');');
hSubFun.addText('       ', hString, ' = sprintf(format2,', hString, ',abs(', hCoeffs, '(fit+1)));');
hSubFun.addText('        set(th,''string'',', hString, ');');
hSubFun.addText('        et = get(th,''extent'');');
hSubFun.addText('        if et(1)+et(3) > xl(2)');
hSubFun.addText('            ', hString, ' = [', hString, '(1:sl) sprintf(''\n     '') ', hString, '(sl+1:end)];');
hSubFun.addText('        end');
hSubFun.addText('    end');
hSubFun.addText('    delete(th);');
hSubFun.addText('    % Delete last "+"');
hSubFun.addText('    if isequal(', hString, '(end),''+'')');
hSubFun.addText('        ', hString, '(end-1:end) = []; % There is always a space before the +.');
hSubFun.addText('    end');
hSubFun.addText('    if length(', hString, ') == 3');
hSubFun.addText('        ', hString, ' = sprintf(format2,', hString, ',0);');
hSubFun.addText('    end');
hSubFun.addText('end');

hCode.addSubFunction(hSubFun);

% ---------------------------------------------------
function hSubFun = createShowNormOfResiduals(hCode)
hSubFun = codegen.coderoutine;
hSubFun.Name = 'showNormOfResiduals';
hSubFun.Comment = message('MATLAB:graph2d:bfit:CommentShowNormOfResiduals');

% Create the input arguments
hResidaxes = codegen.codeargument;
hResidaxes.IsParameter = true;
hResidaxes.Name = 'residaxes';
hResidaxes.Comment = message('MATLAB:graph2d:bfit:CommentAxesForResiduals');

hFittypes = codegen.codeargument;
hFittypes.IsParameter = true;
hFittypes.Name = 'fittypes';
hFittypes.Comment = message('MATLAB:graph2d:bfit:CommentTypesOfFits');

hNormResids = codegen.codeargument;
hNormResids.IsParameter = true;
hNormResids.Name = 'normResids';
hNormResids.Comment = message('MATLAB:graph2d:bfit:CommentNormOfResiduals');

hSubFun.addArgin(hResidaxes);
hSubFun.addArgin(hFittypes);
hSubFun.addArgin(hNormResids);

hSubFun2 = createGetResidStrFun(hSubFun);

hSubFun.addText('txt = cell(length(', hFittypes, ') ,1);');
hSubFun.addText('for i = 1:length(', hFittypes, ')');
hSubFun.addText('    txt{i,:} = ', hSubFun2, '(', hFittypes, '(i),', hNormResids, '(i));');
hSubFun.addText('end');

hSubFun.addComment(message('MATLAB:graph2d:bfit:CommentSaveCurrentAxisUnitsThenSetToNormalized'));
hSubFun.addText('axesunits = get(', hResidaxes,',''units'');');
hSubFun.addText('set(', hResidaxes, ',''units'',''normalized'');');

hSubFun.addText('text(.05,.95,txt,''parent'',', hResidaxes, ', ...');
hSubFun.addText('    ''verticalalignment'',''top'',''units'',''normalized'');');

hSubFun.addComment(message('MATLAB:graph2d:bfit:CommentResetUnits'));
hSubFun.addText('set(', hResidaxes,',''units'',axesunits);');

hCode.addSubFunction(hSubFun);

% ---------------------------------------------------
function hSubFun = createGetResidStrFun(hCode)

% Create the subfunction object
hSubFun = codegen.coderoutine;

% Set the name
hSubFun.Name = 'getResidString';

% Set the comment 
hSubFun.Comment = message('MATLAB:graph2d:bfit:CommentGetShowNormOfResidualsString');

% Create the input arguments
hFittype = codegen.codeargument;
hFittype.IsParameter = true;
hFittype.Name = 'fittype';
hFittype.Comment = message('MATLAB:graph2d:bfit:CommentTypeOfFit');

hNormResid = codegen.codeargument;
hNormResid.IsParameter = true;
hNormResid.Name = 'normResid';
hNormResid.Comment = message('MATLAB:graph2d:bfit:CommentNormOfResiduals');

% Create the output argument
hString = codegen.codeargument;
hString.IsOutputArgument = true;
hString.IsParameter = true;
hString.Name = 's';

% Add the arguments to the subroutine
hSubFun.addArgin(hFittype);
hSubFun.addArgin(hNormResid);
hSubFun.addArgout(hString);

hSubFun.addComment(message('MATLAB:graph2d:bfit:CommentGetStringFromMessageCatalog'));
hSubFun.addText('switch ', hFittype);
hSubFun.addText('case 0');
hSubFun.addText('    ', hString, ' = getString(message(''MATLAB:graph2d:bfit:ResidualDisplaySplineNorm''));');
hSubFun.addText('case 1');
hSubFun.addText('    ', hString, ' = getString(message(''MATLAB:graph2d:bfit:ResidualDisplayShapepreservingNorm''));');
hSubFun.addText('case 2');
hSubFun.addText('    ', hString, ' = getString(message(''MATLAB:graph2d:bfit:ResidualDisplayLinearNorm'', num2str(', hNormResid, ')));');
hSubFun.addText('case 3');
hSubFun.addText('    ', hString, ' = getString(message(''MATLAB:graph2d:bfit:ResidualDisplayQuadraticNorm'', num2str(', hNormResid, ')));');
hSubFun.addText('case 4');
hSubFun.addText('    ', hString, ' = getString(message(''MATLAB:graph2d:bfit:ResidualDisplayCubicNorm'', num2str(', hNormResid, ')));');
hSubFun.addText('otherwise');
hSubFun.addText('    ', hString, ' = getString(message(''MATLAB:graph2d:bfit:ResidualDisplayNthDegreeNorm'', ', hFittype, '-1, num2str(', hNormResid, ')));');
hSubFun.addText('end');

hCode.addSubFunction(hSubFun);


function AllInfo = createBasicFitGetDataInfo(BFDSFigure)
% Create a structure of information about the basic fitting and data stats
% objects in the figure.

% Work out the number of Basic Fit objects
numFits = 0;
numEvalResultsPlots = 0;
basicFitCurrentData = getAppdataOrDefault(BFDSFigure, 'Basic_Fit_Current_Data', []);

if ~isempty(basicFitCurrentData)
    numFits = sum(getAppdataOrDefault(basicFitCurrentData, 'Basic_Fit_Showing', 0));
    
    evalResults = getAppdataOrDefault(basicFitCurrentData, 'Basic_Fit_EvalResults', []);
    if ~isempty(evalResults) && ~isempty(evalResults.handle)
        numEvalResultsPlots = 1;
    end
end

% Work out the number of Data Stats objects
numDataXStats = 0;
numDataYStats = 0;
dataStatsCurrentData = getAppdataOrDefault(BFDSFigure, 'Data_Stats_Current_Data', []);
if ~isempty(dataStatsCurrentData)
    numDataXStats = sum(getAppdataOrDefault(dataStatsCurrentData, 'Data_Stats_X_Showing', 0));
    numDataYStats = sum(getAppdataOrDefault(dataStatsCurrentData, 'Data_Stats_Y_Showing', 0));
end

% Set up a counter of items left that persists between calls
itemsLeft = numFits + numEvalResultsPlots + numDataXStats + numDataYStats;
setappdata(BFDSFigure, 'Basic_Fit_Data_Stats_Gen_MFile_Item_Counter', itemsLeft);

% Initialize data structures to track the code we create for getting
% data
BasicFitInfo = struct( ...
    'Required', (numFits + numEvalResultsPlots > 0), ...
    'Created', false, ...
    'PlotHandle', basicFitCurrentData, ...
    'xName', 'BFDSxdata', ...
    'yName', 'BFDSydata');

NeedDataStats = (numDataXStats + numDataYStats > 0);
if NeedDataStats ...
        && (numFits + numEvalResultsPlots > 0) ...
        && (dataStatsCurrentData==basicFitCurrentData)
    % Data stats shares a source handle with the basic fit and can reuse the
    % data created by its code.
    DSxName = 'BFDSxdata';
    DSyName = 'BFDSydata';
    NeedDataStats = false;
else
    DSxName = 'BFDSDSxdata';
    DSyName = 'BFDSDSydata';
end

DataStatsInfo = struct( ...
    'Required', NeedDataStats, ...
    'Created', false, ...
    'PlotHandle', dataStatsCurrentData, ...
    'xName', DSxName, ...
    'yName', DSyName);

AllInfo = struct('BasicFit', BasicFitInfo, 'DataStats', DataStatsInfo);


function checkCreateGetData(hCode, linetype, BFDSFigure)
% Check whether we need to/have created the data for the specified line
% type.

AllInfo = getGenMfileInfo(BFDSFigure);
switch linetype
    case {'fit', 'evalResults'}
        ThisName = 'BasicFit';
        xCommentID = 'MATLAB:graph2d:bfit:CommentGetXdataFromPlot';
        yCommentID = 'MATLAB:graph2d:bfit:CommentGetYdataFromPlot';
        
    case 'stat'
        ThisName = 'DataStats'; 
        xCommentID = 'MATLAB:graph2d:bfit:CommentGetXdataFromPlotForDataStatistics';
        yCommentID = 'MATLAB:graph2d:bfit:CommentGetYdataFromPlotForDataStatistics';

    otherwise
        error(message('MATLAB:bfitMCodeConstructor:UnknownLineType'));
end

if AllInfo.(ThisName).Required && ~AllInfo.(ThisName).Created
    % Create the code block 
    createGetDataBlock(hCode, AllInfo.(ThisName).PlotHandle, ...
        AllInfo.(ThisName).xName, AllInfo.(ThisName).yName, ...
        xCommentID, yCommentID);
    
    % Update Created flag
    AllInfo.(ThisName).Created = true;
    setappdata(BFDSFigure, 'Basic_Fit_Data_Stats_Gen_MFile_Info', AllInfo);
end


function createGetDataBlock(hCode, hPlot, xName, yName, xCommentID, yCommentID)
% Create a code block that gets data from a plot object and adds it as a
% sibling of the provided code block.

hThisCode = codegen.codeblock;
hParent = hCode.getParent();
hParent.addChildren(hThisCode);

hPlotArg = codegen.codeargument('Value',hPlot,'IsParameter',true);

hXdata = codegen.codeargument('Value', xName, 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xdata');
hYdata = codegen.codeargument('Value', yName, 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'ydata');

% getting x and y data from plot to deal with just y input.
hThisCode.addComment(message(xCommentID));
hThisCode.addText(hXdata, ' = get(', hPlotArg, ', ''xdata'');');
hThisCode.addComment(message(yCommentID));
hThisCode.addText(hYdata, ' = get(', hPlotArg, ', ''ydata'');');
hThisCode.addComment(message('MATLAB:graph2d:bfit:CommentMakeSureDataAreColumnVectors'));
hThisCode.addText(hXdata, ' = ', hXdata, '(:);');
hThisCode.addText(hYdata, ' = ', hYdata, '(:);');
hThisCode.addText(' ');


function AllInfo = getGenMfileInfo(BFDSFigure)
% Get the structure of data that tracks whether and what to create
% data-getting code for
AllInfo = getAppdataOrDefault(BFDSFigure, 'Basic_Fit_Data_Stats_Gen_MFile_Info', []);
if isempty(AllInfo)
    AllInfo = createBasicFitGetDataInfo(BFDSFigure);
    % Store the default value for future use
    setappdata(BFDSFigure, 'Basic_Fit_Data_Stats_Gen_MFile_Info', AllInfo);
end


function removeAppdataIfExists(hObj, AppdataName)
% Remove ApplicationData if it exists in an object
if isappdata(hObj, AppdataName)
    rmappdata(hObj, AppdataName);
end

function data = getAppdataOrDefault(hObj, AppdataName, Default)
% Return appdata if it exists in an object, otherwise return the specified
% default value.  This function is used when getting appdata that is not
% controlled by this function.
if isappdata(hObj, AppdataName)
    data = getappdata(hObj, AppdataName);
else
    data = Default;
end
