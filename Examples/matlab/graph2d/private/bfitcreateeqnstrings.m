function s = bfitcreateeqnstrings(datahandle,fit,pp,resid)
% BFITCREATEEQNSTRINGS Create result strings Basic Fitting GUI.

%   Copyright 1984-2017 The MathWorks, Inc.

guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
if isequal(guistate.normalize,true)
	normalizedState = true;
	normalized = getappdata(double(datahandle),'Basic_Fit_Normalizers');
    switch fit
        case {0,1}
            normstring = getString(message('MATLAB:graph2d:bfit:MsgCenteredAndScaledVariable', ...
                sprintf('%0.5g',normalized(1)), sprintf('%0.5g',normalized(2))));
        otherwise
            normstring = getString(message('MATLAB:graph2d:bfit:MsgZIsCenteredAndScaled', ...
                sprintf('%0.5g',normalized(1)), sprintf('%0.5g',normalized(2))));
    end
else
    normstring = '';
    normalizedState = false;
end

switch fit
case {0,1}
    s = getString(message('MATLAB:graph2d:bfit:MsgNormOfResidualsEqual0', eqnstring(fit, normalizedState), normstring));
otherwise
    s = sprintf('%s%s',eqnstring(fit, normalizedState),normstring);
   
    s = getString(message('MATLAB:graph2d:bfit:MsgCoefficients',s));
    for i=1:length(pp)
    	s=[s sprintf('  p%g = %0.5g\n',i,pp(i))];
    end
    
    s = sprintf(getString(message('MATLAB:graph2d:bfit:MsgNormOfResiduals',s)));
    s = [s '     ' num2str(resid,5) sprintf(newline)];

end

%-------------------------------

function s = eqnstring(fitnum, normalizedState)

if isequal(fitnum,0)
    s = getString(message('MATLAB:graph2d:bfit:DisplaySplineInterpolant'));
elseif isequal(fitnum,1)
    s = getString(message('MATLAB:graph2d:bfit:DisplayShapePreservingInterpolant'));
else
    if normalizedState
        xz = 'z';
    else
        xz = 'x';
    end
    fit = fitnum - 1;
    s = sprintf('y =');
    for i = 1:fit
        if i == fit
            s = sprintf('%s p%s*%s +',s,num2str(i), xz);
        else
            s = sprintf('%s p%s*%s^%s +',s,num2str(i),xz,num2str(fit+1-i));
        end
        if isequal(mod(i,2),0)
            s = sprintf('%s\n     ',s);
        end
    end
    s = sprintf('%s p%s ',s,num2str(fit+1));
end

    
