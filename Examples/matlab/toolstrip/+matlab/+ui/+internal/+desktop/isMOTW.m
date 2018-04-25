function flag = isMOTW()
% isMOTW returns true if MATLAB session is in the MATLAB Online mode

% must store warning status for reset afterwards
status = warning('query');
% must use catch because connector might not be on
try
    flag = strcmp(mls.internal.feature('graphicsAndGuis','status'),'on');
catch
    flag = false;
end
warning(status);
