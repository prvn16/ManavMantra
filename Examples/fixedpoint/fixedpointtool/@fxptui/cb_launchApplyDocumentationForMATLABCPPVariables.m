function cb_launchApplyDocumentationForMATLABCPPVariables()
% launch documentation  for MATLAB System object

%   Copyright 2015 The MathWorks, Inc.

map_path = fullfile(docroot, 'fixedpoint','fixedpoint.map');

topic_id = 'MLFB_SysObj_apply';

helpview (map_path, topic_id);