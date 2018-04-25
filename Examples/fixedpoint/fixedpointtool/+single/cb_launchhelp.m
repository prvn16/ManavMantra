function cb_launchhelp(topic)
% CB_LAUNCHHELP Callback to launch doc pages for the single precision app

% Copyright 2015-2016, The MathWorks, Inc.

switch topic   
  case 'fixedpoint'
    doc fixedpoint;
  case 'converter'
    helpview(fullfile(docroot, 'fixedpoint','fixedpoint.map'),'SinglePrec_app'); 
  case 'gettingstarted' 
    helpview(fullfile(docroot, 'fixedpoint','fixedpoint.map'),'SinglePrec_gettingStarted'); 
end
