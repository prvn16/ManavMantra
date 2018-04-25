%%%%%%%
% Copyright: 2016 The MathWorks, Inc.
% This method is used to invoke matlab.internal.addons.Manager's show
% method from Java. From java, it requires to feval to call Manager#show
%%%%%%%
function showManager(navigationData)
    try
        matlab.internal.addons.Manager.getInstance.show(navigationData);
    catch exception
        if (strcmp(exception.identifier, 'cefclient:webwindow:launchProcess'))
            errordlg(getString(message('matlab_addons:errors:errorOpeningManagerText')), ...
                     getString(message('matlab_addons:errors:errorOpeningAddOnUIDialogTitle')),...
                     'modal');
        end
    end
end