%   FOR INTERNAL USE ONLY -- This class is intentionally
%   undocumented and is intended for use only within other toolbox
%   classes and functions. Its behavior may change, or the feature
%   itself may be removed in a future release.
%
%SpatialDimensionManager Referencing information per image dimension
%
%   A SpatialDimensionManager object encapsulates the spatial referencing
%   information for each spatial dimension. The imref2d and imref3d objects
%   use this object in composition to perform 2D and 3D spatial referencing
%   by using an instance of this object for each spatial dimension.
%
%   SpatialDimensionManager properties:
%      Delta - Floating point representation of delta
%      DeltaNumerator - Numerator of delta represented as a fraction
%      DeltaDenominator - Denominator of delta represented as a fraction
%      ExtentInWorld - Extent of dimension in world units
%      IntrinsicLimits - Intrinsic limits of dimension
%      NumberOfSamples - Number of samples
%      StartCoordinateInWorld - Starting coordinate in the world coordinate system
%      WorldEdgeOfFirstSample - World coordinate of the edge of the first sample
%      WorldLimits - World limits of dimension
%
%   See also imref2d, imref3d

% Copyright 2012 The MathWorks, Inc.

classdef SpatialDimensionManager
    
    properties
        
        NumberOfSamples = 2;
        StartCoordinateInWorld = 0.5;
        DimensionName = '';
  
    end
    
    properties(SetAccess = 'private')
        
        
        DeltaNumerator = 1;
        
        DeltaDenominator = 1;
        
    end
    
    properties(Dependent = true, SetAccess = 'private')
        
        ExtentInWorld
        WorldIncreasesWithIntrinsic

    end
    
    properties (Dependent = true)
        
        IntrinsicLimits
        
        WorldLimits
        
        Delta
                
    end
    
    
    methods
        % get methods for public properties
                
        function TF = get.WorldIncreasesWithIntrinsic(self)
           % set.Delta prevents Delta from being zero, so Delta is either
           % positive or negative.
           TF = self.Delta > 0;
        end
        
        function extent = get.ExtentInWorld(self)
            extent = diff(self.WorldLimits);
        end
        
        function intrinsicLim = get.IntrinsicLimits(self)
            
            intrinsicLim = 0.5 + [0, self.NumberOfSamples];
        end
        
        function worldLim = get.WorldLimits(self)
            
            worldLim = sort(self.StartCoordinateInWorld + [0, self.NumberOfSamples * self.DeltaNumerator / self.DeltaDenominator]);
            
        end
        
        function delta = get.Delta(self)
            
            delta = self.DeltaNumerator/self.DeltaDenominator;
            
        end
        
    end
    
    methods
        % set methods for writable properties
        
        function self = set.DimensionName(self,name)
           
            validstr = validatestring(name,{'X','Y','Z'});
            self.DimensionName = validstr;
                        
        end
        
        function self = set.Delta(self,delta)
            
            % The math throughout SpatialDimensionManager is written to allow Delta
            % to be negative in the case where the Intrinsic and World axes
            % in a given dimension point in opposite directions. We don't
            % want to expose this initially, so we are enforcing that Delta
            % must be negative within SpatialDimensionManager until we want
            % to expose and integrate spatial referencing objects with
            % opposing world and intrinsic axes.
            validateattributes(delta, ...
                {'double','single'}, {'positive','real','scalar','finite'}, ...
                'images.spatialref.internal.SpatialDimensionManager.set.Delta', ...
                sprintf('PixelExtentInWorld%s',self.DimensionName));
                        
            [self.DeltaNumerator,self.DeltaDenominator] = simplifyRatio(double(delta));
               
        end
        
        function self = set.StartCoordinateInWorld(self,start)
            % The context in which you would see this set fail is in the
            % constructors in the clients that specify:
            % imref2d(size,dx,dy,FirstCornerX,FirstCornerY). In these cases,
            % we use the variable names as they are known in the clients.
            validateattributes(start, ...
                {'double','single'}, {'real','scalar','finite'}, ...
                'images.spatialref.internal.SpatialDimensionManager.set.StartCoordinateInWorld', ...
                sprintf('FirstCorner%s',self.DimensionName)); %#ok<MCSUP>
            
            self.StartCoordinateInWorld = double(start);
                                    
        end
        
        function self = set.WorldLimits(self,worldLimits)
            
            validateattributes(worldLimits, ...
                {'double','single'}, {'real','finite','size',[1 2]}, ...
                'images.spatialref.internal.SpatialDimensionManager.set.worldLimits', ...
                sprintf('%sWorldLimits',self.DimensionName));
            
            if (worldLimits(2) <= worldLimits(1))
                error(message('images:spatialref:expectedAscendingLimits',...
                    sprintf('%sWorldLimits',self.DimensionName)));
            end
            
            worldLimits = double(worldLimits);
            if (self.WorldIncreasesWithIntrinsic)
                self.StartCoordinateInWorld = worldLimits(1);
                self.Delta = diff(worldLimits) / self.NumberOfSamples;
            else
                self.StartCoordinateInWorld = worldLimits(2);
                self.Delta = -diff(worldLimits) / self.NumberOfSamples;
            end
            
        end
        
        function self = set.NumberOfSamples(self, numSamples)
            
            % Don't do dimension or type validation here. This
            % responsibility is delegated to set.ImageSize in the clients.
            % It isn't possible to fully validate the size argument in this
            % context since we only know one dimension.
                        
            worldLimitsOld = self.WorldLimits; %#ok<MCSUP>
            self.NumberOfSamples = numSamples;
            
            deltaAsDouble = diff(worldLimitsOld) / numSamples; 
            [self.DeltaNumerator, self.DeltaDenominator] = rat(deltaAsDouble); %#ok<MCSUP>
            
        end
        
    end
    
    methods
        
        % Public methods
        
        function self = SpatialDimensionManager(varargin)
            
            if (nargin == 1)
                %SpatialDimensionManager(DimensionName)
                
                % Corresponds to 2 elements per dimension in the intrinsic
                % system.
                self.DimensionName = varargin{1};

            elseif (nargin == 4)
                %SpatialDimensionManager(DimensionName,NumberOfSamples,Delta,StartCoordinateInWorld)
                self.DimensionName = varargin{1};
                self.NumberOfSamples = varargin{2};
                self.Delta = varargin{3};
                self.StartCoordinateInWorld = varargin{4};
                
            else
                assert(false,...
                    'Invalid construction syntax for images.spatialref.internal.SpatialDimensionManager');
            end
                       
        end
        
        function TF = contains(self,worldCoordinate)
            
            validateattributes(worldCoordinate,{'numeric'},{'real'},'contains');
            
            bounds = self.WorldLimits;
            
            TF = (worldCoordinate >= bounds(1))...
               & (worldCoordinate <= bounds(2));
            
        end
        
        function worldCoordinate = intrinsicToWorld(self,intrinsicCoordinate)
            
            validateattributes(intrinsicCoordinate,{'numeric'},{'real','nonsparse'},'intrinsicToWorld');

            worldCoordinate = self.StartCoordinateInWorld + (intrinsicCoordinate-0.5)*self.DeltaNumerator/self.DeltaDenominator;
            
        end
        
        function subscript = worldToSubscript(self,worldCoordinate)
            
            validateattributes(worldCoordinate,{'numeric'},{'real','nonsparse'},'worldToSubscript');

            containedSubscripts = self.contains(worldCoordinate);
            subscript = nan(size(worldCoordinate));
            % Use round to map the intrinsic coordinate to the nearest
            % integral value. The outer min computation ensures that the
            % edge of the last pixel maps to a valid location, since round
            % maps 0.5 to 1.0.
            subscript(containedSubscripts) = min(round(self.worldToIntrinsic(worldCoordinate(containedSubscripts))), self.NumberOfSamples);
            
        end
        
        function intrinsicCoordinate = worldToIntrinsic(self,worldCoordinate)
            
            validateattributes(worldCoordinate,{'numeric'},{'real','nonsparse'},'worldToIntrinsic');

            intrinsicCoordinate = 0.5 + (worldCoordinate-self.StartCoordinateInWorld) * self.DeltaDenominator / self.DeltaNumerator;
            
        end
        
        
    end
    
    
end

function [n,d] = simplifyRatio(ratioIn)

n = ratioIn;
d = 1;
[nNew,dNew] = rat(ratioIn);
% If we can exactly represent the input as a simple ratio, do it.
% Otherwise, just keep the original representation. We never want to change
% the resolution as a result of the implementation detail of storing the
% resolution as a ratio.
if isequal(nNew/dNew,ratioIn)
    n = nNew;
    d = dNew;
end
    
end

