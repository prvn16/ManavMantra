function sysObjMap = hdlsysobjs
% hdlsysobjs

% map from System object to HDL implementation

%   Copyright 2011-2012 The MathWorks, Inc.

sysObjMap = containers.Map;

% needed until hdlram is deprecated to new hdl.RAM (ships with MATLAB)
sysObjMap('hdlram') = 'hdldefaults.RamSystem';

% end
