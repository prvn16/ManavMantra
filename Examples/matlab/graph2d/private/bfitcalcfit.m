function [strings, errRet, pp, resid] = bfitcalcfit(datahandle,fit)
% BFITCALCFIT  Calculate coefficients and residuals of FIT to data DATAHANDLE.

%   Copyright 1984-2014 The MathWorks, Inc.

strings = ' ';
errRet = 0;

if fit < 0 % select fit is cleared
    setappdata(double(datahandle),'Basic_Fit_NumResults_',[]);
    return
end

% get data
guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
xdata = double(get(datahandle,'xdata'));
ydata = double(get(datahandle,'ydata'));

% calculate fit with warnings turned off
ws = warning('off', 'all'); 
[lastwarnmsg, lastid] = lastwarn; % save warning in case no new warning
lastwarn('')
try
    [pp, resid, errRet, warnmsg] = calcfit(xdata,ydata,fit,datahandle,guistate);
catch errCalcfit %#ok<NASGU>
    errRet = 1;
    warnmsg = '';
end
lastwarn(lastwarnmsg, lastid); % set lastwarn to last warning
warning(ws);

% quit if error, warn if warning
if errRet
    return;
end
if isempty(warnmsg)
    dlgh = [];
else
    dlgh = warndlg(warnmsg,getString(message('MATLAB:graph2d:bfit:TitleBasicFitting')));
end
setgraphicappdata(double(datahandle),'Basic_Fit_Dialogbox_Handle',dlgh);


value = getappdata(double(datahandle),'Basic_Fit_Coeff');
% we assume this is initialized in setup as cell array
value{fit + 1} = pp;
setappdata(double(datahandle),'Basic_Fit_Coeff', value);

value = getappdata(double(datahandle),'Basic_Fit_Resids');
% we assume this is initialized in setup as a cell array
value{fit + 1} = resid;
setappdata(double(datahandle),'Basic_Fit_Resids', value);

% save last fit calculated
setappdata(double(datahandle),'Basic_Fit_NumResults_',fit);

% get other needed strings - ignore NaNs when calculating resids    
strings = bfitcreateeqnstrings(datahandle,fit,pp,norm(resid(~isnan(resid))));

% ----------------------------------------------
function [pp,resid,errRet,warnmsg] = calcfit(xdata,ydata,fit,datahandle,guistate)
% CALCFIT calculates a fit.
%    [COEFF, RESID, ERR, WMSG] = CALCFIT(X,Y,FIT) calculates a fit and 
%    returns coefficients in a form PPVAL or POLYVAL can understand, 
%    the residuals, an error indicator, and warning messages.

errRet = 0;
warnmsg = '';
distincterrid = 'MATLAB:chckxy:RepeatedSites';
twodataerrid = 'MATLAB:chckxy:NotEnoughPts';
title = getString(message('MATLAB:graph2d:bfit:TitleBasicFitting'));

% Remove NaN values but remember doing so
nanmask = isnan(xdata(:)) | isnan(ydata(:));
nandata = any(nanmask);
if nandata
   xdata(nanmask) = [];
   ydata(nanmask) = [];
end

if fit == 0 % spline
    if guistate.normalize
	    normalized = getappdata(double(datahandle),'Basic_Fit_Normalizers');
        newxdata  = (xdata - normalized(1))./(normalized(2));
    else
	    newxdata = xdata;
    end
    try
        pp = spline(newxdata,ydata);
    catch errSpline
        pp = [];
        resid = [];
        errRet = 1;
        if strcmp(errSpline.identifier,distincterrid)
            errmsg = getString(message('MATLAB:graph2d:bfit:ErrorRepeatedXValuesNotPermittedWCubicInt')); 
            dlgh = bfitcascadeerr(errmsg,title);
        elseif strcmp(errSpline.identifier,twodataerrid)
            errmsg = getString(message('MATLAB:graph2d:bfit:ErrorTwoPointsRequiredWCubic'));
            dlgh = bfitcascadeerr(errmsg,title);
        else
            dlgh = bfitcascadeerr({errSpline.message},title);
        end
        setgraphicappdata(double(datahandle),'Basic_Fit_Dialogbox_Handle',dlgh);
        return;
    end
    y = ppval(pp,newxdata);     % this should be all zeros for spline
elseif fit == 1 % pchip
    if guistate.normalize
    	normalized = getappdata(double(datahandle),'Basic_Fit_Normalizers');
        newxdata  = (xdata - normalized(1))./(normalized(2));
    else
		newxdata = xdata;
    end
    try
		pp = pchip(newxdata,ydata);
    catch errPchip
        pp = [];
        resid = [];
        errRet = 1;
        if strcmp(errPchip.identifier,distincterrid)
            errmsg = getString(message('MATLAB:graph2d:bfit:ErrorRepeatedXValuesNotPermittedWShapePres'));
            dlgh = bfitcascadeerr(errmsg,title);
        elseif strcmp(errPchip.identifier,twodataerrid)
            errmsg = getString(message('MATLAB:graph2d:bfit:ErrorTwoPointsRequiredWShapePres'));
            dlgh = bfitcascadeerr(errmsg,title);
        else
            dlgh = bfitcascadeerr({errPchip.message},title);
        end
        setgraphicappdata(double(datahandle),'Basic_Fit_Dialogbox_Handle',dlgh);
        return;
    end
    y = ppval(pp,newxdata);     % this should be all zeros for pchip
else % polynomial
    order = fit-1;
    centerscaleid = 'MATLAB:polyfit:RepeatedPointsOrRescale';
    repeatptsid = 'MATLAB:polyfit:RepeatedPoints';
    if guistate.normalize
		% polyfit calculates normalizers, so we don't have to getappdata.
        [pp,~,normalizers] = polyfit(xdata,ydata,order);
    else
        pp = polyfit(xdata,ydata,order);
    end
    if ~isempty(lastwarn)
        [~, lastwarnid] = lastwarn;
        centerwarn = strcmp(lastwarnid, centerscaleid);
        repeatwarn = strcmp(lastwarnid, repeatptsid);
        if centerwarn || repeatwarn
            waswarned = getappdata(double(datahandle),'Basic_Fit_Scaling_Warn');
            if isempty(waswarned)
                % only give these warnings once per data set
                setappdata(double(datahandle),'Basic_Fit_Scaling_Warn',1);
                if centerwarn
                    warnmsg = sprintf( ...
                    getString(message('MATLAB:graph2d:bfit:WarningPolynomialBadlyConditionedCenterScale')));
                else
                    warnmsg = sprintf( ...
                         getString(message('MATLAB:graph2d:bfit:WarningPolynomialIsBadlyConditionedUseLowerDegree')));
                end
            end
            lastwarn('');
        end
    end
	if guistate.normalize
	    y = polyval(pp,xdata,[],normalizers);
	else
	    y = polyval(pp,xdata);
	end
end

resid = ydata(:) - y(:);  % always column
if nandata
   fullresid = NaN(size(nanmask));
   fullresid(~nanmask) = resid;
   resid = fullresid;
end

% Capture warning messages not handled earlier
if isempty(warnmsg)
    warnmsg = lastwarn;
end

% expand warning message if any nan data
if nandata && isempty(getappdata(double(datahandle),'Basic_Fit_NaN_Warn'))
    % only give these warnings once per data set
    setappdata(double(datahandle),'Basic_Fit_NaN_Warn',1);
    nanerrstr = getString(message('MATLAB:graph2d:bfit:WarningPointsWithNaNCoordsIgnored'));
    if isempty(warnmsg)
        warnmsg = nanerrstr;
    else
        warnmsg = sprintf('%s\n\n%s',warnmsg,nanerrstr);
    end
end

