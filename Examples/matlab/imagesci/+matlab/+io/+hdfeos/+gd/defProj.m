function defProj(gridID,projCode,zoneCode,sphereCode,projParm)
%defProj Define grid projection.
%   defProj(GID,PROJCODE,ZONECODE,SPHERECODE,PROJPARM) defines a GCTP
%   projection on the grid specified by GID.  PROJCODE can be one of the 
%   following strings:
%
%       'geo'    - Geographic
%       'utm'    - Universal Transverse Mercator
%       'albers' - Albers Canonical Equal Area
%       'lamcc'  - Lambert Conformal Conic
%       'ps'     - Polar Stereographic
%       'polyc'  - Polyconic
%       'tm'     - Transverse Mercator
%       'lamaz'  - Lambert Azimuthal Equal Area
%       'snsoid' - Sinusoidal
%       'hom'    - Hotine Oblique Mercator
%       'som'    - Space Oblique Mercator
%       'good'   - Interrupted Goode Homolosine
%       'cea'    - Cylindrical Equal Area
%       'bcea'   - Behrmann Cylindrical Equal Area
%       'isinus' - Integerized Sinusoidal
%
%   If PROJCODE is 'geo', then ZONECODE, SPHERECODE, and PROJPARM should be
%   specified as [].  Any other values for these parameters will be
%   ignored.
%
%   ZONECODE is the Universal Transverse Mercator zone code.  It should be 
%   specified as -1 for other projections.  
%
%   SPHERECODE is the name of the GCTP spheroid or the corresponding 
%   numeric code. 
%
%   PROJPARM is a vector of up to 13 elements containing 
%   projection-specific parameters.  For more details about PROJCODE, 
%   ZONECODE, SPHERECODE, and PROJPARM, see Chapter 6 of HDF-EOS 
%   Library Users Guide for the ECS Project, Volume 1: Overview and 
%   Examples.
%
%   This function corresponds to the GDdefproj function in the HDF
%   library C API.
%
%   Example:  Create a UTM grid bounded by 54 E to 60 E longitude and 20 N
%   to 30 N latitude (zone 40).  Divide the grid into 120 bins along the 
%   x-axis and 200 bins along the y-axis.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('myfile.hdf','create');
%       uplft = [210584.50041 3322395.95445];
%       lowrgt = [813931.10959 2214162.53278];
%       gridID = gd.create(gfid,'UTMGrid',120,200,uplft,lowrgt);
%       gd.defProj(gridID,'utm',40,'Clarke 1866',[]);
%       gd.detach(gridID);
%       gd.close(gfid);
%       
%    Example:  Add a polar stereographic projection of the northern
%    hemisphere with true scale at 90 N, 0 longitude below the pole) using
%    the WGS 84 spheroid.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('myfile.hdf','create');
%       gridID = gd.create(gfid,'PolarGrid',100,100,[],[]);
%       projparm = zeros(1,13);
%       projparm(6) = 90000000;
%       gd.defProj(gridID,'ps',[],'WGS 84',projparm);
%       gd.detach(gridID);
%       gd.close(gfid);
%
%    See also gd, gd.projInfo, gd.create, gd.sphereCodeToName.

%   Copyright 2010-2013 The MathWorks, Inc.

if ischar(sphereCode)
    sphereCode = matlab.io.hdfeos.gd.sphereNameToCode(sphereCode);
end

if (~isempty(zoneCode) && (zoneCode ~= -1)) && ~strcmp(projCode,'utm')
    error(message('MATLAB:imagesci:hdfeos:projCodeSpherecodeMisMatch', zoneCode, projCode));
end
    

% Check specific projections.
switch lower(projCode)
    case 'geo'
        if ~isempty(sphereCode) || ~isempty(projParm)
            warning(message('MATLAB:imagesci:hdfeos:unnecessaryGeoParameters'));
            zoneCode = [];
            sphereCode = [];
            projParm = [];
        end

        
    case 'utm'
        
    otherwise
        if isempty(projParm)
            error(message('MATLAB:imagesci:hdfeos:emptyProjectionParameters', projCode));
        end
end
status = hdf('GD','defproj',gridID,projCode,zoneCode,sphereCode,projParm);
hdfeos_gd_error(status,'GDdefproj');
