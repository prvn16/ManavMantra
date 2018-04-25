function schema
%SCHEMA Define the GRIDPANEL Class.

%   Copyright 2004-2013 The MathWorks, Inc.

    pkg = findpackage('hdftool');

    superCls = pkg.findclass('eospanel');
    schema.class(pkg,'gridpanel',superCls);

end
