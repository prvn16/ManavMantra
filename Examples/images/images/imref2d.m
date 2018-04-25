%imref2d Reference 2-D image to world coordinates
%
%   An imref2d object encapsulates the relationship between the "intrinsic
%   coordinates" anchored to the columns and rows of a 2-D image and the
%   spatial location of the same column and row locations in a world
%   coordinate system. The image is sampled regularly in the planar "world
%   X" and "world Y" coordinates of the coordinate system such that the
%   "intrinsic X" and "world X" axes align and likewise with the "intrinsic
%   Y" and "world Y" axes. The pixel spacing from row to row need not
%   equal the pixel spacing from column to column.
%
%   The intrinsic coordinate values (x,y) of the center point of any pixel
%   are identical to the values of the column and row subscripts for that
%   pixel. For example, the center point of the pixel in row 5, column 3
%   has intrinsic coordinates x = 3.0, y = 5.0. Be aware, however, that the
%   order of coordinate specification (3.0,5.0) is reversed in intrinsic
%   coordinates relative to pixel subscripts (5,3). Intrinsic coordinates
%   are defined on a continuous plane while the subscript locations are
%   discrete locations with integer values.
%
%   imref2d properties:
%      XWorldLimits - Limits of image in world X [xMin xMax]
%      YWorldLimits - Limits of image in world Y [yMin yMax]
%      ImageSize - Image size in each spatial dimension
%
%   imref2d properties (SetAccess = private):
%      PixelExtentInWorldX - Spacing along rows in world units
%      PixelExtentInWorldY - Spacing along columns in world units
%      ImageExtentInWorldX - Full image extent in X dimension
%      ImageExtentInWorldY - Full image extent in Y dimension
%      XIntrinsicLimits - Limits of image in intrinsic X [xMin xMax]
%      YIntrinsicLimits - Limits of image in intrinsic Y [yMin yMax]
%
%   imref2d methods:
%      imref2d - Construct imref2d object
%      sizesMatch - True if object and image are size-compatible
%      intrinsicToWorld - Convert from intrinsic to world coordinates
%      worldToIntrinsic - Convert from world to intrinsic coordinates
%      worldToSubscript - World coordinates to row and column subscripts
%      contains - True if image contains points in world coordinate system
% 
%   Example 1
%   ---------
%   % Construct an imref2d object given a knowledge of world limits and
%   % image size.
%   A = imread('pout.tif');
%   xWorldLimits = [2 5];
%   yWorldLimits = [3 6];
%   RA = imref2d(size(A),xWorldLimits,yWorldLimits);
%   % Display spatially referenced image in imshow
%   figure, imshow(A,RA);
%
%   Example 2
%   ---------
%   % Construct an imref2d object given a knowledge of resolution in each
%   % dimension and image size.
%   m = dicominfo('knee1.dcm');
%   A = dicomread(m);
%   % The PixelSpacing field of the metadata of the file specifies the
%   % resolution in each dimension in millimeters/pixel. Use this information
%   % to construct a spatial referencing object associated with the image
%   % data A.
%   RA = imref2d(size(A),m.PixelSpacing(2),m.PixelSpacing(1));
%   % Examine the extent of the image in each dimension in millimeters.
%   RA.ImageExtentInWorldX
%   RA.ImageExtentInWorldY
%   
%   See also imref3d, IMSHOW, IMWARP

% Copyright 2012-2015 The MathWorks, Inc.

classdef imref2d
    
    %------------------- Properties: Public + visible --------------------
    
    properties (Dependent = true)
        
        %XWorldLimits - Limits of image in world X [xMin xMax]
        %
        %    XWorldLimits is a two-element row vector.
        XWorldLimits
        
        %YWorldLimits - Limits of image in world Y [yMin yMax]
        %
        %    YWorldLimits is a two-element row vector.
        YWorldLimits
        
        %ImageSize Number of elements in each spatial dimension
        %
        %   ImageSize is a vector specifying the size of the image
        %   associated with the referencing object.
        ImageSize
        
    end
    
    properties(Dependent=true,SetAccess = protected)

        %PixelExtentInWorldX - Pixel extent along rows in world units.
        PixelExtentInWorldX
        
        %PixelExtentInWorldY - Pixel extent along columns in world units.
        PixelExtentInWorldY
        
    end
    
    properties(Dependent=true,SetAccess = private)
       
        
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
    
    
    %---------------- Properties: Protected + hidden ---------------------
    properties (Access = protected, Hidden = true)
        
        Dimension
        
    end
    
    properties (SetAccess = private, Hidden = true)
        
        %FirstCornerX - World X coordinate of the first corner of the image
        %
        %   R.FirstCornerX returns the world X coordinate of the
        %   outermost corner of the first pixel of the image
        %   associated with referencing object R. This world X location
        %   corresponds to the intrinsic X location 0.5.
        FirstCornerX
        
        %FirstCornerY - World Y coordinate of the first corner of the image
        %
        %   R.FirstCornerY returns the world Y coordinate of the
        %   outermost corner of the first pixel of the image
        %   associated with referencing object R. This world Y location
        %   corresponds to the intrinsic Y location 0.5.
        FirstCornerY
                
    end
    

    
    %-------------- Constructor and ordinary methods -------------------
    
    methods
                   
                   
        function self = imref2d(imageSize, varargin)
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
            validSyntaxThatSpecifiesImageSize = (nargin == 1) || (nargin == 3);
            if validSyntaxThatSpecifiesImageSize
                validateattributes(imageSize, ...
                {'uint8','uint16','uint32','int8','int16','int32','single','double'},...
                {'positive','real','vector','integer','finite'}, ...
                    'imref2d', ...
                    'ImageSize');
                if isscalar(imageSize)
                    error(message('images:spatialref:invalidImageSize','ImageSize'));
                end
                imageSize = double(imageSize);
            end
                        
            if (nargin ==0)
                % imref2d()
                self.Dimension.X = images.spatialref.internal.SpatialDimensionManager('X');
                self.Dimension.Y = images.spatialref.internal.SpatialDimensionManager('Y');
            elseif (nargin == 1)
                % imref2d(imageSize)
                self.Dimension.X = images.spatialref.internal.SpatialDimensionManager('X',imageSize(2),1,0.5);
                self.Dimension.Y = images.spatialref.internal.SpatialDimensionManager('Y',imageSize(1),1,0.5);
            else
                narginchk(3,3);

                if isscalar(varargin{1})
                    % imref2d(imageSize,pixelExtentInWorldX,pixelExtentInWorldY)
                    pixelExtentInWorldX = varargin{1};
                    pixelExtentInWorldY = varargin{2};
                    self.Dimension.X = images.spatialref.internal.SpatialDimensionManager('X',imageSize(2),pixelExtentInWorldX,pixelExtentInWorldX/2);
                    self.Dimension.Y = images.spatialref.internal.SpatialDimensionManager('Y',imageSize(1),pixelExtentInWorldY,pixelExtentInWorldY/2);
                else
                    % imref2d(imageSize,xWorldLimits,yWorldLimits)
                    self.Dimension.X = images.spatialref.internal.SpatialDimensionManager('X',imageSize(2),1,0.5);
                    self.Dimension.Y = images.spatialref.internal.SpatialDimensionManager('Y',imageSize(1),1,0.5);
                    self.XWorldLimits = varargin{1};
                    self.YWorldLimits = varargin{2};
                end
                
            end
            
        end
        
        
        function [xw,yw] = intrinsicToWorld(self,xIntrinsic,yIntrinsic)
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
            
            validateXYPoints(xIntrinsic,yIntrinsic,'xIntrinsic','yIntrinsic');
            
            xw = self.Dimension.X.intrinsicToWorld(xIntrinsic);
            yw = self.Dimension.Y.intrinsicToWorld(yIntrinsic);
        end
        
        function [xi,yi] = worldToIntrinsic(self,xWorld,yWorld)
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
            
            validateXYPoints(xWorld,yWorld,'xWorld','yWorld');
            
            xi = self.Dimension.X.worldToIntrinsic(xWorld);
            yi = self.Dimension.Y.worldToIntrinsic(yWorld);
        end
        
        function [r,c] = worldToSubscript(self,xWorld,yWorld)
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
            
            validateXYPoints(xWorld,yWorld,'xWorld','yWorld');
            
            r = self.Dimension.Y.worldToSubscript(yWorld);
            c = self.Dimension.X.worldToSubscript(xWorld);
            
            nan_r = isnan(r);
            nan_c = isnan(c);
            
            % Any [r,c] where a row or col is nan needs to be nan as a
            % pair.
            c(nan_r) = NaN;
            r(nan_c) = NaN;
        end
        
        function TF = contains(self,xWorld,yWorld)
            %contains True if image contains points in world coordinate system
            %
            %   TF = contains(R,xWorld, yWorld) returns a logical array TF
            %   having the same size as xWorld, yWorld such that TF(k) is
            %   true if and only if the point (xWorld(k), yWorld(k)) falls
            %   within the bounds of the image associated with
            %   referencing object R.
            
            validateXYPoints(xWorld,yWorld,'xWorld','yWorld');
            
            TF = self.Dimension.X.contains(xWorld) ...
               & self.Dimension.Y.contains(yWorld);
        end
        
        function TF = sizesMatch(self,I)
            %sizesMatch True if object and image are size-compatible
            %
            %   TF = sizesMatch(R,A) returns true if the size of the image A is consistent with the ImageSize property of
            %   the referencing object R. That is,
            %
            %           R.ImageSize == [size(A,1) size(A,2)].
            imageSize = size(I);
            TF = isequal(imageSize(1),self.Dimension.Y.NumberOfSamples)...
              && isequal(imageSize(2),self.Dimension.X.NumberOfSamples);
        end
        
        
    end

    
    %----------------- Get methods ------------------
    methods
                
        function extentX = get.ImageExtentInWorldX(self)
            extentX = self.Dimension.X.ExtentInWorld;
        end
        
        function height = get.ImageExtentInWorldY(self)
            height = self.Dimension.Y.ExtentInWorld;
        end
        
        function limits = get.XWorldLimits(self)
            limits = self.Dimension.X.WorldLimits;
        end
        
        function limits = get.YWorldLimits(self)
            limits = self.Dimension.Y.WorldLimits;  
        end
                
        function extentX = get.PixelExtentInWorldX(self)
            extentX = abs(self.Dimension.X.Delta);
        end
        
        function extentY = get.PixelExtentInWorldY(self)
            extentY = abs(self.Dimension.Y.Delta);
        end
                        
        function xedge = get.FirstCornerX(self)
            xedge = self.Dimension.X.StartCoordinateInWorld;
        end
        
        function xedge = get.FirstCornerY(self)
            xedge = self.Dimension.Y.StartCoordinateInWorld;
        end
        
        function limits = get.XIntrinsicLimits(self)
            limits = self.Dimension.X.IntrinsicLimits;
        end
        
        function limits = get.YIntrinsicLimits(self)
            limits = self.Dimension.Y.IntrinsicLimits;
        end
        
        function imageSize = get.ImageSize(self)
            is3D = isfield(self.Dimension,'Z');
            
            if is3D
                imageSize = [self.Dimension.Y.NumberOfSamples,...
                             self.Dimension.X.NumberOfSamples,...
                             self.Dimension.Z.NumberOfSamples];
            else
                imageSize = [self.Dimension.Y.NumberOfSamples,...
                             self.Dimension.X.NumberOfSamples];
            end
                
        end
                
    end
    
    %----------------- Set methods ------------------
    methods
       
        function self = set.XWorldLimits(self, xLimWorld)
            self.Dimension.X.WorldLimits = xLimWorld;
        end
        
        function self = set.YWorldLimits(self, yLimWorld)
            self.Dimension.Y.WorldLimits = yLimWorld;
        end
               
       function self = set.ImageSize(self,imSize)
           
           validateattributes(imSize, ...
               {'uint8','uint16','uint32','int8','int16','int32','single','double'},...
               {'positive','real','vector','integer','finite'}, ...
               'imref2d.set.ImageSize', ...
               'ImageSize');
           
           if isscalar(imSize)
               error(message('images:spatialref:invalidImageSize','ImageSize'));
           end
           
           imSize = double(imSize);
           
           self.Dimension.X.NumberOfSamples = imSize(2);
           self.Dimension.Y.NumberOfSamples = imSize(1);
          
           is3D = isfield(self.Dimension,'Z');
           if is3D
               if numel(imSize) ~=3
                   error(message('images:spatialref:invalid3dImageSize','ImageSize'));
               end
               self.Dimension.Z.NumberOfSamples = imSize(3);
           end
          
       end
       
    end
    
    % saveobj and loadobj are implemented to ensure compatibility across
    % releases even if architecture of spatial referencing classes
    % changes.
    methods (Hidden)
       
        function S = saveobj(self)
            
            S = struct('ImageSize',self.ImageSize,...
                        'XWorldLimits',self.XWorldLimits,...
                        'YWorldLimits',self.YWorldLimits);
            
        end
        
    end
    
    methods (Static, Hidden)
       
        function self = loadobj(S)
           
            self = imref2d(S.ImageSize,S.XWorldLimits,S.YWorldLimits);
            
        end
        
    end
    
       %-----------------------------------------------------------------------
   methods(Access=private, Static)
       function name = matlabCodegenRedirect(~)
         name = 'images.internal.coder.imref2d';
       end
   end
            
end

function validateXYPoints(X,Y,xName,yName)

if ~isequal(size(X),size(Y))
    error(message('images:spatialref:invalidXYPoint',xName,yName));
end

end
