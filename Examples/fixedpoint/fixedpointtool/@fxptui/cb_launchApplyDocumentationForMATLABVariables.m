function cb_launchApplyDocumentationForMATLABVariables()
% launch documentation 

%   Copyright 2014 The MathWorks, Inc.

map_path = fullfile(docroot, 'fixedpoint','fixedpoint.map');

topic_id = 'MATLABFunctionBlock_Apply';

helpview (map_path, topic_id);


% [EOF]
