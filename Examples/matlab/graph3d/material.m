function varargout=material(varargin)
%MATERIAL Material reflectance mode.
%   MATERIAL controls the surface reflectance properties of SURFACE and
%   PATCH objects in the current axes.  SURFACE and PATCH objects are
%   created by the functions SURF, MESH, PCOLOR, FILL, and FILL3.
%
%   MATERIAL SHINY makes the objects shiny.
%   MATERIAL DULL makes the objects dull.
%   MATERIAL METAL makes the objects metallic.
%
%   MATERIAL([ka kd ks]) sets the ambient/diffuse/specular strength
%   of the objects.
%
%   MATERIAL([ka kd ks n]) sets the ambient/diffuse/specular strength
%   and specular exponent of the objects.
%
%   MATERIAL([ka kd ks n sc]) sets the ambient/diffuse/specular strength,
%   specular exponent and specular color reflectance of the objects.
%
%   MATERIAL DEFAULT sets the ambient/diffuse/specular strength,
%   specular exponent and specular color reflectance of the objects
%   to their defaults.
%
%   MATERIAL(H,...) operates on the surface and patch objects specified in
%   vector H. If you include other types of graphics objects in H, then
%   material operates on any surface or patch objects that are descendants
%   of the specified objects.
%
%   See also LIGHT, LIGHTING

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

numArgin =length(varargin);

if nargout==1
    if numArgin>0 && matlab.graphics.internal.isCharOrString(varargin{1})
        [ka,kd,ks,n,sc]=getMaterialValues(varargin{1});
        varargout{1}={ka,kd,ks,n,sc};
    elseif numArgin==0
        varargout{1}=getMaterialNames;
    else
        error(message('MATLAB:material:IncorrectCall'));
    end
elseif nargout==0
    if numArgin==0
        error(message('MATLAB:material:TooFewInputs'));
    elseif numArgin==1
        processProperties(findMaterialObjects(gca),varargin{1});
    elseif numArgin==2
        processProperties(findMaterialObjects(varargin{1}),varargin{2});
    else
        error(message('MATLAB:material:TooManyInputs'));
    end
else
    error(message('MATLAB:material:TooManyOutputs'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function processProperties(h,matspec)

if matlab.graphics.internal.isCharOrString(matspec)
    [ka,kd,ks,n,sc]=getMaterialValues(matspec);
    setProperties(h,ka,kd,ks,n,sc);
elseif isa(matspec, 'double')
    if ~isMaterialVectorOk(matspec)
        error(message('MATLAB:material:InvalidVectorSize'));
    else
        matCell=num2cell(matspec);
        setProperties(h,matCell{:});
    end
else %if not a string or vector
    error(message('MATLAB:material:InvalidMaterialsName'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setProperties(h,varargin)

propNames={
    'AmbientStrength'
    'DiffuseStrength'
    'SpecularStrength'
    'SpecularExponent'
    'SpecularColorReflectance'
    };

pvPairs=[propNames(1:length(varargin)),varargin(:)]';

set(h,pvPairs{:});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ok=isMaterialVectorOk(matVec)

sz = size(matVec);
ok=(length(sz) == 2  & ...
    min(sz)    == 1  & ...
    max(sz)    >= 3  & ...
    max(sz)    <= 5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function objHandles=findMaterialObjects(h)

objHandles = [findobj(h,'type','surface'); findobj(h,'type','patch'); ...
    findobj(h,'type','functionsurface'), findobj(h,'type','parameterizedfunctionsurface'), ...
    findobj(h,'type','implicitfunctionsurface')];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function matNames=getMaterialNames

allMats = getMaterialList;
matNames = allMats(:,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function allMaterials=getMaterialList

allMaterials={  %ka     %kd     %ks     %n      %sc
    'Shiny',	0.3,	0.6,	0.9,	20,		1.0
    'Dull',		0.3,	0.8,	0.0,	10,		1.0
    'Metal',	0.3,	0.3,	1.0,	25,		.5
    'Default',	'default','default','default','default','default'
    };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ka,kd,ks,n,sc]=getMaterialValues(matName)

allMats = getMaterialList;

matRow=find(strcmpi(allMats(:,1),matName));

if isempty(matRow)
    error(message('MATLAB:material:FileNotFound'))
else
    ka= allMats{matRow,2};
    kd= allMats{matRow,3};
    ks= allMats{matRow,4};
    n = allMats{matRow,5};
    sc= allMats{matRow,6};
end
