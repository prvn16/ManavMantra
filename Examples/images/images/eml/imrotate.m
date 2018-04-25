function B = imrotate(varargin) %#codegen
%IMROTATE Rotate image.

%   Copyright 2015 The MathWorks, Inc.

%#ok<*EMCA>

[A,ang,method,bbox] = parse_inputs(varargin{:});

if (isempty(A))
    
    B = A; % No rotation needed
    
else
    sizeA = size(A);
    
    if rem(ang,90) == 0
        % Catch and speed up 90 degree rotations
        
        % Determine if angle is +- 90 degrees or 0,180 degrees.
        multiple_of_ninety = mod(floor(ang/90), 4);
        
        switch multiple_of_ninety
            
            case 0
                % 0 rotation;
                B = A;
                
            case {1,3}
                % +- 90 deg rotation
                
                not_square = sizeA(1) ~= sizeA(2);
                
                % Compute output size
                [outSize, v1, v2] = calcOutputSizeAndIndices(sizeA,bbox);
                
                % Calculate output
                if numel(size(A)) == 2
                    % 2-D
                    
                    % B(v{1},v{2},:) = rot90(A(v{1},v{2},:), multiple_of_ninety);
                    if bbox == CROP && not_square
                        B = createInitializedOutputBuffer(outSize,A);
                        B(v1,v2) = rot90(A(v1,v2), multiple_of_ninety);
                    else
                        B = createUnInitializedOutputBuffer(outSize,A); %#ok<NASGU>
                        B = rot90(A, multiple_of_ninety);
                    end
                    
                elseif numel(size(A)) == 3
                    % 3-D
                    
                    % B(v{1},v{2},:) = rot90(A(v{1},v{2},:), multiple_of_ninety);
                    if bbox == CROP && not_square
                        B = createInitializedOutputBuffer(outSize,A);
                        B(v1,v2,1:sizeA(3)) = rot90(A(v1,v2,1:sizeA(3)), multiple_of_ninety);
                    else
                        B = createUnInitializedOutputBuffer(outSize,A); %#ok<NASGU>
                        B = rot90(A, multiple_of_ninety);
                    end
                    
                else
                    % N-D
                    
                    thirdD = prod(sizeA(3:end));
                    A_tmp = reshape(A,[sizeA(1:2) thirdD]);
                    
                    %B(v{1},v{2},:) = rot90(A(v{1},v{2},:), multiple_of_ninety);
                    if bbox == CROP && not_square
                        B_tmp = createInitializedOutputBuffer(outSize,A_tmp);
                        B_tmp(v1,v2,:) = rot90(A_tmp(v1,v2,:), multiple_of_ninety);
                    else
                        B_tmp = createUnInitializedOutputBuffer(outSize,A_tmp); %#ok<NASGU>
                        B_tmp = rot90(A_tmp, multiple_of_ninety);
                    end
                    
                    B = reshape(B_tmp,[outSize(1) outSize(2) sizeA(3:end)]);
                end
                
            case 2
                % 180 rotation
                
                if islogical(A)
                    B = coder.nullcopy(false(sizeA));
                else
                    B = coder.nullcopy(zeros(sizeA, 'like', A));
                end
                
                if numel(size(A)) == 2
                    % 2-D
                    
                    % v1 = sizeA(1):-1:1;
                    % v2 = sizeA(2):-1:1;
                    % B = A(v1,v2);
                    for j = 1:sizeA(2)
                        for i = 1:sizeA(1)
                            B(i,j) = A(coder.internal.indexPlus(coder.internal.indexMinus(sizeA(1),i),1),coder.internal.indexPlus(coder.internal.indexMinus(sizeA(2),j),1));
                        end
                    end
                    
                elseif numel(size(A)) == 3
                    % 3-D
                    
                    % B = A(v1,v2,:);
                    for k = 1:sizeA(3)
                        for j = 1:sizeA(2)
                            for i = 1:sizeA(1)
                                B(i,j,k) = A(coder.internal.indexPlus(coder.internal.indexMinus(sizeA(1),i),1),coder.internal.indexPlus(coder.internal.indexMinus(sizeA(2),j),1),k);
                            end
                        end
                    end
                    
                else
                    % N-D
                    v1 = sizeA(1):-1:1;
                    v2 = sizeA(2):-1:1;
                    
                    i = 1:sizeA(1);
                    j = 1:sizeA(2);
                    
                    B(i,j,:) = A(v1,v2,:);
                end
                
            otherwise
                B = A;
        end
        
    else
        % Perform general rotation
        
        rotMatrix = [cosd(ang) -sind(ang) 0; 
                     sind(ang) cosd(ang)  0; 
                     0          0         1];
        tform = affine2d(rotMatrix);
        RA = imref2d(size(A));
        Rout = images.spatialref.internal.applyGeometricTransformToSpatialRef(RA,tform);
        
        if bbox == CROP
            % Trim Rout, preserve center and resolution.
            Rout.ImageSize = RA.ImageSize;
            xTrans = mean(Rout.XWorldLimits) - mean(RA.XWorldLimits);
            yTrans = mean(Rout.YWorldLimits) - mean(RA.YWorldLimits);
            Rout.XWorldLimits = RA.XWorldLimits+xTrans;
            Rout.YWorldLimits = RA.YWorldLimits+yTrans;
        end
        
        smoothTF = true;
        % imwarp expects string inputs
        if method == NEAREST
            B = imwarp(A,tform,'nearest','OutputView',Rout,'SmoothEdges',smoothTF);
        elseif method == BILINEAR
            B = imwarp(A,tform,'bilinear','OutputView',Rout,'SmoothEdges',smoothTF);
        else % method == BICUBIC
            B = imwarp(A,tform,'bicubic','OutputView',Rout,'SmoothEdges',smoothTF);
        end
    end
end
end

function [outSize, v1, v2] = calcOutputSizeAndIndices(sizeA,bbox)
% Calculate the output size and input index vectors to copy the input array
% to the output array

coder.internal.prefer_const(bbox,sizeA);
coder.inline('always');

sizeA_2D = sizeA(1:2);
not_square = sizeA_2D(1) ~= sizeA_2D(2);
thirdD = prod(sizeA(3:end));

if bbox == CROP && not_square
    % Center rotated image and preserve size
    imbegin = (max(sizeA_2D) == sizeA)*abs(diff(floor(sizeA_2D/2)));
    vec = 1:min(sizeA_2D);
    
    v1 = coder.internal.indexPlus(imbegin(1),vec);
    v2 = coder.internal.indexPlus(imbegin(2),vec);
    
    if numel(sizeA) == 2
        outSize = sizeA_2D;
    elseif numel(sizeA) == 3
        outSize = [sizeA_2D sizeA(3)];
    else
        outSize = [sizeA_2D thirdD];
    end
    
else
    % Don't preserve original size. i.e. bbox = 'loose'
    
    if numel(sizeA) == 2
        outSize = fliplr(sizeA_2D);
    elseif numel(sizeA) == 3
        outSize = [fliplr(sizeA_2D) sizeA(3)];
    else
        outSize = [fliplr(sizeA_2D) thirdD];
    end
    
    % Not used. Assign to zero to ensure that v1 and v2 are defined.
    v1 = coder.internal.indexInt(0);
    v2 = coder.internal.indexInt(0);
end

end

function B = createInitializedOutputBuffer(outSize,A)
% Creates an initialized output buffer of size outSize and datatype of in.

coder.internal.prefer_const(outSize,A);
coder.inline('always');

if islogical(A)
    B = false(outSize);
else
    B = zeros(outSize, 'like', A);
end

end

function B = createUnInitializedOutputBuffer(outSize,A)
% Creates an uninitialized output buffer of size outSize and datatype of in

coder.inline('always');
coder.internal.prefer_const(outSize,A);

if islogical(A)
    B = coder.nullcopy(false(outSize));
else
    B = coder.nullcopy(zeros(outSize, 'like', A));
end

end

function [A,ang,method,bbox] = parse_inputs(varargin)
% Outputs:  A       the input image
%           ang     the angle by which to rotate the input image
%           method  interpolation method (nearest,bilinear,bicubic)
%           bbox    bounding box option 'loose' or 'crop'

% % Defaults:
% method = 'nearest';
% bbox = 'bilinear';

coder.internal.prefer_const(varargin);
coder.inline('always');

narginchk(2,4)

validateattributes(varargin{1},{'numeric','logical'},{},mfilename,'input image',1);

validateattributes(varargin{2},{'numeric'},{'real','scalar'},mfilename,'ANGLE',2);

A = varargin{1};
ang = double(varargin{2}(1));

if nargin <= 2
    firstStringToProcess = 2; %#ok<NASGU>
    
    method = NEAREST;
    bbox = LOOSE;
else
    firstStringToProcess = 3;
    
    [method, bbox] = parseMethodBBox(firstStringToProcess, varargin{:});
end
end

function p = isBBoxStr(str)
% Returns true is str is a valid direction string
% Use strncmpi to allow case-insensitive, partial matches
p = strncmpi(str,'loose',numel(str)) || strncmpi(str,'crop',numel(str));
end

function p = isMethodStr(str)
% Returns true is str is a valid method string
p = strncmpi(str,'nearest',numel(str)) || strncmpi(str,'bilinear',numel(str)) || strncmpi(str, 'bicubic',numel(str));
end

function bbox = stringToBBox(bboxStr)
% Convert bbox string to its corresponding enumeration
% Use strncmpi to allow case-insensitive, partial matches
if strncmpi(bboxStr,'loose',numel(bboxStr))
    bbox = LOOSE;
else % if strncmpi(bboxStr,'crop',numel(dStr))
    bbox = CROP;
end
end

function method = stringToMethod(mStr)
% Convert method string to its corresponding enumeration
% Use strncmpi to allow case-insensitive, partial matches
if strncmpi(mStr,'nearest',numel(mStr))
    method = NEAREST;
elseif strncmpi(mStr,'bilinear',numel(mStr))
    method = BILINEAR;
else % if strncmpi(mStr,'bicubic',numel(mStr))
    method = BICUBIC;
end
end

function [method, bbox] = parseMethodBBox(idx0,varargin)

coder.inline('always');
coder.internal.prefer_const(idx0,varargin);

validStrings = {'nearest','bilinear','bicubic','crop','loose'};

N = numel(varargin);

% Check that all string inputs arguments are constants
for idx = coder.unroll(idx0:N)
    eml_invariant(eml_is_const(varargin{idx}),...
        eml_message('images:imrotate:codegenMethodOrBBoxStringNotConst'),...
        'IfNotConst','Fail');
    validatestring(varargin{idx}, validStrings, 'imrotate', ...
        'METHOD or BBOX', idx);
end

% Set location of next string
idx0p1 = idx0 + 1;

% Parse each input argument to ensure method and bbox are compile-time
% constants. When an argument (method or bbox) is repeated, the last
% occurence is used. e.g. For imrotate(I,40,'crop','loose'), bbox is set to
% 'loose' and method is set to 'nearest'

% Parse Method string
if idx0 <= N && isMethodStr(varargin{idx0})
    if idx0p1 <= N && isMethodStr(varargin{idx0p1})
        % Deal with two method string inputs by honoring the final value
        % e.g. out = imrotate(I,40,'nearest','bicubic') will set the method
        % to 'bicubic'
        method = stringToMethod(varargin{idx0p1});
    else
        method = stringToMethod(varargin{idx0});
    end
elseif idx0p1 <= N && isMethodStr(varargin{idx0p1})
    method = stringToMethod(varargin{idx0p1});
else
    method = NEAREST;
end

% Parse BBox string
if idx0 <= N && isBBoxStr(varargin{idx0})
    if idx0p1 <= N && isBBoxStr(varargin{idx0p1})
        % Deal with two bbox string inputs by honoring the final value
        bbox = stringToBBox(varargin{idx0p1});
    else
        bbox = stringToBBox(varargin{idx0});
    end
elseif idx0p1 <= N && isBBoxStr(varargin{idx0p1})
    bbox = stringToBBox(varargin{idx0p1});
else
    bbox = LOOSE;
end
end

function methodFlag = NEAREST()
coder.inline('always');
methodFlag = int8(1);
end

function methodFlag = BILINEAR()
coder.inline('always');
methodFlag = int8(2);
end

function methodFlag = BICUBIC()
coder.inline('always');
methodFlag = int8(3);
end

function methodFlag = LOOSE()
coder.inline('always');
methodFlag = int8(4);
end

function directionFlag = CROP()
coder.inline('always');
directionFlag = int8(5);
end

