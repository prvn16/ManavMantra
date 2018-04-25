function success = htmlrenderer(option)
%HTMLRENDERER Specify which HTML renderer to use.
%   This command is unsupported and may change at any time in the future.
 
%   Copyright 1984-2013 The MathWorks, Inc.

success = 1;
if strcmp(option, 'basic')
    com.mathworks.mlwidgets.html.HtmlComponentFactory.setDefaultType('HTMLRENDERER');
elseif strcmp(option, 'chromium')
    com.mathworks.mlwidgets.html.HtmlComponentFactory.setDefaultType('CHROMIUM');    
elseif strcmp(option, 'mozilla')
    if ismac
        com.mathworks.mlwidgets.html.HtmlComponentFactory.setDefaultType('HTMLPANEL');
        com.mathworks.mlwidgets.html.HtmlComponentFactory.setBrowserProperty('JxBrowser.BrowserType','Mozilla15'); 
    elseif strcmp(computer, 'PCWIN')
        % On win32, use JxBrowser3, which uses Mozilla.
        com.mathworks.mlwidgets.html.HtmlComponentFactory.setDefaultType('HTMLPANEL');
    else
        disp('This option is only available on the Mac or 32-bit Windows.');
        success = 0;
        return;
    end
elseif strcmp(option, 'ie')
    if strcmp(computer, 'PCWIN64')
        % On win64, use JxBrowser3, which uses IE.
        com.mathworks.mlwidgets.html.HtmlComponentFactory.setDefaultType('HTMLPANEL');
    else
        disp('This option is only available on 64-bit Windows.');
        success = 0;
        return;
    end
elseif strcmp(option, 'safari')
    if ismac
        com.mathworks.mlwidgets.html.HtmlComponentFactory.setDefaultType('HTMLPANEL');
        com.mathworks.mlwidgets.html.HtmlComponentFactory.setBrowserProperty('JxBrowser.BrowserType','Safari'); 
    else
        disp('This option is only available on the Mac.');
        success = 0;
        return;
    end
elseif strcmp(option, 'default')
    com.mathworks.mlwidgets.html.HtmlComponentFactory.setDefaultType(' ');
    if ismac
       com.mathworks.mlwidgets.html.HtmlComponentFactory.setBrowserProperty('JxBrowser.BrowserType','Safari');       
    end
else
    fprintf('Option ''%s'' not recognized.\n', option);
    success = 0;
    return;
end

fprintf('Your HTML rendering engine is now set to ''%s''.\n', option);
