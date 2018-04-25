%%%%%%%
% Copyright: 2016 The MathWorks, Inc.
% This method is used to invoke matlab.internal.addons.Explorer's show
% method from Java.
%%%%%%%
function showExplorer(navigationData)
    try
        matlab.internal.addons.Explorer.getInstance.show(navigationData);
    catch exception
        if (strcmp(exception.identifier, 'cefclient:webwindow:launchProcess'))
            errordlg(getString(message('matlab_addons:errors:errorOpeningExplorerText')), ...
                     getString(message('matlab_addons:errors:errorOpeningAddOnUIDialogTitle')),...
                     'modal');
        end
    end

end