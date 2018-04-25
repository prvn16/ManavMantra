%imref2d Reference 2-D image to world coordinates

% Copyright 2013-2015 The MathWorks, Inc.

%#ok<*EMCA>

classdef imref2d %#codegen
    
    
    properties (Dependent=true)
        
        %ImageSize Number of elements in each spatial dimension
        %
        %   ImageSize is a vector specifying the size of the image
        %   associated with the referencing object.
        ImageSize
        
    end
    
    properties
        
        %XWorldLimits - Limits of image in world X [xMin xMax]
        %
        %    XWorldLimits is a two-element row vector.
        XWorldLimits
        
        %YWorldLimits - Limits of image in world Y [yMin yMax]
        %
        %    YWorldLimits is a two-element row vector.
        YWorldLimits
        
    end
    
    properties (Dependent=true,SetAccess = protected)
        
        %PixelExtentInWorldX - Pixel extent along rows in world units.
        PixelExtentInWorldX
        
        %PixelExtentInWorldY - Pixel extent along columns in world units.
        PixelExtentInWorldY
        
    end
    
    properties (Dependent=true,SetAccess = private)
        
        %ImageExtentInWorldX - Full image extent in X direction
        %
        %   ImageExtentInWorldX is the extent of the image as measured in
        %   the world system in the X direction.
        ImageExtentInWorldX
        
        %ImageExtentInWorldY - Full image extent in Y direction
        %
        %   ImageExtentInWorldY is the extent of the image as measured in
        %   the world system in the Y direction.
        ImageExtentInWorldY
        
        %XIntrinsicLimits - Limits of image in intrinsic X [xMin xMax]
        %
        %    XIntrinsicLimits is a two-element row vector. For an M-by-N
        %    image (or an M-by-N-by-P image) it equals [0.5, N + 0.5].
        XIntrinsicLimits
        
        %YIntrinsicLimits - Limits of image in intrinsic Y [yMin yMax]
        %
        %    YIntrinsicLimits is a two-element row vector. For an M-by-N
        %    image (or an M-by-N-by-P image) it equals [0.5, M + 0.5].
        YIntrinsicLimits
        
    end
    
    properties (Access = protected)
        
        %ImageSizeAlias Number of elements in each spatial dimension.
        %
        %   ImageSizeAlias is a vector specifying the size of the image
        %   associated with the referencing object. This property is an
        %   alias of the ImageSize dependent property.
        ImageSizeAlias
        
        %ForcePixelExtentToOne
        %
        %   ForcePixelExtentToOne is a logical scalar which specifies that 
        %   the value of pixel extent and bypasses its calculation for 
        %   constructor syntaxes where the pixel extent is 1. By explicitly
        %   setting the resolution, a division operation is avoided which 
        %   helps the upper bound analysis better predict the expected size
        %   of temporary arrays that are dependent on the resolution value. 
        %   The ForcePixelExtentToOne property has to be set to false when 
        %   a set method for any property is called becuase pixel extent is
        %   a dependent property.
        ForcePixelExtentToOne
        
    end
    
    methods
        
        
        function obj = imref2d(imageSizeIn, varargin)
            %imref2d Construct imref2d object
            %
            %   R = imref2d() constructs an imref2d object with default
            %   property settings.
            %
            %   R = imref2d(imageSize) constructs an imref2d object given an
            %   image size. This syntax constructs a spatial referencing
            %   object for the default case in which the world coordinate
            %   system is co-aligned with the intrinsic coordinate system.
            %
            %   R = imref2d(imageSize, pixelExtentInWorldX,pixelExtentInWorldY)
            %   constructs an imref2d object given an image size and the
            %   resolution in each dimension defined by the scalars
            %   pixelExtentInWorldX and pixelExtentInWorldY.
            %
            %   R = imref2d(imageSize, xWorldLimits, yWorldLimits)
            %   constructs an imref2d object given an image size and the
            %   world limits in each dimension defined by the vectors
            %   xWorldLimits and yWorldLimits.
            
            % Validate imageSize separately since this can't be done a
            % dimension at a time by the SpatialDimensionManager.
            
            coder.inline('always');
            coder.internal.prefer_const(imageSizeIn,varargin);
            
            validSyntaxThatSpecifiesImageSize = (nargin == 1) || (nargin == 3);
            if validSyntaxThatSpecifiesImageSize
                validateattributes(imageSizeIn, ...
                    {'uint8','uint16','uint32','int8','int16','int32','single','double'},...
                    {'positive','real','vector','integer','finite'}, ...
                    'imref2d', ...
                    'ImageSize');
                
                eml_invariant(~isscalar(imageSizeIn),...
                    eml_message('images:spatialref:invalidImageSize','ImageSize'),...
                    'IfNotConst','Fail');
                
                imageSize = double(imageSizeIn);
            end
            
            if (nargin ==0)
                % imref2d()
                obj.ImageSizeAlias = [2 2];
                obj.XWorldLimits = [0.5, 2.5];
                obj.YWorldLimits = [0.5, 2.5];
                obj.ForcePixelExtentToOne = true;
                
            elseif (nargin == 1)
                % imref2d(imageSize)
                obj.ImageSizeAlias = [imageSize(1) imageSize(2)];
                obj.XWorldLimits = [0.5, 0.5+imageSize(2)];
                obj.YWorldLimits = [0.5, 0.5+imageSize(1)];
                obj.ForcePixelExtentToOne = true;
                
            else
                narginchk(3,3);
                obj.ForcePixelExtentToOne = false;
                if isscalar(varargin{1})
                    % imref2d(imageSize,pixelExtentInWorldX,pixelExtentInWorldY)
                    
                    pixelExtentInWorldX = varargin{1};
                    pixelExtentInWorldY = varargin{2};
                    
                    validateattributes(pixelExtentInWorldX, ...
                        {'double','single'}, {'positive','real','scalar','finite'}, ...
                        mfilename, ...
                        'PixelExtentInWorldX');
                    
                    validateattributes(pixelExtentInWorldY, ...
                        {'double','single'}, {'positive','real','scalar','finite'}, ...
                        mfilename, ...
                        'PixelExtentInWorldY');
                    
                    obj.ImageSizeAlias = [imageSize(1) imageSize(2)];
                    
                    obj.XWorldLimits = pixelExtentInWorldX .* [0.5, 0.5+imageSize(2)];
                    obj.YWorldLimits = pixelExtentInWorldY .* [0.5, 0.5+imageSize(1)];
                    
                else
                    % imref2d(imageSize,xWorldLimits,yWorldLimits)
                    
                    xWorldLimits = varargin{1};
                    yWorldLimits = varargin{2};
                    
                    validateattributes(xWorldLimits, ...
                        {'double','single'}, {'real','finite','size',[1 2]}, ...
                        mfilename, ...
                        'xWorldLimits');
                    
                    validateattributes(yWorldLimits, ...
                        {'double','single'}, {'real','finite','size',[1 2]}, ...
                        mfilename, ...
                        'yWorldLimits');
                    
                    coder.internal.errorIf((xWorldLimits(2) <= xWorldLimits(1)),...
                        'images:spatialref:expectedAscendingLimits',...
                        'xWorldLimits');
                    
                    coder.internal.errorIf((yWorldLimits(2) <= yWorldLimits(1)),...
                        'images:spatialref:expectedAscendingLimits',...
                        'yWorldLimits');
                    
                    obj.ImageSizeAlias = [imageSize(1) imageSize(2)];
                    obj.XWorldLimits = xWorldLimits;
                    obj.YWorldLimits = yWorldLimits;
                    
                end
                
                
            end
            
        end
        
        function [xw,yw] = intrinsicToWorld(obj,xIntrinsic,yIntrinsic)
            %intrinsicToWorld Convert from intrinsic to world
            %coordinates
            %
            %   [xWorld, yWorld] = intrinsicToWorld(R,...
            %   xIntrinsic,yIntrinsic) maps point locations from the
            %   intrinsic system (xIntrinsic, yIntrinsic) to the world
            %   system (xWorld, yWorld) based on the relationship defined
            %   by the referencing object R. The input may include values
            %   that fall completely outside limits of the image in the
            %   intrinsic system. In this case world X and Y are
            %   extrapolated outside the bounds of the image in the world
            %   system.
            
            coder.inline('always');
            coder.internal.prefer_const(obj,xIntrinsic,yIntrinsic);
            
            validateXYPoints(xIntrinsic,yIntrinsic,'xIntrinsic','yIntrinsic','intrinsicToWorld');
            
            xw = obj.XWorldLimits(1) + (xIntrinsic-0.5).* obj.PixelExtentInWorldX;
            yw = obj.YWorldLimits(1) + (yIntrinsic-0.5).* obj.PixelExtentInWorldY;
            
        end
        
        function [xi,yi] = worldToIntrinsic(obj,xWorld,yWorld)
            %worldToIntrinsic Convert from world to intrinsic coordinates
            %
            %   [xIntrinsic, yIntrinsic] = worldToIntrinsic(R,...
            %   xWorld, yWorld) maps point locations from the
            %   world system (xWorld, yWorld) to the intrinsic
            %   system (xIntrinsic, yIntrinsic) based on the relationship
            %   defined by the referencing object R. The input may
            %   include values that fall completely outside limits of
            %   the image in the world system. In this case world X and Y
            %   are extrapolated outside the bounds of the image in the
            %   intrinsic system.
            
            coder.inline('always');
            coder.internal.prefer_const(obj,xWorld,yWorld);
            
            validateXYPoints(xWorld,yWorld,'xWorld','yWorld','worldToIntrinsic');
            
            xi = 0.5 + (xWorld-obj.XWorldLimits(1)) / obj.PixelExtentInWorldX;
            yi = 0.5 + (yWorld-obj.YWorldLimits(1)) / obj.PixelExtentInWorldY;
            
        end
        
        function [r,c] = worldToSubscript(obj,xWorld,yWorld)
            %worldToSubscript World coordinates to row and column subscripts
            %
            %   [I,J] = worldToSubscript(R,xWorld, yWorld) maps point
            %   locations from the world system (xWorld,yWorld) to
            %   subscript arrays I and J based on the relationship defined
            %   by the referencing object R. I and J are the row and column
            %   subscripts of the image pixels containing each element of a
            %   set of points given their world coordinates (xWorld,
            %   yWorld). xWorld and yWorld must have the same size. I and J
            %   will have the same size as xWorld and yWorld. For an M-by-N
            %   image, 1 <= I <= M and 1 <= J <= N, except when a point
            %   xWorld(k), yWorld(k) falls outside the image, as defined by
            %   contains(R,xWorld, yWorld), then both I(k) and J(k) are
            %   NaN.
            coder.inline('always');
            coder.internal.prefer_const(obj,xWorld,yWorld);
            
            validateXYPoints(xWorld,yWorld,'xWorld','yWorld','worldToSubscript');
            
            containedSubscripts = obj.contains(xWorld,yWorld);
            r = coder.internal.nan(size(yWorld));
            c = coder.internal.nan(size(xWorld));
            [cInit, rInit] =...
                obj.worldToIntrinsic(xWorld(containedSubscripts),yWorld(containedSubscripts));
            
            cPix = min(round(cInit),obj.ImageSize(2));
            rPix = min(round(rInit),obj.ImageSize(1));
            
            c(containedSubscripts) = cPix;
            r(containedSubscripts) = rPix;
            
        end
        
        function TF = contains(obj,xWorld,yWorld)
            %contains True if image contains points in world coordinate system
            %
            %   TF = contains(R,xWorld, yWorld) returns a logical array TF
            %   having the same size as xWorld, yWorld such that TF(k) is
            %   true if and only if the point (xWorld(k), yWorld(k)) falls
            %   within the bounds of the image associated with
            %   referencing object R.
            
            coder.inline('always');
            coder.internal.prefer_const(obj,xWorld,yWorld);
            
            validateXYPoints(xWorld,yWorld,'xWorld','yWorld','contains');
            
            TF = (xWorld >= obj.XWorldLimits(1))...
                & (xWorld <=  obj.XWorldLimits(2))...
                & (yWorld >= obj.YWorldLimits(1))...
                & (yWorld <= obj.YWorldLimits(2));
            
            
        end
        
        function TF = sizesMatch(obj,I)
            %sizesMatch True if object and image are size-compatible
            %
            %   TF = sizesMatch(R,A) returns true if the size of the image A is consistent with the ImageSize property of
            %   the referencing object R. That is,
            %
            %           R.ImageSize == [size(A,1) size(A,2)].
            
            coder.inline('always');
            coder.internal.prefer_const(obj,I);
            
            imageSize = size(I);
            TF = isequal(imageSize(1),obj.ImageSize(1))...
                && isequal(imageSize(2),obj.ImageSize(2));
            
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
        
        function obj = set.XWorldLimits(obj, xLimWorld)
            validateattributes(xLimWorld, ...
                {'double','single'}, {'real','finite','size',[1 2]}, ...
                'imref2d.set.XworldLimits', ...
                'XWorldLimits');
            
            coder.internal.errorIf(xLimWorld(2) <= xLimWorld(1),...
                'images:spatialref:expectedAscendingLimits',...
                'XWorldLimits');
            
            xLimWorld = double(xLimWorld);
            obj.XWorldLimits = xLimWorld;
            
            % If a property is set, make sure dependent properties are
            % calculated. The following line produces a MLint warning which
            % is suppressed because it is safe to set the  property, 
            % ForcePixelExtentToOne. It doesn't have a set method which 
            % avoids a circular reference i.e. properties trying to set 
            % each other.
            obj.ForcePixelExtentToOne = false; %#ok<MCSUP>
        end
        
        function obj = set.YWorldLimits(obj, yLimWorld)
            validateattributes(yLimWorld, ...
                {'double','single'}, {'real','finite','size',[1 2]}, ...
                'imref2d.set.YworldLimits', ...
                'YWorldLimits');
            
            coder.internal.errorIf(yLimWorld(2) <= yLimWorld(1),...
                'images:spatialref:expectedAscendingLimits',...
                'YWorldLimits');
            
            yLimWorld = double(yLimWorld);
            obj.YWorldLimits = yLimWorld;
            
            % If a property is set, make sure dependent properties are
            % calculated. The following line produces a MLint warning which
            % is suppressed because it is safe to set the  property, 
            % ForcePixelExtentToOne. It doesn't have a set method which 
            % avoids a circular reference i.e. properties trying to set 
            % each other.
            obj.ForcePixelExtentToOne = false; %#ok<MCSUP>
        end
        
        function obj = set.ImageSize(obj,imSize)
            if ~isa(obj,'imref3d')
                
                validateattributes(imSize, ...
                    {'uint8','uint16','uint32','int8','int16','int32','single','double'},...
                    {'positive','real','vector','integer','finite'}, ...
                    'imref2d.set.ImageSize', ...
                    'ImageSize');
                
                coder.internal.errorIf(isscalar(imSize),...
                    'images:spatialref:invalidImageSize','ImageSize');
                
                imSize = double(imSize);
                obj.ImageSizeAlias = [imSize(1) imSize(2)];
            else
                validateattributes(imSize, ...
                    {'uint8','uint16','uint32','int8','int16','int32','single','double'},...
                    {'positive','real','vector','integer','finite','size',[1 3]}, ...
                    'imref2d.set.ImageSize', ...
                    'ImageSize');
                
                imSize = double(imSize);
                obj.ImageSizeAlias = [imSize(1) imSize(2) imSize(3)];
            end
            
            % If a property is set, make sure dependent properties are
            % calculated.
            obj.ForcePixelExtentToOne = false;
           
        end
        
    end
    
    
    %----------------- Get methods ------------------
    methods
        
        function extentX = get.ImageExtentInWorldX(obj)
            extentX = diff(obj.XWorldLimits);
        end
        
        function height = get.ImageExtentInWorldY(obj)
            height = diff(obj.YWorldLimits);
        end
        
        function limits = get.XWorldLimits(obj)
            limits = obj.XWorldLimits;
        end
        
        function limits = get.YWorldLimits(obj)
            limits = obj.YWorldLimits;
        end
        
        function extentX = get.PixelExtentInWorldX(obj)
            if obj.ForcePixelExtentToOne
                extentX = 1;
            else
                extentX = obj.ImageExtentInWorldX / obj.ImageSize(2);
            end
       end
        
        function extentY = get.PixelExtentInWorldY(obj)
            if obj.ForcePixelExtentToOne
                extentY = 1;
            else
                extentY = obj.ImageExtentInWorldY / obj.ImageSize(1);
            end
        end
        
        function limits = get.XIntrinsicLimits(obj)
            limits = 0.5 + [0 obj.ImageSize(2)];
        end
        
        function limits = get.YIntrinsicLimits(obj)
            limits = 0.5 + [0 obj.ImageSize(1)];
        end
        
        function imageSize = get.ImageSize(obj)
            imageSize = obj.ImageSizeAlias;
        end
        
    end
    
end


function validateXYPoints(X,Y,xName,yName,methodName)

coder.inline('always');
coder.internal.prefer_const(X,Y,xName,yName,methodName);

validateattributes(X,{'numeric'},{'real','nonsparse'},methodName);
validateattributes(Y,{'numeric'},{'real','nonsparse'},methodName);

eml_invariant(isequal(size(X),size(Y)),...
    eml_message('images:spatialref:invalidXYPoint',xName,yName));

end
