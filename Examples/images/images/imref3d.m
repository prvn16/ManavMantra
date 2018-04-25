%imref3d Reference 3-D image to world coordinates
%
%   An imref3d object encapsulates the relationship between the "intrinsic
%   coordinates" anchored to the columns, rows, and planes of a 3-D image and the
%   spatial location of the same column, row, and plane locations in a world
%   coordinate system. The image is sampled regularly in the planar "world
%   X", "world Y", and "world Z" coordinates of the coordinate system such that the
%   "intrinsic" and "world" axes align. The pixel spacing in each dimension
%   may be different.
%
%   The intrinsic coordinate values (x,y,z) of the center point of any
%   pixel are identical to the values of the column, row, and plane
%   subscripts for that pixel. For example, the center point of the pixel
%   in row 5, column 3, plane 4 has intrinsic coordinates x = 3.0, y = 5.0,
%   z = 4.0. Be aware, however, that the order of the XY coordinate
%   specification (3.0,5.0,4.0) is reversed in intrinsic coordinates
%   relative to pixel subscripts (5,3,4). Intrinsic coordinates are defined
%   on a continuous plane while the subscript locations are discrete
%   locations with integer values.
%
%   imref3d properties:
%      XWorldLimits - Limits of image in world X [xMin xMax]
%      YWorldLimits - Limits of image in world Y [yMin yMax]
%      ZWorldLimits - Limits of image in world Z [zMin zMax]
%      ImageSize - Image size in each spatial dimension
%
%   imref3d properties (SetAccess = private):
%      PixelExtentInWorldX - Spacing along rows in world units
%      PixelExtentInWorldY - Spacing along columns in world units
%      PixelExtentInWorldZ - Spacing across planes in world units
%      ImageExtentInWorldX - Full image extent in X dimension
%      ImageExtentInWorldY - Full image extent in Y dimension
%      ImageExtentInWorldZ - Full image extent in Z dimension
%      XIntrinsicLimits - Limits of image in intrinsic X [xMin xMax]
%      YIntrinsicLimits - Limits of image in intrinsic Y [yMin yMax]
%      ZIntrinsicLimits - Limits of image in intrinsic Z [zMin zMax]
%
%   imref3d methods:
%      imref3d - Construct imref3d object
%      sizesMatch - True if object and image are size-compatible
%      intrinsicToWorld - Convert from intrinsic to world coordinates
%      worldToIntrinsic - Convert from world to intrinsic coordinates
%      worldToSubscript - World coordinates to row and column subscripts
%      contains - True if image contains points in world coordinate system
%
%   Example 1
%   ---------
%   % Construct an imref3d object given a knowledge of resolution in each
%   % dimension and image size.
%   m = analyze75info('brainMRI.hdr');
%   A = analyze75read(m);
%   % The PixelDimensions field of the metadata of the file specifies the
%   % resolution in each dimension in millimeters/pixel. Use this information
%   % to construct a spatial referencing object associated with the image
%   % data A.
%   RA = imref3d(size(A),m.PixelDimensions(2),m.PixelDimensions(1),m.PixelDimensions(3));
%   % Examine the extent of the image in each dimension in millimeters.
%   RA.ImageExtentInWorldX
%   RA.ImageExtentInWorldY
%   RA.ImageExtentInWorldZ
%
%   See also imref2d, imwarp

% Copyright 2012-2015 The MathWorks, Inc.


classdef imref3d < imref2d & matlab.mixin.CustomDisplay
    
    
    %------------------- Properties: Public + visible --------------------
    
    properties (Dependent = true)
                
        %ZWorldLimits - Limits of image in world Z [yMin yMax]
        %
        %    ZWorldLimits is a two-element row vector.
        ZWorldLimits
                        
    end
    
    properties(SetAccess = private, Dependent = true)
                
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
    
    properties ( SetAccess = private, Hidden = true)
        
        %FirstCornerZ - World Z coordinate of the first corner of the image
        %
        %   R.FirstCornerZ returns the world Z coordinate of the
        %   outermost corner of the first pixel of the image
        %   associated with referencing object R. This world Z location
        %   corresponds to the intrinsic Z location 0.5.
        FirstCornerZ
        
    end
    
          
    %-------------- Constructor and ordinary methods -------------------
    
    methods
                    
               
        function self = imref3d(imageSize,varargin)
            
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
            validSyntaxThatSpecifiesImageSize = (nargin == 1) || (nargin==4);
            if validSyntaxThatSpecifiesImageSize
                validateattributes(imageSize, ...
                    {'uint8','uint16','uint32','int8','int16','int32','single','double'},...
                    {'positive','real','vector','integer','finite','size',[1 3]}, ...
                    'imref3d', ...
                    'ImageSize');
                
                imageSize = double(imageSize);

            end
            
            if (nargin == 0)
                %imref3d()
                
                self.Dimension.X = images.spatialref.internal.SpatialDimensionManager('X');
                self.Dimension.Y = images.spatialref.internal.SpatialDimensionManager('Y');
                self.Dimension.Z = images.spatialref.internal.SpatialDimensionManager('Z');
                
            elseif (nargin ==1)
                %imref3d(imageSize)
                self.Dimension.X = images.spatialref.internal.SpatialDimensionManager('X',imageSize(2),1,0.5);
                self.Dimension.Y = images.spatialref.internal.SpatialDimensionManager('Y',imageSize(1),1,0.5);
                self.Dimension.Z = images.spatialref.internal.SpatialDimensionManager('Z',imageSize(3),1,0.5);
                
            else
                
                narginchk(4,4);
                
                if isscalar(varargin{1})
                    % imref3d(imageSize,pixelExtentInWorldX,pixelExtentInWorldY,pixelExtentInWorldZ)
                    pixelExtentInWorldX = varargin{1};
                    pixelExtentInWorldY = varargin{2};
                    pixelExtentInWorldZ = varargin{3};
                    self.Dimension.X = images.spatialref.internal.SpatialDimensionManager('X',imageSize(2),pixelExtentInWorldX,pixelExtentInWorldX/2);
                    self.Dimension.Y = images.spatialref.internal.SpatialDimensionManager('Y',imageSize(1),pixelExtentInWorldY,pixelExtentInWorldY/2);
                    self.Dimension.Z = images.spatialref.internal.SpatialDimensionManager('Z',imageSize(3),pixelExtentInWorldZ,pixelExtentInWorldZ/2);

                else
                    % imref3d(imageSize,xWorldLimits,yWorldLimits,zWorldLimits)
                    self.Dimension.X = images.spatialref.internal.SpatialDimensionManager('X',imageSize(2),1,0.5);
                    self.Dimension.Y = images.spatialref.internal.SpatialDimensionManager('Y',imageSize(1),1,0.5);
                    self.Dimension.Z = images.spatialref.internal.SpatialDimensionManager('Z',imageSize(3),1,0.5);
                    self.XWorldLimits = varargin{1};
                    self.YWorldLimits = varargin{2};
                    self.ZWorldLimits = varargin{3};

                end
                                
            end
            
        end
        
        
        function [xw,yw,zw] = intrinsicToWorld(self,xIntrinsic,yIntrinsic,zIntrinsic)
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
            
            validateXYZPoints(xIntrinsic,yIntrinsic,zIntrinsic,...
                              'xIntrinsic','yIntrinsic','zIntrinsic');
            
            xw = self.Dimension.X.intrinsicToWorld(xIntrinsic);
            yw = self.Dimension.Y.intrinsicToWorld(yIntrinsic);
            zw = self.Dimension.Z.intrinsicToWorld(zIntrinsic);

        end
        
        function [xi,yi,zi] = worldToIntrinsic(self,xWorld,yWorld,zWorld)
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
            
            validateXYZPoints(xWorld,yWorld,zWorld,...
                'xWorld','yWorld','zWorld');
            
            xi = self.Dimension.X.worldToIntrinsic(xWorld);
            yi = self.Dimension.Y.worldToIntrinsic(yWorld);
            zi = self.Dimension.Z.worldToIntrinsic(zWorld);
        end
        
        function [r,c,p] = worldToSubscript(self,xWorld,yWorld,zWorld)
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
            
            validateXYZPoints(xWorld,yWorld,zWorld,...
                'xWorld','yWorld','zWorld');
            
            r = self.Dimension.Y.worldToSubscript(yWorld);
            c = self.Dimension.X.worldToSubscript(xWorld);
            p = self.Dimension.Z.worldToSubscript(zWorld);
            
            nan_r = isnan(r);
            nan_c = isnan(c);
            nan_p = isnan(p);
            
            % Any [r,c,p] where a row,col, or plane is nan needs to be nan as a
            % coordinate triplet.
            c(nan_r | nan_p) = NaN;
            r(nan_c | nan_p) = NaN;
            p(nan_r | nan_c) = NaN;
        end
        
        function TF = contains(self,xWorld,yWorld,zWorld)
            %contains True if image contains points in world coordinate system
            %
            %   TF = contains(R,xWorld, yWorld, zWorld) returns a logical array TF
            %   having the same size as xWorld, yWorld, and zWorld such that TF(k) is
            %   true if and only if the point (xWorld(k), yWorld(k), zWorld(k)) falls
            %   within the bounds of the image associated with
            %   referencing object R.
            
            validateXYZPoints(xWorld,yWorld,zWorld,...
                'xWorld','yWorld','zWorld');
            
            TF = self.Dimension.X.contains(xWorld)... 
               & self.Dimension.Y.contains(yWorld)...
               & self.Dimension.Z.contains(zWorld);
        end
        
        function TF = sizesMatch(self,I)
            %sizesMatch True if object and image are size-compatible
            %
            %   TF = sizesMatch(R,A) returns true if the size of the image A is consistent with the ImageSize property of
            %   the referencing object R. That is,
            %
            %   R.ImageSize == [size(A,1) size(A,2) size(A,3)].
            imageSize = size(I);
            if ~isequal(size(self.ImageSize), size(imageSize))
                error(message('images:imref:sizeMismatch','ImageSize','imref3d'));
            end
            TF = isequal(imageSize(1),self.Dimension.Y.NumberOfSamples)...
              && isequal(imageSize(2),self.Dimension.X.NumberOfSamples)...
              && isequal(imageSize(3),self.Dimension.Z.NumberOfSamples);
        end
        
    end

    %----------------- Get methods ------------------
    methods
      
        function depth = get.ImageExtentInWorldZ(self)
            depth = self.Dimension.Z.ExtentInWorld;
        end
                
       
        function extentZ = get.PixelExtentInWorldZ(self)
            extentZ = abs(self.Dimension.Z.Delta);
        end
                        
        function limits = get.ZIntrinsicLimits(self)
            limits = self.Dimension.Z.IntrinsicLimits;
        end
                
        function limits = get.ZWorldLimits(self)
            limits = self.Dimension.Z.WorldLimits;
        end
        
        
        function zedge = get.FirstCornerZ(self)
            zedge = self.Dimension.Z.StartCoordinateInWorld;
        end
        
                
    end
    
    %----------------- Set methods ------------------
    methods
        
        
        function self = set.ZWorldLimits(self, zLimWorld)
            self.Dimension.Z.WorldLimits = zLimWorld;
        end
                
    end
    
    methods (Access = protected)

        function basicDisplay(self)

            fprintf('%s\n',getHeader(self));

            orderedPropNames = {'XWorldLimits',...
                'YWorldLimits',...
                'ZWorldLimits',...
                'ImageSize',...
                'PixelExtentInWorldX',...
                'PixelExtentInWorldY',...
                'PixelExtentInWorldZ',...
                'ImageExtentInWorldX',...
                'ImageExtentInWorldY',...
                'ImageExtentInWorldZ',...
                'XIntrinsicLimits',...
                'YIntrinsicLimits',...
                'ZIntrinsicLimits'};

            groups = matlab.mixin.util.PropertyGroup(orderedPropNames);
            matlab.mixin.CustomDisplay.displayPropertyGroups(self, groups);

        end


        function displayEmptyObject(self)

            self.basicDisplay();

        end

        function displayNonScalarObject(self)

            self.basicDisplay();

        end
        
        function displayScalarObject(self)
            
            self.basicDisplay
            
        end
        
    end
    
    % saveobj and loadobj are implemented to ensure compatibility across
    % releases even if architecture of spatial referencing classes
    % changes.
    methods (Hidden)
       
        function S = saveobj(self)
            
            S = struct('ImageSize',self.ImageSize,...
                        'XWorldLimits',self.XWorldLimits,...
                        'YWorldLimits',self.YWorldLimits,...
                        'ZWorldLimits',self.ZWorldLimits);
            
        end
        
    end
    
    methods (Static, Hidden)
       
        function self = loadobj(S)
           
            self = imref3d(S.ImageSize,...
                S.XWorldLimits,...
                S.YWorldLimits,...
                S.ZWorldLimits);
            
        end
        
    end
    
    %-----------------------------------------------------------------------
   methods(Access=private, Static)
       function name = matlabCodegenRedirect(~)
         name = 'images.internal.coder.imref3d';
       end
   end

end

function validateXYZPoints(X,Y,Z,xName,yName,zName)

if ~isequal(size(X),size(Y),size(Z))
    error(message('images:spatialref:invalidXYZPoint',xName,yName,zName));
end

end
