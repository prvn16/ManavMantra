function [projCode,zoneCode,sphereName,projParm] = projInfo(gridID) 
%projInfo Return GCTP projection information about grid.
%   [PROJCODE,ZONECODE,SPHERENAME,PROJPARM] = projInfo(gridID) returns
%   the GCTP projection code, zone code, spheroid, and projection
%   parameters for the grid identified by gridID.
%
%   ZONECODE will be -1 if PROJCODE is anything other than 'UTM'.
%
%   This function corresponds to the GDprojinfo function in the HDF-EOS
%   library C API.
%
%   For details about the GCTP projection code, zone code, spheroid code,
%   and projection parameters, please consult the HDF-EOS User's Guide.
%
%   Example:
%       import matlab.io.hdfeos.*
%       fid = gd.open('grid.hdf');
%       gridID = gd.attach(fid,'PolarGrid');
%       [projCode,zoneCode,sphereCode,projParm] = gd.projInfo(gridID);
%       gd.detach(gridID);
%       gd.close(fid);
%
%   See also gd, gd.defProj, gd.sphereNameToCode, gd.sphereCodeToName.

%   Copyright 2010-2013 The MathWorks, Inc.

[projCode,zoneCode,sphereCode,projParm,status] = hdf('GD','projinfo',gridID);
hdfeos_gd_error(status,'GDprofinfo');

sphereName = matlab.io.hdfeos.gd.sphereCodeToName(sphereCode);

% There are really only 13 possible projection parameters.
projParm = projParm(1:13);
