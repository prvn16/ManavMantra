function [strings,err] = bfitcheckfitbox(checkon,...
    datahandle,fit,showeqnon,digits,plotresidon,plottype,subploton,showresidon)
%

%   Copyright 1984-2016 The MathWorks, Inc.

strings = ' ';
err = 0;

axesH = ancestor(datahandle,'axes'); % need this in case subplots in figure
figH = ancestor(axesH,'figure');
bfitlistenoff(figH)

%
% preserve the legend AutoUpdate if not off and then turn AutoUpdate 'off'
% so that it doesn't conflict with Basic Fitting legend update
%
legH = legend('-find', axesH);
if ~isempty(legH) && ~strcmp(legH.AutoUpdate, 'off')
  if ~isempty(bfitFindProp(figH, 'bfit_Set_AutoUpdate_Function'))
    bfitSetAutoUpdateFcn = get(figH, 'bfit_Set_AutoUpdate_Function');
    bfitRestoreAutoUpdateFcn = get(figH, 'bfit_Restore_AutoUpdate_Function');
  else
    bfitSetAutoUpdateFcn = [];
    bfitRestoreAutoUpdateFcn = [];
  end

  if ~isempty(bfitSetAutoUpdateFcn)
    [autoUpdate, autoUpdateMode] = feval(bfitSetAutoUpdateFcn, @SetAutoUpdate, legH, 'off');
  else
    [autoUpdate, autoUpdateMode] = SetAutoUpdate(legH, 'off');
  end
end

if checkon
    % calculate fit and get resulting strings of info
    [strings, err, pp] = bfitcalcfit(datahandle,fit);
    if err
        dlgh = getappdata(double(datahandle),'Basic_Fit_Dialogbox_Handle');
        if ishghandle(dlgh) % if error or warning appeared, make sure it is on top
            figure(dlgh);
        end
        bfitlistenon(figH)
        return
    end
    
    % plot the curve/fit
    bfitplotfit(datahandle,axesH,figH,pp,fit);
    
    % update the legend so it's stuff + fits + evalresults
    bfitcreatelegend(axesH);
    
    % add equations to plot
    bfitcheckshowequations(showeqnon, datahandle, digits)
    
    % plot resids with other info on plot
    bfitcheckplotresiduals(plotresidon,datahandle,plottype,subploton,showresidon)
    
else % check off

    fitshandles = double(getappdata(double(datahandle),'Basic_Fit_Handles'));
    fitsshowinglogical = getappdata(double(datahandle),'Basic_Fit_Showing');
    % delete fitline from plot
    if ishghandle(fitshandles(fit+1)) && ~strcmpi(get(fitshandles(fit+1),'beingdeleted'),'on')
        delete(fitshandles(fit+1))
    end
    
    % Inf out the fitshowing appdata
    fitshandles(fit+1) = Inf;
    setgraphicappdata(double(datahandle),'Basic_Fit_Handles',fitshandles);
    fitsshowinglogical(fit+1) = false;
    setappdata(double(datahandle),'Basic_Fit_Showing',fitsshowinglogical);
    
    % update legend
    bfitcreatelegend(axesH);
    
    % update eqntxt
    bfitcheckshowequations(showeqnon, datahandle, digits)
    
    % plot resids with other info on plot
    bfitcheckplotresiduals(plotresidon,datahandle,plottype,subploton,showresidon)
   
end
dlgh = double(getappdata(double(datahandle),'Basic_Fit_Dialogbox_Handle'));
if ishghandle(dlgh) % if error or warning appeared, make sure it is on top
    figure(dlgh);
end
bfitlistenon(figH)

%
% restore legend AutoUpdate to what it was upon entry
% 
if ~isempty(legH) && exist('autoUpdate','var')
  if ~isempty(bfitRestoreAutoUpdateFcn)
    feval(bfitRestoreAutoUpdateFcn, @RestoreAutoUpdate, legH, autoUpdate, autoUpdateMode);
  else
    RestoreAutoUpdate(legH, autoUpdate, autoUpdateMode)
  end
end
end

%
% SetAutoUpdate - set the legend AutoUpdate property
%
function [autoUpdate, autoUpdateMode] = SetAutoUpdate(legH, autoUpdateSet)
autoUpdate = legH.AutoUpdate;
autoUpdateMode = legH.AutoUpdateMode;
legH.AutoUpdate = autoUpdateSet;
end

%
% RestoreAutoUpdate - restore the legend AutoUpdate property after being
% set
%
function RestoreAutoUpdate(legH, autoUpdate, autoUpdateMode)
legH.AutoUpdate = autoUpdate;
legH.AutoUpdateMode = autoUpdateMode;
end