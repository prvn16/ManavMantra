function [A,ind,weights,conn] = parseGeodesicInputs(varargin_client,clientName)
%parseGeodesicInputs Parse inputs for geodesic morphology functions. 
% [A,ind,weights,conn] = parseGeodesicInputs(varargin_client,clientName)
% parses the cell array varargin_client passed to the geodesic morphology
% function of name clientName. The outputs of parseGeodesicInputs are in a
% form that can be easily used by the algorithmic core function
% graydistmex.
%
% Outputs:
% A       - ndim array containing input image data.
% ind     - linear indices specifying marker set
% weights - chamfer weights to use for specified distance metric
% conn    - logical array specifying neighborhood connectivity

%   Copyright 2011-2013 The MathWorks, Inc.

nargin_client = length(varargin_client);

% Enforce required attributes of input image, A
A = varargin_client{1};

maskMarkerSetSpecified = islogical(varargin_client{2});

markerCRSyntaxSpecified = (nargin_client > 2) &&...
    isnumeric(varargin_client{2}) && isnumeric(varargin_client{3});

% Determine which syntax was used to specify marker set
if maskMarkerSetSpecified
    % (A,MASK)
    if isequal(size(varargin_client{2}),size(A))
        ind = find(varargin_client{2});
    else
        error(message('images:parseGeodesicInputs:invalidMarkerSetMask'));
    end
    
elseif markerCRSyntaxSpecified
    % (A,C,R)
    
    C = varargin_client{2};
    R = varargin_client{3};
    
    [num_rows,num_cols] = size(A);
    allIntegralValued = all(rem(R,1)==0) && ...
        all(rem(C,1)==0);
    
    allInValidRange = all ( (R >= 1) & (R <= num_rows) ) &&...
        all ( (C >= 1) & (C <= num_cols) );
    
    numElementsIsMatching = isequal(numel(R),numel(C));
    
    if (ndims(A) ~= 2)
        error(message('images:parseGeodesicInputs:invalidDimsForRowColSyntax'));
    end
    
    if ~allIntegralValued
        error(message('images:parseGeodesicInputs:RCSubscriptsNotIntegerValues'));
    end
    
    if ~allInValidRange
        error(message('images:parseGeodesicInputs:RCSubscriptsOutsideRange'));
    end
    
    if ~numElementsIsMatching
        error(message('images:parseGeodesicInputs:RCNumElementsMismatch'));
    end
    
    ind = sub2ind([num_rows,num_cols],R,C);
    
else
    % (A,IND)
    ind = varargin_client{2};
    validInd = isnumeric(ind);
    
    if ~validInd
       error(message('images:parseGeodesicInputs:indicesMustBeNumeric'));
    end
    
    allIntegralValued = all(rem(ind,1)==0);
    allInValidRange   = all( (ind >= 1) & (ind <= numel(A)));
    
    if ~allIntegralValued
        error(message('images:parseGeodesicInputs:linearIndexNotIntegerValues'));
    end
    if ~allInValidRange
        error(message('images:parseGeodesicInputs:linearIndexOutsideRange'));
    end
end
                                
% Convert to 0 based linear index to pass to C++ code
ind = ind-1;

validateMethodFcn = @(method,argPos) validatestring(method,...
    {'chessboard','cityblock','quasi-euclidean'},...
    clientName,'METHOD',argPos);

% Default distance metric is chessboard
method = 'chessboard';
if markerCRSyntaxSpecified
    if (length(varargin_client) == 4)
        method = varargin_client{4};
        method = validateMethodFcn(method,4);
    end
else
    if (length(varargin_client) == 3)
        method = varargin_client{3};
        method = validateMethodFcn(method,3);
    elseif (length(varargin_client) > 3)
        error(message('images:parseGeodesicInputs:TooManyArgsForSyntax'));
    end
end
    
% Get chamfer neighborhood weights based on dimensionality and method
[weights,conn]  = images.internal.computeChamferMask(ndims(A),method);
conn((end+1)/2) = false;
weights(~conn)  = [];

% If A is not double, convert A to a floating point type and cast weights
% to single so that calculation can be done in single.
if ~isa(A,'double')
    A = single(A);
    weights = single(weights);
end
    
