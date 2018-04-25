function [X,Y,errmsg] = bfitevalfit(expression,datahandle,fit)
% BFITEVALFIT evaluates a fit.

%   Copyright 1984-2008 The MathWorks, Inc. 

X = []; 
Y = []; 
errmsg = '';

try
    % make into array in case a list of numbers
    X = evalin('base',['[' expression ']']);
catch err
    errmsg = getString(message('MATLAB:graph2d:bfit:ErrorEvaluateInBaseWorkspaceFailed',...
         err.message));
    bfitcascadeerr(errmsg, getString(message('MATLAB:graph2d:bfit:TitleBasicFitting')));
    return
end

if ~isa(X, 'double')
    X=[];  % reset so that closing, then reopening does not error.
	errmsg = getString(message('MATLAB:graph2d:bfit:ErrorMustEvaluateToReal'));
    bfitcascadeerr(errmsg, getString(message('MATLAB:graph2d:bfit:TitleBasicFitting')));
    return
end

if ~isreal(X)
    warnmsg = getString(message('MATLAB:graph2d:bfit:WarningImaginaryPartIgnored'));
    warndlg(warnmsg,getString(message('MATLAB:graph2d:bfit:TitleBasicFitting')));
    lastwarn(warnmsg);
    X = real(X);
end
dh = double(datahandle);
if ~ishghandle(dh)
	errmsg = getString(message('MATLAB:graph2d:bfit:ErrorEvaluatingCausedFitToBeDeleted'));
    bfitcascadeerr(errmsg, getString(message('MATLAB:graph2d:bfit:TitleBasicFitting')));
    return

end
coeffcell = getappdata(dh,'Basic_Fit_Coeff'); % cell array of pp structures
pp = coeffcell{fit+1};

if isempty(pp)
    error(message('MATLAB:bfitevalfit:NoFit'))
end

X = X(:);
% Calculate with "newX" but return with "X": (what we plot, etc with)
guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
normalized = getappdata(double(datahandle),'Basic_Fit_Normalizers');
if guistate.normalize
    newX  = (X - normalized(1))./(normalized(2));
else
    newX = X;
end
switch fit
case {0,1} % spline or pchip
    Y = ppval(pp,newX);
otherwise
    Y = polyval(pp,newX);
end
Y = Y(:);

