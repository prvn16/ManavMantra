function LaunchHelp(clientData)
% LaunchHelp Callback to launch doc pages for the FPT and the
% single-precision app

% Copyright 2016-2017 The MathWorks, Inc.

switch clientData.topic
    case 'fixedpointtool'
        fpbhelp('fxptdlg');
    case 'fixedpointdesigner' 
        doc fixedpoint;
    case 'fixedpointdemos'
        demo('matlab','Fixed-Point Designer')
    case 'aboutfixedpointdesigner'
        fxptui.aboutslfixpoint
    otherwise
        helpview(fullfile(docroot,'fixedpoint','fixedpoint.map'), clientData.anchor);
end

% LocalWords:  fixedpointtool fixedpointdesigner fixedpointdemos
% LocalWords:  aboutfixedpointdesigner
