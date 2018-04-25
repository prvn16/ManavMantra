function I = anisotropicDiffusion2D(I,gradientThreshold, connectivity, conductionMethod)
paddedImg = padarray(I, [1 1], 'replicate');
    dd = sqrt(2);
    switch connectivity
        case 'minimal'
            % DiffusionRate is fixed to 1/4 because we considered nearest neighbour
            % differences in 4 directions(East,West,North,South)
            diffusionRate = 1/4;
            diffImgNorth = paddedImg(1:end-1,2:end-1) - paddedImg(2:end,2:end-1);
            diffImgEast = paddedImg(2:end-1,2:end) - paddedImg(2:end-1,1:end-1);
            switch conductionMethod
                % Conduction coefficients
                case 'exponential'
                    conductCoeffNorth = exp(-(abs(diffImgNorth)/gradientThreshold).^2);
                    conductCoeffEast = exp(-(abs(diffImgEast)/gradientThreshold).^2);
                case 'quadratic'
                    conductCoeffNorth = 1./(1+(abs(diffImgNorth)/gradientThreshold).^2);
                    conductCoeffEast = 1./(1+(abs(diffImgEast)/gradientThreshold).^2);
            end
            fluxNorth = conductCoeffNorth .* diffImgNorth;
            fluxEast =  conductCoeffEast .* diffImgEast;
            
            % Discrete PDE solution
            I = I + diffusionRate * (fluxNorth(1:end-1,:) - fluxNorth(2:end,:) + ...
                fluxEast(:,2:end) - fluxEast(:,1:end-1));
        case 'maximal'
            % DiffusionRate is fixed to 1/8 because we considered nearest neighbour
            % differences in 8 directions
            diffusionRate = 1/8;
            diffImgNorth = paddedImg(1:end-1,2:end-1) - paddedImg(2:end,2:end-1);
            diffImgEast = paddedImg(2:end-1,2:end) - paddedImg(2:end-1,1:end-1);
            diffImgNorthWest = paddedImg(1:end-2,1:end-2) - I;
            diffImgNorthEast = paddedImg(1:end-2,3:end) - I;
            diffImgSouthWest = paddedImg(3:end,1:end-2) - I;
            diffImgSouthEast = paddedImg(3:end,3:end) - I;
            switch conductionMethod
                % Conduction coefficients
                case 'exponential'
                    conductCoeffNorth = exp(-(abs(diffImgNorth)/gradientThreshold).^2);
                    conductCoeffEast = exp(-(abs(diffImgEast)/gradientThreshold).^2);
                    conductCoeffNorthWest = exp(-(abs(diffImgNorthWest)/gradientThreshold).^2);
                    conductCoeffNorthEast = exp(-(abs(diffImgNorthEast)/gradientThreshold).^2);
                    conductCoeffSouthWest = exp(-(abs(diffImgSouthWest)/gradientThreshold).^2);
                    conductCoeffSouthEast = exp(-(abs(diffImgSouthEast)/gradientThreshold).^2);
                case 'quadratic'
                    conductCoeffNorth = 1./(1+(abs(diffImgNorth)/gradientThreshold).^2);
                    conductCoeffEast = 1./(1+(abs(diffImgEast)/gradientThreshold).^2);
                    conductCoeffNorthWest= 1./(1+(abs(diffImgNorthWest)/gradientThreshold).^2);
                    conductCoeffNorthEast = 1./(1+(abs(diffImgNorthEast)/gradientThreshold).^2);
                    conductCoeffSouthWest = 1./(1+(abs(diffImgSouthWest)/gradientThreshold).^2);
                    conductCoeffSouthEast = 1./(1+(abs(diffImgSouthEast)/gradientThreshold).^2);
            end
            fluxNorth = conductCoeffNorth .* diffImgNorth;
            fluxEast =  conductCoeffEast .* diffImgEast;
            fluxNorthWest = conductCoeffNorthWest .* diffImgNorthWest;
            fluxNorthEast = conductCoeffNorthEast .* diffImgNorthEast;
            fluxSouthWest = conductCoeffSouthWest .* diffImgSouthWest;
            fluxSouthEast = conductCoeffSouthEast .* diffImgSouthEast;
            % Discrete PDE solution
            I = I + diffusionRate * (fluxNorth(1:end-1,:) - fluxNorth(2:end,:) + ...
                fluxEast(:,2:end) - fluxEast(:,1:end-1) + (1/(dd^2)).* fluxNorthWest + ...
                (1/(dd^2)).* fluxNorthEast + (1/(dd^2)).* fluxSouthWest + (1/(dd^2)).* fluxSouthEast);
            
    end
end
