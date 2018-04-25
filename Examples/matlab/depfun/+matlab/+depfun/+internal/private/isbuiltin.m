function tf = isbuiltin(fcn)
% ISBUILTIN Is the function a MATLAB built-in?
import matlab.depfun.internal.cacheWhich;
import matlab.depfun.internal.requirementsConstants;

    tf = false(1,numel(fcn));
    for k=1:numel(fcn)
        pth = fcn{k};
        % Look for the string 'built-in' in the full path (returned by WHICH);
        % but call which last, since it's expensive.
        tf(k) = ~isempty(strfind(pth, requirementsConstants.BuiltInStr));
        if tf(k) == false
            tf(k) = ~isempty(strfind(cacheWhich(pth), requirementsConstants.BuiltInStr));
        end
    end
