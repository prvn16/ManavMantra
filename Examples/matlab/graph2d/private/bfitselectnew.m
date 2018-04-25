function [axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
        currentfit,coeffresidstrings] = bfitselectnew(figHandle, newdataHandle, createLegend)
% BFITSELECTNEW Update basic fit GUI and figure from current data to new data.

%   Copyright 1984-2010 The MathWorks, Inc.

% Flag indicating if we should re/create the legend
if nargin < 3 || isempty(createLegend)
    createLegend = true;
end

% for new data, was it showing before?
guistate = getappdata(double(newdataHandle),'Basic_Fit_Gui_State');
if isempty(guistate) % new data
    %setup appdata and compute stats: nothing plotted since new data
    [axesCount,fitschecked,bfinfo,~,currentfit] = bfitsetup(figHandle, newdataHandle, createLegend); % data stats computed
    evalresultsstr = '';  
    evalresultsx = '';
    evalresultsy = '';
    coeffresidstrings = ' ';
    
else % was showing before: get fit info to return, and replot
    [axesCount,fitschecked,bfinfo,evalresultsstr,~,~,currentfit,coeffresidstrings] = ...
        bfitgetcurrentinfo(newdataHandle);
    
    axesH = ancestor(newdataHandle,'axes'); % need this in case subplots in figure
    figH = ancestor(axesH,'figure');
    bfitlistenoff(figH)
       
    % All the fits that are plotted need to be recalculated and replotted.
    % Additionally, the currentfit needs to be recalculated even if it is
    % not plotted so that the correct information appears in the second
    % panel.
    % The following code assumes that the order the fits are plotted
    % does not make any difference.
    currentfitPlotted = false;
    for fitindex = find(fitschecked)
        fit = fitindex - 1;
        if isequal(fit,currentfit) % Currentfit handled separately below.
            currentfitPlotted = true;
        else
            [~, err, pp] = bfitcalcfit(newdataHandle,fit);
            if err % Shouldn't happen - data changes are now dealt with explicitly.
                % See bfitlisten.m
                error(message('MATLAB:bfitselectnew:calcfiterr'))
            end
            bfitplotfit(newdataHandle,axesH,figH,pp,fit);
        end
    end         
    % Calculate the currentfit (and replot if necessary) after the other 
    % fits so that the coeffresidstrings, which are returned from this 
    % function, contain information for the currentfit.   
    if ~isempty(currentfit) % update strings in 2nd panel if there
                            % is a current fit
          [coeffresidstrings, err, pp] = bfitcalcfit(newdataHandle,currentfit);
          if err % Shouldn't happen - data changes are now dealt with explicitly
                 % See bfitlisten.m
              error(message('MATLAB:bfitselectnew:calcfiterr'))
          end
          if currentfitPlotted
              bfitplotfit(newdataHandle,axesH,figH,pp,currentfit);
          end
    elseif isempty(currentfit)
        coeffresidstrings = ' ';  % if current fit is empty, the 2nd panel is empty
    end
    
    % update the legend so it's stuff + fits + evalresults
    bfitcreatelegend(axesH);
    
    % add equations to plot
    if guistate.equations
        bfitcheckshowequations(guistate.equations, newdataHandle, guistate.digits)
    end
    
    if guistate.plotresids
        % plot resids with other info on plot
        bfitcheckplotresiduals(guistate.plotresids,newdataHandle, ...
            guistate.plottype,~(guistate.subplot),guistate.showresid);
    end
    
	% Recalculate and replot Evaluated results if needed 
    plotresults = getappdata(double(newdataHandle),'Basic_Fit_EvalResults'); 
	% only "clearresults" if plotresults.x plotresults.y both empty
	clearresults = (isempty(plotresults.x) && isempty(plotresults.y)) || isempty(currentfit);
	[evalresultsx,evalresultsy] = ...
		bfitevalfitbutton(newdataHandle,currentfit, plotresults.string, guistate.plotresults, clearresults);
    % Make sure currentfit is what it was to begin with	(bfitcalcfit may have changed it)
    setappdata(double(newdataHandle),'Basic_Fit_NumResults_',currentfit);
    
    dlgh = getappdata(double(newdataHandle),'Basic_Fit_Dialogbox_Handle');
    if ishghandle(dlgh) % if error or warning appeared, make sure it is on top
        figure(dlgh);
    end
    bfitlistenon(figH)
end
