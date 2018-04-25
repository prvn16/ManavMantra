%imref3d Reference 3-D image to world coordinates

% Copyright 2012-2015 The MathWorks, Inc.

%#ok<*EMCA>

classdef imref3d  < imref2d %#codegen
    
    properties
        
        %ZWorldLimits - Limits of image in world Z [yMin yMax]
        %
        %    ZWorldLimits is a two-element row vector.
        ZWorldLimits
        
    end
    
    properties (Dependent = true, SetAccess = private)
        
        %PixelExtentInWorldZ - Pixel extent across planes in world units.
        %
        PixelExtentInWorldZ
        
        %ImageExtentInWorldZ - Full image extent in Z direction
        %
        %   ImageExtentInWorldZ is the extent of the image as measured in
        %   the world system in the Z direction.
        ImageExtentInWorldZ
        
        %ZIntrinsicLimits - Limits of image in intrinsic Z [zMin zMax]
        %
        %    ZIntrinsicLimits is a two-element row vector. For an
        %    M-by-N-by-P image it equals [0.5, P + 0.5].
        ZIntrinsicLimits
        
    end
    
    
    methods
        
        function obj = imref3d(imageSizeIn, varargin)
            %imref3d Construct imref3d object
            %
            %   R = imref3d() constructs an imref3d object with default
            %   property settings.
            %
            %   R = imref3d(imageSize) constructs an imref3d object given an
            %   image size. This syntax constructs a spatial referencing
            %   object for the default case in which the world coordinate
            %   system is co-aligned with the intrinsic coordinate system.
            %
            %   R = imref3d(imageSize,pixelExtentInWorldX,pixelExtentInWorldY,pixelExtentInWorldZ)
            %   constructs an imref3d object given an image size and the
            %   resolution in each dimension defined by the scalars
            %   pixelExtentInWorldX, pixelExtentInWorldY, and
            %   pixelExtentInWorldZ.
            %
            %   R = imref3d(imageSize,xWorldLimits,yWorldLimits,zWorldLimits)
            %   constructs an imref3d object given an image size and the
            %   world limits in each dimension defined by the vectors xWorldLimits,
            %   yWorldLimits and zWorldLimits.
            
            % Validate imageSize separately since this can't be done a
            % dimension at a time by the SpatialDimensionManager.
            
            coder.inline('always');
            coder.internal.prefer_const(imageSizeIn,varargin);
            
            validSyntaxThatSpecifiesImageSize = (nargin == 1) || (nargin==4);
            if validSyntaxThatSpecifiesImageSize
                validateattributes(imageSizeIn, ...
                    {'uint8','uint16','uint32','int8','int16','int32','single','double'},...
                    {'positive','real','vector','integer','finite','size',[1 3]}, ...
                    'imref3d', ...
                    'ImageSize');
                
                imageSize = double(imageSizeIn);
                
            end
            
            if (nargin ==0)
                % imref3d()
                
                obj.ImageSizeAlias = [2 2 2];
                [obj.XWorldLimits,...
                    obj.YWorldLimits,...
                    obj.ZWorldLimits] = deal([0.5 2.5]);
                
                obj.ForcePixelExtentToOne = true;
                
            elseif (nargin == 1)
                % imref3d(imageSize)
                obj.ImageSizeAlias = imageSize;
                obj.XWorldLimits = deal(0.5+[0 imageSize(2)]);
                obj.YWorldLimits = deal(0.5+[0 imageSize(1)]);
                obj.ZWorldLimits = deal(0.5+[0 imageSize(3)]);
                
                obj.ForcePixelExtentToOne = true;
            else
                narginchk(4,4);
                obj.ForcePixelExtentToOne = false;
                if isscalar(varargin{1})
                    % imref3d(imageSize,pixelExtentInWorldX,pixelExtentInWorldY,pixelExtentInWorldZ)
                    
                    pixelExtentInWorldX = varargin{1};
                    pixelExtentInWorldY = varargin{2};
                    pixelExtentInWorldZ = varargin{3};
                    
                    validateattributes(pixelExtentInWorldX, ...
                        {'double','single'}, {'positive','real','scalar','finite'}, ...
                        mfilename, ...
                        'PixelExtentInWorldX');
                    
                    validateattributes(pixelExtentInWorldY, ...
                        {'double','single'}, {'positive','real','scalar','finite'}, ...
                        mfilename, ...
                        'PixelExtentInWorldY');
                    
                    validateattributes(pixelExtentInWorldZ, ...
                        {'double','single'}, {'positive','real','scalar','finite'}, ...
                        mfilename, ...
                        'PixelExtentInWorldZ');
                    
                    obj.ImageSizeAlias = imageSize;
                    obj.XWorldLimits = pixelExtentInWorldX .* [0.5, 0.5+imageSize(2)];
                    obj.YWorldLimits = pixelExtentInWorldY .* [0.5, 0.5+imageSize(1)];
                    obj.ZWorldLimits = pixelExtentInWorldZ .* [0.5, 0.5+imageSize(3)];
                    
                else
                    % imref3d(imageSize,xWorldLimits,yWorldLimits,zWorldLimits)
                    xWorldLimits = varargin{1};
                    yWorldLimits = varargin{2};
                    zWorldLimits = varargin{3};
                    
                    validateattributes(xWorldLimits, ...
                        {'double','single'}, {'real','finite','size',[1 2]}, ...
                        mfilename, ...
                        'xWorldLimits');
                    
                    validateattributes(yWorldLimits, ...
                        {'double','single'}, {'real','finite','size',[1 2]}, ...
                        mfilename, ...
                        'yWorldLimits');
                    
                    validateattributes(zWorldLimits, ...
                        {'double','single'}, {'real','finite','size',[1 2]}, ...
                        mfilename, ...
                        'zWorldLimits');
                    
                    coder.internal.errorIf((xWorldLimits(2) <= xWorldLimits(1)),...
                        'images:spatialref:expectedAscendingLimits',...
                        'xWorldLimits');
                    
                    coder.internal.errorIf((yWorldLimits(2) <= yWorldLimits(1)),...
                        'images:spatialref:expectedAscendingLimits',...
                        'yWorldLimits');
                    
                    coder.internal.errorIf((zWorldLimits(2) <= zWorldLimits(1)),...
                        'images:spatialref:expectedAscendingLimits',...
                        'zWorldLimits');
                    
                    obj.ImageSizeAlias = imageSize;
                    obj.XWorldLimits = xWorldLimits;
                    obj.YWorldLimits = yWorldLimits;
                    obj.ZWorldLimits = zWorldLimits;
                    
                end
                
                
            end
            
        end
        
        
        function [xw,yw,zw] = intrinsicToWorld(obj,xIntrinsic,yIntrinsic,zIntrinsic)
            %intrinsicToWorld Convert from intrinsic to world
            %coordinates
            %
            %   [xWorld, yWorld, zWorld] = intrinsicToWorld(R,...
            %   xIntrinsic,yIntrinsic,zIntrinsic) maps point locations from
            %   the intrinsic system (xIntrinsic, yIntrinsic, zIntrinsic)
            %   to the world system (xWorld, yWorld, zWorld) based on the
            %   relationship defined by the referencing object R. The input
            %   may include values that fall completely outside limits of
            %   the image in the intrinsic system. In this case world X, Y,
            %   and Z are extrapolated outside the bounds of the image in
            %   the world system.
            
            coder.inline('always');
            coder.internal.prefer_const(obj,xIntrinsic,yIntrinsic,zIntrinsic);
            
            validateXYZPoints(xIntrinsic,yIntrinsic,zIntrinsic,'xIntrinsic','yIntrinsic','zIntrinsic','intrinsicToWorld');
            
            xw = obj.XWorldLimits(1) + (xIntrinsic-0.5).*obj.PixelExtentInWorldX;
            yw = obj.YWorldLimits(1) + (yIntrinsic-0.5).*obj.PixelExtentInWorldY;
            zw = obj.ZWorldLimits(1) + (zIntrinsic-0.5).*obj.PixelExtentInWorldZ;
            
        end
        
        function [xi,yi,zi] = worldToIntrinsic(obj,xWorld,yWorld,zWorld)
            %worldToIntrinsic Convert from world to intrinsic coordinates
            %
            %   [xIntrinsic, yIntrinsic, zIntrinsic] = worldToIntrinsic(R,...
            %   xWorld, yWorld, zWorld) maps point locations from the world
            %   system (xWorld, yWorld, zWorld) to the intrinsic system
            %   (xIntrinsic, yIntrinsic, zIntrinsic) based on the
            %   relationship defined by the referencing object R. The input
            %   may include values that fall completely outside limits of
            %   the image in the world system. In this case world X, Y, and
            %   Z are extrapolated outside the bounds of the image in the
            %   intrinsic system.
            
            coder.inline('always');
            coder.internal.prefer_const(obj,xWorld,yWorld,zWorld);
            
            validateXYZPoints(xWorld,yWorld,zWorld,'xWorld','yWorld', 'zWorld','worldToIntrinsic');
            
            xi = 0.5 + (xWorld-obj.XWorldLimits(1)) / obj.PixelExtentInWorldX;
            yi = 0.5 + (yWorld-obj.YWorldLimits(1)) / obj.PixelExtentInWorldY;
            zi = 0.5 + (zWorld-obj.ZWorldLimits(1)) / obj.PixelExtentInWorldZ;
            
        end
        
        function [r,c,p] = worldToSubscript(obj,xWorld,yWorld,zWorld)
            %worldToSubscript World coordinates to row,column,plane subscripts
            %
            %   [I,J,K] = worldToSubscript(R,xWorld, yWorld, zWorld) maps point
            %   locations from the world system (xWorld,yWorld,zWorld) to
            %   subscript arrays (I,J,K) based on the relationship defined
            %   by the referencing object R. xWorld, yWorld, and
            %   zWorld must have the same size. I, J, and K will have the
            %   same size as xWorld, yWorld, and zWorld. For an M-by-N-by-P
            %   image, 1 <= I <= M, 1 <= J <= N, and 1 <= K <= P except
            %   when a point xWorld(k), yWorld(k), zWorld(k) falls outside
            %   the image, as defined by contains(R,xWorld, yWorld,
            %   zWorld), then I(k), J(k), and K(k) are NaN.
            
            coder.inline('always');
            coder.internal.prefer_const(obj,xWorld,yWorld,zWorld);
            
            validateXYZPoints(xWorld,yWorld,zWorld,'xWorld','yWorld', 'zWorld','worldToSubscript');
            
            containedSubscripts = obj.contains(xWorld,yWorld,zWorld);
            
            r = coder.internal.nan(size(yWorld));
            c = coder.internal.nan(size(xWorld));
            p = coder.internal.nan(size(zWorld));
            
            [cInit, rInit, pInit] =...
                obj.worldToIntrinsic(...
                xWorld(containedSubscripts),...
                yWorld(containedSubscripts),...
                zWorld(containedSubscripts));
            
            cPix = min(round(cInit),obj.ImageSize(2));
            rPix = min(round(rInit),obj.ImageSize(1));
            pPix = min(round(pInit),obj.ImageSize(3));
            
            c(containedSubscripts) = cPix;
            r(containedSubscripts) = rPix;
            p(containedSubscripts) = pPix;
            
        end
        
        function TF = contains(obj,xWorld,yWorld,zWorld)
            %contains True if image contains points in world coordinate system
            %
            %   TF = contains(R,xWorld, yWorld, zWorld) returns a logical array TF
            %   having the same size as xWorld, yWorld, and zWorld such that TF(k) is
            %   true if and only if the point (xWorld(k), yWorld(k), zWorld(k)) falls
            %   within the bounds of the image associated with
            %   referencing object R.
            
            coder.inline('always');
            coder.internal.prefer_const(obj,xWorld,yWorld,zWorld);
            
            validateXYZPoints(xWorld,yWorld,zWorld,'xWorld','yWorld', 'zWorld','contains');
            
            TF = (xWorld >= obj.XWorldLimits(1))...
                & (xWorld <=  obj.XWorldLimits(2))...
                & (yWorld >= obj.YWorldLimits(1))...
                & (yWorld <= obj.YWorldLimits(2))...
                & (zWorld >= obj.ZWorldLimits(1))...
                & (zWorld <= obj.ZWorldLimits(2));
            
            
        end
        
        function TF = sizesMatch(obj,I)
            %sizesMatch True if object and image are size-compatible
            %
            %   TF = sizesMatch(R,A) returns true if the size of the image A is consistent with the ImageSize property of
            %   the referencing object R. That is,
            %
            %   R.ImageSize == [size(A,1) size(A,2) size(A,3)].
            
            coder.inline('always');
            coder.internal.prefer_const(obj,I);
            
            imageSize = size(I);
            coder.internal.errorIf(...
                ~isequal(size(obj.ImageSize), size(imageSize)),...
                'images:imref:sizeMismatch','ImageSize','imref3d');
            TF = isequal(imageSize(1),obj.ImageSize(1))...
                && isequal(imageSize(2),obj.ImageSize(2))...
                && isequal(imageSize(3),obj.ImageSize(3));
            
        end
        
        function disp(~)
            coder.internal.errorIf(true,'images:imref:methodNotSupportedForCodegen','disp');
        end
        
        function display(~)
            coder.internal.errorIf(true,'images:imref:methodNotSupportedForCodegen','display');
        end
        
        function details(~)
            coder.internal.errorIf(true,'images:imref:methodNotSupportedForCodegen','disp');
        end
        
    end
    
    %----------------- Set methods ------------------
    methods
        
        function obj = set.ZWorldLimits(obj, zLimWorld)
            validateattributes(zLimWorld, ...
                {'double','single'}, {'real','finite','size',[1 2]}, ...
                'imref3d.set.ZworldLimits', ...
                'ZWorldLimits');
            
            coder.internal.errorIf(zLimWorld(2) <= zLimWorld(1),...
                'images:spatialref:expectedAscendingLimits',...
                'ZWorldLimits');
            
            zLimWorld = double(zLimWorld);
            obj.ZWorldLimits = zLimWorld;
            
            % If a property is set, make sure dependent properties are
            % calculated.
            obj.ForcePixelExtentToOne = false;
        end
        
    end
    
    %----------------- Get methods ------------------
    methods
        
        function depth = get.ImageExtentInWorldZ(obj)
            depth = diff(obj.ZWorldLimits);
        end
        
        function limits = get.ZWorldLimits(obj)
            limits = obj.ZWorldLimits;
        end
        
        function extentZ = get.PixelExtentInWorldZ(obj)
            if obj.ForcePixelExtentToOne
                extentZ = 1;
            else
                extentZ = obj.ImageExtentInWorldZ / obj.ImageSize(3);
            end
        end
        
        function limits = get.ZIntrinsicLimits(obj)
            limits = 0.5 + [0 obj.ImageSize(3)];
        end
        
    end
    
end

function validateXYZPoints(X,Y,Z,xName,yName,zName, methodName)

coder.inline('always');
coder.internal.prefer_const(X,Y,Z,xName,yName,zName, methodName);

validateattributes(X,{'numeric'},{'real','nonsparse'},methodName);
validateattributes(Y,{'numeric'},{'real','nonsparse'},methodName);
validateattributes(Z,{'numeric'},{'real','nonsparse'},methodName);

eml_invariant(isequal(size(X),size(Y),size(Z)),...
    eml_message('images:spatialref:invalidXYZPoint',xName,yName,zName));

end
