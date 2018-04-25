% This internal helper class may change in a future release.

%  Copyright 2008-2009 The MathWorks, Inc.

% Class to for drawing the cross section of a 3d selection prism. An object
% should be created on a mouse down event, and the prism drawn by calling
% draw on mouse motion. The reset method should be called on the object on
% a mouse up to clear the selection graphic.

classdef (CaseInsensitiveProperties = true) select3d < brushing.select
    properties
        % Defines if brushing prism should be clipped by axes bounds
        Clipping = true;
    end
    methods
        function this = select3d(hostAxes)
            this = this@brushing.select(hostAxes);
        end
    end
    methods (Static = true)
        function figurePixelVectorNormalized = convertToFigNormalized(hAx,hFig,x,varargin)
            
            % Convert x (3xn) in axes space to figure normalized units
            % Resurn 2 rows
            if nargin<=3
                transMat = brushing.select3d.getAxesTransform(hAx);
            else
                transMat = varargin{1};
            end
            figurePixelVector = brushing.select3d.doTransform(transMat,x); %3xn
            figpixelbounds = getpixelposition(hFig);
            figurePixelVectorNormalized = [figurePixelVector(1,:)/figpixelbounds(3);...
                                           figurePixelVector(2,:)/figpixelbounds(4)];
            % Flip the Y axes sense
            figurePixelVectorNormalized(2,:) = 1.0-figurePixelVectorNormalized(2,:);
        end
        
        function transMat = getAxesTransform(hAx)
            
            % Returns an invertible transformation matrix that represents the
            % transformation of a point in the axes coordinate space to pixel-space.
            % Based on HG's gs_data3matrix_to_pixel internal C-function. It should be
            % noted that the Y-coordinate is flipped with respect to the Figure
            % Window's returned "CurrentPoint" properties
            
            % Get needed transforms
            xform = get(hAx,'x_RenderTransform');
            offset = get(hAx,'x_RenderOffset');
            scale = get(hAx,'x_RenderScale');
            zeroInd = scale == 0;
            invScale = zeros(size(scale));
            invScale(~zeroInd) = 1./scale(~zeroInd);
            transMat = xform * [diag(invScale) -offset;0 0 0 1];
        end
        %----------------------------------------------------------------%
        function newData = doTransform(transMat,data)
            
            % Transforms data based on the homogeneous transform matrix. Data must be
            % 3xn matrix.
            
            data = [data;ones(1,size(data,2))];
            newData = transMat*data;
            w = newData(4,:);
            w(w==0) = 1;
            newData = newData(1:3,:);
            newData(1,:) = newData(1,:)./w;
            newData(2,:) = newData(2,:)./w;
            newData(3,:) = newData(3,:)./w;
        end
        
        % Invert the mapping from 3d axes space to 2d figure pixel space.
        function axesVector = convertFromFigPixels(hAx,x)
            
            if any(isnan(x))
                axesVector = NaN(2,3);
                return
            end
            % Get the transfor matrix
            transMat = brushing.select3d.getAxesTransform(hAx);
            
            % Find the 3d axes coords for z==0, and z==1
            axesVector1 = transMat\([x(:);0;1]);
            axesVector2 = transMat\([x(:);1;1]);
            axesVector1 = axesVector1(1:3)/axesVector1(4);
            axesVector2 = axesVector2(1:3)/axesVector2(4);
            axesVector = [axesVector1(:)';axesVector2(:)'];
        end
    end
end
