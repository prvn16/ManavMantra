%esfrChart Edge Spatial Frequency Response (eSFR) test chart
%
%   An esfrChart encapsulates an enhanced version of the edge spatial
%   frequency response test chart specified in ISO 12233:2014 standard.
%
%   esfrChart properties:
%       Image                           - Original test chart image.
%       SlantedEdgeROIs                 - Spatial and intensity information
%                                         of slanted edge regions of interest (ROIs).
%       GrayROIs                        - Spatial and intensity information of gray ROIs.
%       ColorROIs                       - Spatial and intensity information of color ROIs.
%       RegistrationPoints              - Coordinates of registration points.
%       ReferenceGrayLab                - Reference intensities of the GrayROIs in CIE L*a*b*
%                                         color space. This parameter can
%                                         be set to custom values in case
%                                         default values do not match with
%                                         a particular chart.
%       ReferenceColorLab               - Reference intensities of the
%                                         ColorROIs in CIE L*a*b* color space.
%                                         This parameter can be set to
%                                         custom values in case default
%                                         values do not match with a
%                                         particular chart.
%
%   esfrChart methods:
%       esfrChart                   - Construct an esfrChart object from a test image.
%       measureSharpness            - Measure sharpness using slanted edge ROIs.
%       measureChromaticAberration  - Measure chromatic aberration using slanted edge ROIs.
%       measureNoise                - Measure noise using gray ROIs
%       measureColor                - Measure color reproduction using color ROIs.
%       measureIlluminant           - Measure the scene illuminant.
%       displayChart                - Display constructed esfrChart
%
%   References:
%   ----------
%
%   [1] ISO 12233:2014 - Photography -- Electronic still picture imaging --
%   Resolution and spatial frequency responses.
%
%   [2] Imatest Extended eSFR ISO test chart
%
%   Example
%   -------
%   % This example shows how to construct an esfrChart object
%   % from a test image. Post construction the chart object is
%   % displayed for visually verifying proper import.
%
%   I = imread('eSFRTestImage.jpg');
%   chart = esfrChart(I,'Sensitivity',0.6);
%   figure
%   displayChart(chart);
%
%   See also plotSFR, displayColorPatch, plotChromaticity

% Copyright 2017 The MathWorks, Inc.

classdef esfrChart
    
    properties(SetAccess = private, GetAccess = public)
        
        %Image - Original chart image
        %
        %   Original chart image provided to create the esfrChart object to
        %   perform quality measurements. It is an MxNx3 RGB image.
        Image
        
        %slantedEdgeROIs - Spatial extent and intensity values for slanted
        %                  edge regions of interest(ROIs).
        %
        %   An array of structures, each corresponding to a slanted edge
        %   ROI and containing the following fields:
        %
        %       ROI          : A 1x4 matrix specifying spatial extent of the ROI as
        %                      [X Y Width Height] where X and Y are image
        %                      coordinates of the top left corner of the
        %                      ROI.
        %       ROIIntensity : Intensity values within the ROI in RGB format
        %                      and is a Height x Width x 3 matrix.
        SlantedEdgeROIs struct
        
        %GrayROIs - Spatial extent and intensity values for gray ROIs.
        %
        %   An array of structures, each corresponding to a gray ROI and
        %   containing the following fields:
        %
        %       ROI          : A 1x4 matrix specifying spatial extent of the ROI as
        %                      [X Y Width Height] where X and Y are image
        %                      coordinates of the top left corner of the
        %                      ROI.
        %       ROIIntensity : Intensity values within the ROI in RGB format
        %                      and is a Height x Width x 3 matrix.
        GrayROIs struct
        
        %ColorROIs - Spatial extent and intensity values for color ROIs.
        %
        %   An array of structures, each corresponding to a color ROI and
        %   containing the following fields:
        %
        %       ROI          : A 1x4 matrix specifying spatial extent of the ROI as
        %                      [X Y Width Height] where X and Y are image
        %                      coordinates of the top left corner of the
        %                      ROI.
        %       ROIIntensity : Intensity values within the ROI in RGB format
        %                      and is a Height x Width x 3 matrix.
        ColorROIs struct
        
        %RegistrationPoints - Image coordinates of the registration points.
        %
        %   Image coordinates of the four registration points stored in a
        %   4x2 matrix where row one corresponds to top left, two to top
        %   right, three to bottom right and four to bottom left
        %   registration point.
        RegistrationPoints
    end
    
    properties(Access = public)
        %ReferenceGrayLab - Reference CIE L*a*b* values of gray ROIs
        %
        %   A 20x3 matrix containing the reference intensities of the gray
        %   ROIs in CIE L*a*b* color space. They correspond to linear RGB
        %   values when converted to RGB color space.
        %
        %   If required, the property can be set as:
        %
        %   chart.ReferenceGrayLab = GRAYLABDATA;
        %
        %   GRAYLABDATA is a 20x3 matrix containing the reference
        %   intensities of the 20 gray ROIs sequentially numbered as
        %   displayed when using the displayChart function. The values
        %   should be in CIE L*a*b* color space with the first column
        %   containing the L values, second one the a values and third one
        %   the b values respectively.
        %
        %   Notes
        %   -----
        %   1.  Default CIE L*a*b* values for the gray ROIs are included
        %       with the chart object. However, there may be variations
        %       depending on several factors such as print quality and
        %       measuring conditions.
        ReferenceGrayLab
        
        %ReferenceColorLab - Reference CIE L*a*b* values of color ROIs
        %
        %   A 16x3 matrix containing the reference intensities of the color
        %   ROIs in CIE L*a*b* color space. They are used to measure color
        %   reproduction. They correspond to linear RGB values when
        %   converted to RGB color space.
        %
        %   If required, the property can be set as:
        %
        %   chart.ReferenceColorLab = COLORLABDATA;
        %
        %   COLORLABDATA is a 16x3 matrix containing the reference
        %   intensities of the 16 color ROIs sequentially numbered as
        %   displayed when using the displayChart function. The values
        %   should be in CIE L*a*b* color space with the first column
        %   containing the L values, second one the a values and third one
        %   the b values respectively.
        %
        %   Notes
        %   -----
        %   1.  Default CIE L*a*b* values for the color ROIs are included
        %       with the chart object. However, there may be variations
        %       depending on several factors such as print quality and
        %       measuring conditions.
        %   2.  Accurate reference color values will result in more
        %       faithful color reproduction measurements.
        ReferenceColorLab
    end
    
    properties(Hidden = true)
        ImageGray
        ImageRow
        ImageCol
        modelPoints
        refinedPoints
        sigma
        importSensitivity
        importUsingRegistrationPoints
    end
    
    properties(Hidden = true, Constant)
        sl_edgeROI_height_ratio = 0.7
        sl_edgeROI_width_ratio = 0.4
        numSquares = 15
        numGrayPatches = 20
        grayPatch_ratio = 0.8
        numColorPatches = 16
        colorPatch_ratio = 0.8
        horizontalROIs = 2:2:60;
        verticalROIs = 1:2:60;
    end
    
    methods
        function chart = esfrChart(varargin)
            % esfrChart Construct an esfrChart object from an image.
            %
            %   CHART = esfrChart(A) constructs an esfrChart object CHART
            %   from image A. A has to be an RGB image.
            %
            %   CHART = esfrChart(___, Name, Value, ___) constructs an
            %   esfrChart object CHART where additional parameters
            %   controlling the chart import can be provided as name value
            %   pairs in case the import in unsuccessful using the default
            %   parameter settings.
            %
            %   Parameters are:
            %
            %   'Sensitivity'           - Specifies the sensitivity of
            %                             chart detection and is a scalar
            %                             in the range of [0, 1]. Low/high
            %                             sensitivity results in detection
            %                             of fewer/more number of interest
            %                             points in the test image for
            %                             model registration. Default value
            %                             is 0.5.
            %
            %   'RegistrationPoints'    - In case no sensitivity parameter value
            %                             result in successful chart
            %                             import, the registration points
            %                             can be directly provided in image
            %                             coordinates as a 4x2 matrix where
            %                             row one is top left, two is top
            %                             right, three is bottom right and
            %                             four is bottom left registration
            %                             point.
            %
            %   NOTE: Only one of the above name value pairs can be
            %         specified while importing a test image and not both.
            %
            %   Class Support
            %   -------------
            %
            %   A must be a real, non-sparse, M-by-N-by-3 matrix of one of
            %   the following classes: uint8, uint16, single or double.
            %
            %   Notes
            %   -----
            %
            %   1.  The esfrChart is an extended version of the ISO
            %       12233:2014 standard test chart. Check references for
            %       further details.
            %   2.  For accurate and reliable results, the test chart should
            %       be imaged according to standard specifications outlined
            %       in the ISO standards, by the manufacturer and also in
            %       relevant literature. As a simple guideline, the chart
            %       should be horizontally aligned with care on a light
            %       background. It should cover over 90% of the imaged
            %       region and the acquired image should ideally have some
            %       background space between the chart top/bottom edge and
            %       the image top/bottom edge. It is recommended that the
            %       minimum image width should be at least 500 pixels for
            %       reliable measurements.
            %   3.  The chart can be imaged in its entirety or at an aspect
            %       ratio of 3:2 or 4:3 as specified on the chart.
            %   4.  For best results, all test chart images should be properly
            %       imported and visually verified using the displayChart
            %       function before any measurements are performed.
            %
            %   References
            %   ----------
            %
            %   [1] ISO 12233:2014 - Photography -- Electronic still
            %   picture imaging -- Resolution and spatial frequency responses.
            %
            %   [2] Imatest Extended eSFR ISO test chart
            %
            %   Example 1
            %   ---------
            %   % This example shows how to construct an esfrChart object from a test
            %   % image. Post construction the chart object is displayed for visually
            %   % verifying proper import.
            %
            %   I = imread('eSFRTestImage.jpg');
            %   chart = esfrChart(I,'Sensitivity',0.6);
            %   figure
            %   displayChart(chart);
            %
            %   Example 2
            %   ---------
            %   % This example shows how to construct an esfrChart object by providing the
            %   % coordinates of the registration points. Please check and follow
            %   % convention in numbering the registration points.
            %
            %   I = imread('eSFRTestImage.jpg');
            %   % Identify the registration points using the pointing device with
            %   % reasonable accuracy
            %   figure
            %   imshow(I)
            %   [X, Y] = ginput(4);
            %   chart = esfrChart(I,'RegistrationPoints',[X, Y]);
            %   figure
            %   displayChart(chart);
            %
            %   See also esfrChart, measureSharpness, measureChromaticAberration,
            %            measureNoise, measureColor, measureIlluminant
            
            %   Copyright 2017 The MathWorks, Inc.
            
            narginchk(0,3);
            
            if nargin > 0
                options = parseInputsesfrChart(varargin{:});
                chart.Image = options.A;
                sensitivity = options.Sensitivity;
                RegistrationPoints = options.RegistrationPoints;
                
                chart.ImageGray = rgb2gray(chart.Image);
                [chart.ImageRow, chart.ImageCol, ~] = size(chart.Image);
                chart.sigma = ceil(chart.ImageCol/500);
                chart.importUsingRegistrationPoints = ~isempty(RegistrationPoints);
                if ~chart.importUsingRegistrationPoints
                    chart.importSensitivity = sensitivity;
                else
                    Xcheck = any((RegistrationPoints(:,1)>chart.ImageCol) | (RegistrationPoints(:,1) < 1));
                    Ycheck = any((RegistrationPoints(:,2)>chart.ImageRow) | (RegistrationPoints(:,2) < 1));
                    invalidRegistrationPoints = Xcheck || Ycheck;
                    
                    if invalidRegistrationPoints
                        error(message('images:esfrChart:invalidRegistrationPoints'));
                    end                    
                end
                
                [chart.RegistrationPoints, chart.modelPoints] = images.internal.testchart.register_esfrChart(chart, chart.importSensitivity,RegistrationPoints);
                images.internal.testchart.verify_esfrChart(chart);
                [chart.refinedPoints, chart.SlantedEdgeROIs] = images.internal.testchart.detectSlantedEdgeROIs(chart);
                chart.GrayROIs = images.internal.testchart.detectGrayPatches(chart);
                chart.ColorROIs = images.internal.testchart.detectColorPatches(chart);
                
                colorReference = load('eSFRdefaultColorReference');
                chart.ReferenceColorLab = [colorReference.defaultColorReference(:,4) colorReference.defaultColorReference(:,5) colorReference.defaultColorReference(:,6)];
                grayReference = load('eSFRdefaultGrayReference');
                chart.ReferenceGrayLab = [grayReference.defaultGrayReference(:,4) grayReference.defaultGrayReference(:,5) grayReference.defaultGrayReference(:,6)];
            end
        end
        
        
        
        % Measurement functions
        function noiseTable = measureNoise(chart)
            %measureNoise   Measure noise using esfrChart
            %
            %   noiseTable = measureNoise(CHART) measures noise levels
            %   using the gray ROIs in a esfrChart image.
            %
            %   The rows of the noiseTable correspond to individual gray
            %   ROIs sequentially numbered as displayed when using the
            %   displayChart function. Variables or columns of the
            %   noiseTable correspond to the following:
            %
            %       1. ROI                      : Index of an ROI
            %       2. MeanIntensity_R          : Mean of R channel pixels in a ROI
            %       3. MeanIntensity_G          : Mean of G channel pixels in a ROI
            %       4. MeanIntensity_B          : Mean of B channel pixels in a ROI
            %       5. RMSNoise_R               : Root mean square (RMS) noise of R pixels
            %       6. RMSNoise_G               : Root mean square noise of G pixels
            %       7. RMSNoise_B               : Root mean square noise of B pixels
            %       8. PercentNoise_R           : RMS noise of R expressed as a percentage
            %                                     of the maximum of the
            %                                     original chart image
            %                                     datatype
            %       9. PercentNoise_G           : RMS noise of G expressed as a percentage
            %                                     of the maximum of the
            %                                     original chart image
            %                                     datatype
            %      10. PercentNoise_B           : RMS noise of B expressed as a percentage
            %                                     of the maximum of the
            %                                     original chart image
            %                                     datatype
            %      11. SignalToNoiseRatio_R     : Ratio of signal to noise in R
            %      12. SignalToNoiseRatio_G     : Ratio of signal to noise in G
            %      13. SignalToNoiseRatio_B     : Ratio of signal to noise in B
            %      14. SNR_R                    : Signal to noise ratio in dB
            %                                     (20*log(Signal/Noise)) for R
            %      15. SNR_G                    : Signal to noise ratio in dB
            %                                     (20*log(Signal/Noise)) for G
            %      16. SNR_B                    : Signal to noise ratio in dB
            %                                     (20*log(Signal/Noise)) for B
            %      17. PSNR_R                   : Peak signal to noise ratio in dB for R
            %      18. PSNR_G                   : Peak signal to noise ratio in dB for G
            %      19. PSNR_B                   : Peak signal to noise ratio in dB for B
            %      20. RMSNoise_Y               : RMS noise for Y channel in YCbCr color
            %                                     space
            %      21. RMSNoise_Cb              : RMS noise for Cb channel in YCbCr color
            %                                     space
            %      22. RMSNoise_Cr              : RMS noise for Cr channel in YCbCr color
            %                                     space
            %
            %   Class Support
            %   -------------
            %   CHART is an esfrChart object. noiseTable is a table.
            %
            %   Notes
            %   -----
            %
            %   1.  It is recommended to linearize image data before performing noise
            %       measurements. rgb2lin might be suitable for linearization depending
            %       on test image data.
            %   2.  An esfrChart should be correctly imported for accurate and reliable
            %       measurements. Use esfrChart function to create a correctly imported
            %       chart.
            %
            %   Example
            %   -------
            %   % This example shows the procedure for measuring noise and plotting some of
            %   % the results
            %
            %   I = imread('eSFRTestImage.jpg');
            %   I = rgb2lin(I);
            %   chart = esfrChart(I);
            %   figure
            %   displayChart(chart);
            %   noiseTable = measureNoise(chart);
            %
            %   % Plot results
            %   figure
            %   subplot(1,2,1) 
            %   plot(noiseTable.ROI, noiseTable.MeanIntensity_R,'r-o', ...
            %       noiseTable.ROI, noiseTable.MeanIntensity_G,'g-o',noiseTable.ROI, ...
            %       noiseTable.MeanIntensity_B,'b-o')
            %   title('Signal')
            %   ylabel('Intensity')
            %   xlabel('Gray ROI Number')
            %   grid on
            %   subplot(1,2,2)
            %   plot(noiseTable.ROI, noiseTable.SNR_R,'r-^', noiseTable.ROI, ...
            %       noiseTable.SNR_G,'g-^',noiseTable.ROI, noiseTable.SNR_B,'b-^')
            %   title('SNR')
            %   ylabel('dB')
            %   xlabel('Gray ROI Number')
            %   grid on
            %
            %   See also esfrChart, measureColor, measureSharpness,
            %            measureChromaticAberration, rgb2lin, lin2rgb
            
            %   Copyright 2017 The MathWorks, Inc.
            
            narginchk(1,1);
            validateChart(chart);
            
            noiseTable = images.internal.testchart.esfrMeasureNoise(chart);
            
        end
        
        function [colorTable, varargout] = measureColor(chart)
            %measureColor   Measure color reproduction using esfrChart
            %
            %   colorTable = measureColor(CHART) measures color values of
            %   the color ROIs in an esfrChart image.
            %
            %   [___, colorCorrectionMatrix] = measureColor(CHART) returns
            %   a color correction matrix computed using a simple linear
            %   least squares fit.
            %
            %   The rows of the colorTable correspond to individual color
            %   ROIs sequentially numbered as displayed when using the
            %   displayChart function. Variables or columns of the
            %   colorTable correspond to the following:
            %
            %       1. ROI          : Index of an ROI
            %       2. Measured_R   : Mean of R channel pixels in a ROI
            %       3. Measured_G   : Mean of G channel pixels in a ROI
            %       4. Measured_B   : Mean of B channel pixels in a ROI
            %       5. Reference_L  : Reference L values
            %       6. Reference_a  : Reference a values
            %       7. Reference_b  : Reference b values
            %       8. Delta_E      : Euclidean color distance between measured and
            %                         reference color values as outlined
            %                         in CIE76
            %
            %   Class Support
            %   -------------
            %
            %   CHART is an esfrChart object. colorTable is a table.
            %   colorCorrectionMatrix is a 4-by-3 double matrix.
            %
            %   Notes
            %   -----
            %
            %   1.  It is recommended to linearize image data before
            %       performing color measurements. rgb2lin might be suitable
            %       for linearization depending on test image data.
            %   2.  An esfrChart should be correctly imported for accurate and
            %       reliable measurements. Use esfrChart function to create a
            %       correctly imported chart.
            %   3.  The colorCorrectionMatrix is a 4-by-3 matrix which
            %       captures an affine transformation and can be used to
            %       color correct images captured under similar lighting
            %       conditions as the test chart image.
            %
            %   Example 1
            %   ---------
            %   % This example shows the procedure for measuring color and plotting the
            %   % results
            %
            %   I = imread('eSFRTestImage.jpg');
            %   I = rgb2lin(I);
            %   chart = esfrChart(I);
            %   figure
            %   displayChart(chart);
            %   colorTable = measureColor(chart);
            %
            %   % Plot results
            %   figure
            %   displayColorPatch(colorTable)
            %   figure
            %   plotChromaticity(colorTable)
            %
            %   Example 2
            %   ---------
            %   % This example shows the procedure for calculating and using a color
            %   % correction matrix
            %
            %   I = imread('eSFRTestImage.jpg');
            %   I = rgb2lin(I);
            %   chart = esfrChart(I);
            %   figure
            %   displayChart(chart);
            %   [colorTable, colorCorrectionMatrix] = measureColor(chart);
            %
            %   Aoriginal = imread('lighthouse.png');
            %   A = rgb2lin(Aoriginal);
            %   A_R = A(:,:,1);
            %   A_G = A(:,:,2);
            %   A_B = A(:,:,3);
            %
            %   B = double([A_R(:) A_G(:) A_B(:) ones(length(A_R(:)),1)])*colorCorrectionMatrix;
            %   C = zeros(size(A),'like',A);
            %   C(:,:,1) = reshape(B(:,1),size(A,1),size(A,2));
            %   C(:,:,2) = reshape(B(:,2),size(A,1),size(A,2));
            %   C(:,:,3) = reshape(B(:,3),size(A,1),size(A,2));
            %   C = lin2rgb(C);
            %
            %   figure, imshow(Aoriginal)
            %   figure, imshow(C)
            %
            %   See also esfrChart, measureNoise, measureSharpness,
            %   measureChromaticAberration, rgb2lin, lin2rgb,
            %   displayColorPatch, plotChromaticity
            
            %   Copyright 2017 The MathWorks, Inc.
            
            narginchk(1,1);
            nargoutchk(1,2);
            validateChart(chart);
            
            colorTable = images.internal.testchart.esfrMeasureColor(chart);
            if nargout == 2
                measured_RGB = [colorTable.Measured_R colorTable.Measured_G colorTable.Measured_B];
                
                colorCorMatrix = images.internal.testchart.calculateColorCorMatrix(measured_RGB, ...
                    lab2rgb(chart.ReferenceColorLab,'OutputType', ...
                    class(colorTable.Measured_R)));
                
                varargout = {colorCorMatrix};
            end
            
        end
        
        function aberrationTable = measureChromaticAberration(chart, varargin)
            %measureChromaticAberration     Measure chromatic aberration using esfrChart
            %
            %   aberrationTable = measureChromaticAberration(CHART)
            %   measures chromatic aberration at all slanted edge regions
            %   of interest (ROIs).
            %
            %   aberrationTable = measureChromaticAberration(___ , Name,
            %   Value) measures chromatic aberration at slanted edge ROIs
            %   with additional parameters specifying the specific ROIs at
            %   which aberration is measured.
            %
            %   Parameters are:
            %
            %   'ROIIndex'      :   Specify index of a particular ROI where
            %                       aberration would be measured. Numbering
            %                       convention is same as displayed when an
            %                       esfrChart is displayed using
            %                       displayChart function. It can also be a
            %                       vector of indices. Default is 1:60.
            %
            %   'ROIOrientation':   Specify orientation of ROIs for which
            %                       aberration would be measured. Options are 'vertical',
            %                       'horizontal' and 'both'. Default is 'both'.
            %
            %   NOTE: When both ROIIndex and ROIOrientation are specified,
            %         the intersection of the two sets of ROIs are used for
            %         measurement.
            %
            %   The rows of the aberrationTable correspond to individual
            %   slanted edge ROIs numbered as displayed when using the
            %   displayChart function. Variables or columns of the
            %   aberrationTable correspond to the following:
            %
            %       1. ROI                  : Index of an ROI.
            %       2. aberration           : Chromatic aberration measured as
            %                                 the area between the maximum and the
            %                                 minimum R,G and B edge
            %                                 profiles.
            %       3. percentAberration    : Aberration expressed as a percentage of
            %                                 the distance between the center of the
            %                                 image and the center of the ROI in pixels.
            %       4. edgeProfile          : R,G,B and Y edge profiles averaged along the
            %                                 slanted edge.
            %       5. normalizedEdgeProfile: edgeProfiles normalized between [0,1] using
            %                                 5% of the front end and tail end data.
            %
            %   Class Support
            %   -------------
            %
            %   CHART is an esfrChart object. ROIIndex can be uint8,
            %   uint16, uint32, int8, int16, int32, single and double.
            %   ROIOrientation can be string or char vector.
            %
            %   Notes
            %   -----
            %
            %   1.  Chromatic aberration is usually measured best at
            %       slanted edge ROIs which are roughly orthogonal to the
            %       line connecting the center of the image and the center
            %       of the ROI and farthest from the center of the image.
            %       Since chromatic aberration increases radially from the
            %       center of the image the measurements at slanted edge
            %       ROIs which are very close to the center of the image
            %       should be ignored.
            %   2.  Chromatic aberration reported is indicative of
            %       perceptual chromatic aberration.
            %   3.  The absolute chromatic aberration measured in terms of pixels
            %       is measured in the horizontal of vertical direction in
            %       alignment with the pixel arrangement. However,
            %       chromatic aberration is a radial phenomenon and should
            %       ideally be measured radially.
            %   4.  The normalized edge profile is provided at about four
            %       times the sampling rate compared to the test image, as
            %       is used by the ISO 12233:2014 standard.
            %   5.  It is recommended to linearize image data before performing
            %       chromatic aberration measurements. rgb2lin might be
            %       suitable for linearization depending on test image
            %       data.
            %   6.  Y = [0.213*R 0.715*G 0.072*B]
            %   7.  An esfrChart should be correctly imported for accurate and reliable
            %       measurements. Use esfrChart function to create a
            %       correctly imported chart.
            %
            %   Example
            %   -------
            %   % This example show how to measure chromatic aberration using esfrChart
            %   % and plot measurements.
            %
            %   I = imread('eSFRTestImage.jpg');
            %   I = rgb2lin(I);
            %   chart = esfrChart(I);
            %   figure
            %   displayChart(chart);
            %   chTable = measureChromaticAberration(chart);
            %
            %   % Plot results
            %   figure
            %   ROIIndex = 3;
            %   index = length(chTable.normalizedEdgeProfile{ROIIndex}.normalizedEdgeProfile_R);
            %   plot(1:index, chTable.normalizedEdgeProfile{ROIIndex}.normalizedEdgeProfile_R,'r', ...
            %       1:index, chTable.normalizedEdgeProfile{ROIIndex}.normalizedEdgeProfile_G,'g', ...
            %       1:index, chTable.normalizedEdgeProfile{ROIIndex}.normalizedEdgeProfile_B,'b')
            %   xlabel('Pixel')
            %   ylabel('Normalized intensity')
            %   title(['ROI ' num2str(ROIIndex) ' with aberration ' num2str(chTable.aberration(ROIIndex))])
            %
            %   figure
            %   plot(1:index, chTable.edgeProfile{ROIIndex}.edgeProfile_R,'r', ...
            %       1:index, chTable.edgeProfile{ROIIndex}.edgeProfile_G,'g', ...
            %       1:index, chTable.edgeProfile{ROIIndex}.edgeProfile_B,'b')
            %   xlabel('Pixel')
            %   ylabel('intensity')
            %   title('Intensity profile')
            %
            %   See also esfrChart, measureSharpness, measureNoise, measureColor
            
            %   Copyright 2017 The MathWorks, Inc.
            
            
            narginchk(1,5);
            validateChart(chart);
            options = parseInputsMeasureChromaticAberration(varargin{:});
            ROIIndex = double(options.ROIIndex);
            ROIOrientation = options.ROIOrientation;
            
            % Identify valid ROIs for sharpness calculation
            switch ROIOrientation
                case 'horizontal'
                    validROIs = intersect(ROIIndex,chart.horizontalROIs);
                case 'vertical'
                    validROIs = intersect(ROIIndex,chart.verticalROIs);
                case 'both'
                    validROIs = ROIIndex;
            end
            
            if isempty(validROIs)
                error(message('images:esfrChart:noSlantedEdgeROIs'));
            end
            
            flagValidROIs = true(length(validROIs),1);
            for i = 1:length(validROIs)
                ROInum = validROIs(i);
                if(all(isnan(chart.SlantedEdgeROIs(ROInum).ROI)))
                    flagValidROIs(i) = false;
                end
            end
            validROIs = validROIs(flagValidROIs);
            
            aberrationTable = images.internal.testchart.esfrMeasureChAberration(chart,validROIs);
        end
        
        function [sharpnessTable, varargout] = measureSharpness(chart, varargin)
            %measureSharpness Compute spatial frequency response using esfrChart
            %
            %   sharpnessTable = measureSharpness(CHART) measures spatial
            %   frequency response (SFR) at all slanted edge regions of
            %   interest (ROIs) of an esfrChart. Additional measurements
            %   include frequency at which the response drops to 50% of
            %   initial (MTF50) and peak value (MTF50P).
            %
            %   sharpnessTable = measureSharpness(___ , Name, Value)
            %   measures SFR at slanted edge ROIs with additional
            %   parameters specifying the ROIs at which it is measured and
            %   the percent of the initial and peak frequency response for
            %   which the corresponding frequency is reported.
            %
            %   Parameters are:
            %
            %   'ROIIndex'          :   Specify index of a particular ROI where
            %                           SFR would be measured. Numbering convention is
            %                           same as displayed when an esfrChart is displayed
            %                           using displayChart function. It can also be a
            %                           vector of indices. Default is 1:60.
            %
            %   'ROIOrientation'    :   Specify orientation of ROIs for which SFR would be
            %                           measured. Options are 'vertical', 'horizontal' and
            %                           'both'. Default is 'both'.
            %
            %   'PercentResponse'   :   A percentage of the initial or peak response at
            %                           which the corresponding frequency is
            %                           reported. It has to be an integer and can be
            %                           a vector. Default is 50.
            %
            %
            %   [___, aggregateSharpnessTable] = measureSharpness(___) also
            %   measures and reports average SFRs for vertical and
            %   horizontal slanted edges ROIs as two rows of the
            %   aggregateSharpnessTable.
            %
            %   NOTE: When both ROIIndex and ROIOrientation are specified,
            %         the intersection of the two sets of ROIs are used for
            %         measurement.
            %
            %   The rows of the sharpnessTable correspond to individual
            %   slanted edge ROIs numbered as displayed when using the
            %   displayChart function. Variables or columns of the
            %   sharpnessTable correspond to the following:
            %
            %       1. ROI              : Index of an ROI
            %       2. slopeAngle       : Measured angle in degrees between the slanted
            %                             edge and the horizontal or vertical depending
            %                             on the orientation of the edge
            %       3. confidenceFlag   : A flag which is true when sharpness measurement
            %                             is reliable. It is false when the
            %                             sharpness measurement is not
            %                             reliable due to the following
            %                             conditions, (i) the slopeAngle is
            %                             less than 3.5 or more than 15
            %                             degrees or (ii) the contrast
            %                             within the ROI is less than 20%.
            %       4. SFR              : Table containing SFR measurements for R,G,B and
            %                             Y edge profiles.
            %       5. comment          : In case confidenceFlag is false, outlines the
            %                             reason for unreliable sharpness measurement.
            %       6. MTF'Percent'     : Frequencies for R, G, B and Y at which frequency
            %                             response is 'Percent'/100.
            %       7. MTF'Percent'P    : Frequencies for R, G, B and Y at which frequency
            %                             response is 'Percent'% of peak frequency
            %                             response.
            %
            %   Class Support
            %   -------------
            %
            %   CHART is an esfrChart object. ROIIndex and PercentResponse
            %   can be uint8, uint16, uint32, int8, int16, int32, single
            %   and double. ROIOrientation can be string or char vector.
            %   Both sharpnessTable and aggregateTable are tables.
            %
            %   Notes
            %   -----
            %
            %   1.  The slanted edges are at an angle of 5 degrees from the
            %       horizontal or vertical. The sharpness measurements are
            %       not accurate in case the chart is not properly oriented
            %       and the edge orientation deviates significantly from 5
            %       degrees.
            %   2.  Contrast of a slanted edge ROI is defined as
            %       100 * (IHigh - ILow)/(IHigh + ILow) where IHigh and
            %       ILow are the estimated average intensities of the high
            %       and low intensity regions across the edge. The contrast
            %       is computed for only the red channel.
            %   3.  Sharpness is usually higher towards the center of the
            %       imaged region and decreases towards the periphery.
            %       Also, usually horizontal sharpness is higher than
            %       vertical sharpness.
            %   4.  It is recommended to linearize image
            %       data before performing sharpness measurements. rgb2lin
            %       might be suitable for linearization depending on test
            %       image data.
            %   5.  Y = [0.213*R 0.715*G 0.072*B]
            %   6.  An esfrChart should be correctly imported for accurate and reliable
            %       measurements. Use esfrChart function to create a
            %       correctly imported chart.
            %
            %   References
            %   ----------
            %
            %   [1] ISO 12233:2014 - Photography -- Electronic still picture imaging --
            %       Resolution and spatial frequency responses.
            %
            %   [2] sfrmat3: SFR evaluation for digital cameras and
            %       scanners, Peter D. Burns
            %
            %   [3] Imatest Extended eSFR ISO test chart
            %
            %   Example
            %   -------
            %   % This example shows how to perform sharpness measurements
            %   % using esfrChart and plot results.
            %
            %   I = imread('eSFRTestImage.jpg');
            %   I = rgb2lin(I);
            %   chart = esfrChart(I);
            %   figure
            %   displayChart(chart)
            %
            %   % Measure sharpness at ROIs one to four along with their averaged
            %   % responses in vertical and horizontal directions
            %   [sharpnessTable, aggregateSharpnessTable] = measureSharpness(chart, ...
            %       'ROIIndex',1:4);
            %   plotSFR(sharpnessTable, 'ROIIndex',1:4)
            %   plotSFR(aggregateSharpnessTable)
            %
            %   See also esfrChart, measureColor, measureNoise, measureChromaticAberration,
            %            rgb2lin, lin2rgb, plotSFR
            
            %   Copyright 2017 The MathWorks, Inc.
            
            narginchk(1,7);
            nargoutchk(0,2);
            validateChart(chart);
            options = parseInputsMeasureSharpness(varargin{:});
            ROIIndex = double(options.ROIIndex);
            ROIOrientation = options.ROIOrientation;
            percentResponse = double(options.PercentResponse);
            
            % Identify valid ROIs for sharpness calculation
            switch ROIOrientation
                case 'horizontal'
                    validROIs = intersect(ROIIndex,chart.horizontalROIs);
                case 'vertical'
                    validROIs = intersect(ROIIndex,chart.verticalROIs);
                case 'both'
                    validROIs = ROIIndex;
            end
            
            if isempty(validROIs)
                error(message('images:esfrChart:noSlantedEdgeROIs'));
            end
            
            flagValidROIs = true(length(validROIs),1);
            for i = 1:length(validROIs)
                ROInum = validROIs(i);
                if(all(isnan(chart.SlantedEdgeROIs(ROInum).ROI)))
                    flagValidROIs(i) = false;
                end
            end
            validROIs = validROIs(flagValidROIs);
            
            sharpnessTable = images.internal.testchart.esfrMeasureSharpness(chart,validROIs,percentResponse);
            
            if nargout == 2
                aggregateSharpnessTable = images.internal.testchart.calculateAggregateSharpnessTable(sharpnessTable,percentResponse);
                varargout = {aggregateSharpnessTable};
            end
        end
        
        function illum = measureIlluminant(chart)
            % measureIlluminant Estimate the scene illuminant using esfrChart
            %
            %   ILLUMINANT = measureIlluminant(CHART) measures the scene
            %   illuminant using the gray ROIs of the esfrChart
            %
            %   Class Support
            %   -------------
            %
            %   CHART is an esfrChart object. ILLUMINANT is a three element
            %   vector of doubles.
            %
            %   Notes
            %   -----
            %
            %   1.  The estimated illuminant can be used to white balance 
            %       images acquired under similar lighting conditions as
            %       the test chart.
            %   2.  It is recommended to linearize image data before
            %       performing illuminant measurements. rgb2lin might be
            %       suitable for linearization depending on test image data. 
            %   3.  An esfrChart should be correctly imported for accurate
            %       and reliable measurements. Use esfrChart function to
            %       create a correctly imported chart.
            %
            %   Example
            %   -------
            %   % This example shows how to estimate the illuminant of the
            %   % scene using esfrChart and how to white balance an image
            %   % using the estimated illuminant.
            %
            %   Igamma = imread('eSFRTestImage.jpg');
            %   I = rgb2lin(Igamma);
            %   chart = esfrChart(I);
            %   figure
            %   displayChart(chart)
            %
            %   % Estimate illuminant and white balance the chart image
            %   % itself as a test sample. Ideally the illuminant can be used
            %   % to color balance images acquired under similar lighting
            %   % conditions as the test chart.
            %
            %   illum = measureIlluminant(chart);
            %   imWB = chromadapt(I, illum);
            %   imWB = lin2rgb(imWB);
            %   
            %   figure
            %   imshow(Igamma)
            %   title('Original Image');
            %   figure
            %   imshow(imWB)
            %   title('White Balanced Image');
            %
            %   See also esfrChart, chromadapt, measureColor, measureNoise,
            %            measureChromaticAberration
            
            %   Copyright 2017 The MathWorks, Inc.
            
            narginchk(1,1);
            validateChart(chart);
            
            R_sum = 0;
            G_sum = 0;
            B_sum = 0;
            for i = 1:chart.numGrayPatches
                R_sum = R_sum + mean2(chart.GrayROIs(i).ROIIntensity(:,:,1));
                G_sum = G_sum + mean2(chart.GrayROIs(i).ROIIntensity(:,:,2));
                B_sum = B_sum + mean2(chart.GrayROIs(i).ROIIntensity(:,:,3));
            end
            illum = double([R_sum G_sum B_sum])/chart.numGrayPatches;
        end
        
        % Display functions
        function displayChart(varargin)
            %displayChart Display esfrChart with overlaid regions of interest
            %
            %   displayChart(CHART) displays a valid esfrChart once it has
            %   been successfully imported.
            %
            %   displayChart(___, Name, Value, ___) displays a valid
            %   esfrChart with additional parameters controlling aspects of
            %   the chart display.
            %
            %   Parameters are:
            %
            %   'displayEdgeROIs'           :   Logical controlling whether slanted edge ROIs
            %                                   are overlaid or not. Default is true.
            %
            %   'displayGrayROIs'           :   Logical controlling whether gray ROIs are
            %                                   overlaid or not. Default is true.
            %
            %   'displayColorROIs'          :   Logical controlling whether color ROIs are
            %                                   overlaid or not. Default is true.
            %
            %   'displayRegistrationPoints' :   Logical controlling whether registration
            %                                   points are overlaid or not. Default is
            %                                   true.
            %
            %   'Parent'                    :   Handle of an axes that specifies the parent
            %                                   of the image object created by displayChart.
            %
            %   Class Support
            %   -------------
            %
            %   CHART is an esfrChart object.
            %
            %   Example
            %   -------
            %   % This example shows how to import and display an esfrChart object
            %
            %   I = imread('eSFRTestImage.jpg');
            %   chart = esfrChart(I);
            %
            %   % Display slanted edge ROIs
            %   figure
            %   displayChart(chart,'displayGrayROIs', false,...
            %   'displayColorROIs', false) 
            %
            %   % Display gray ROIs
            %   figure
            %   displayChart(chart,'displayEdgeROIs', false,...
            %   'displayColorROIs', false) 
            %
            %   % Display color ROIs
            %   figure
            %   displayChart(chart,'displayEdgeROIs', false,...
            %   'displayGrayROIs', false) 
            %
            %   % Display all ROIs
            %   figure
            %   displayChart(chart)
            %
            %   See also esfrChart, measureSharpness, measureNoise,
            %   measureColor
            
            %   Copyright 2017 The MathWorks, Inc.
            
            narginchk(1,11);
            options = parseInputsDisplayChart(varargin{:});
            chart = options.chart;
            displayEdgeROIs = options.displayEdgeROIs;
            displayGrayROIs = options.displayGrayROIs;
            displayColorROIs = options.displayColorROIs;
            displayRegistrationPoints = options.displayRegistrationPoints;
            parentAxis = options.Parent;
            
            images.internal.testchart.esfrDisplayChart(chart, displayEdgeROIs, displayGrayROIs, displayColorROIs, displayRegistrationPoints, parentAxis);
        end
        
        
        function chart = set.ReferenceGrayLab(chart,grayLabData)
            validateGrayData(grayLabData);
            chart.ReferenceGrayLab = grayLabData;
        end
        
        function chart = set.ReferenceColorLab(chart,colorLabData)
            validateColorData(colorLabData);
            chart.ReferenceColorLab = colorLabData;
        end
    end
    
    methods(Static, Hidden)
        function self = loadobj(S)
            self = esfrChart;
            self.Image = S.Image;
            self.SlantedEdgeROIs = S.SlantedEdgeROIs;
            self.GrayROIs = S.GrayROIs;
            self.ColorROIs = S.ColorROIs;
            self.RegistrationPoints = S.RegistrationPoints;
            self.ReferenceGrayLab = S.ReferenceGrayLab;
            self.ReferenceColorLab = S.ReferenceColorLab;
            self.modelPoints = S.modelPoints;
            self.refinedPoints = S.refinedPoints;
            self.sigma = S.sigma;
            self.importSensitivity = S.importSensitivity;
            self.importUsingRegistrationPoints = S.importUsingRegistrationPoints;
            self.ImageGray = rgb2gray(S.Image);
            [self.ImageRow, self.ImageCol,~] = size(S.Image);
        end
    end
    
    methods(Hidden)
        function S = saveobj(self)
            S = struct('Image', self.Image, ...
                'SlantedEdgeROIs', self.SlantedEdgeROIs, ...
                'GrayROIs', self.GrayROIs, ...
                'ColorROIs', self.ColorROIs, ...
                'RegistrationPoints',self.RegistrationPoints, ...
                'ReferenceGrayLab', self.ReferenceGrayLab, ...
                'ReferenceColorLab', self.ReferenceColorLab, ...
                'modelPoints', self.modelPoints, ...
                'refinedPoints', self.refinedPoints, ...
                'sigma', self.sigma, ...
                'importSensitivity', self.importSensitivity,...
                'importUsingRegistrationPoints', self.importUsingRegistrationPoints);
        end
    end
end


function options = parseInputsesfrChart(varargin)

parser = inputParser();
parser.addRequired('A',@validateInputImage);
parser.addParameter('Sensitivity',0.5,@validateSensitivity);
parser.addParameter('RegistrationPoints',[],@validateRegistrationPoints);

parser.parse(varargin{:});
options = parser.Results;
end

function options = parseInputsDisplayChart(varargin)

parser = inputParser();
parser.addRequired('chart',@validateChart);
parser.addParameter('displayEdgeROIs',true,@validateDisplayFlag);
parser.addParameter('displayGrayROIs',true,@validateDisplayFlag);
parser.addParameter('displayColorROIs',true,@validateDisplayFlag);
parser.addParameter('displayRegistrationPoints',true,@validateDisplayFlag);
parser.addParameter('Parent',[],@validateParentAxis);

parser.parse(varargin{:});
options = parser.Results;
end

function options = parseInputsMeasureSharpness(varargin)

parser = inputParser();
parser.addParameter('ROIIndex',1:60,@validateROIIndex);
parser.addParameter('ROIOrientation','both',@validateROIOrientation);
parser.addParameter('PercentResponse',50,@validatePercentResponse);

parser.parse(varargin{:});
validOptions = {'horizontal','vertical','both'};
options = parser.Results;
options.ROIOrientation = validatestring(options.ROIOrientation,validOptions, ...
    mfilename,'ROIOrientation');
end

function options = parseInputsMeasureChromaticAberration(varargin)

parser = inputParser();
parser.addParameter('ROIIndex',1:60,@validateROIIndex);
parser.addParameter('ROIOrientation','both',@validateROIOrientation);

parser.parse(varargin{:});
validOptions = {'horizontal','vertical','both'};
options = parser.Results;
options.ROIOrientation = validatestring(options.ROIOrientation,validOptions, ...
    mfilename,'ROIOrientation');
end

function validatePercentResponse(percentResponse)
supportedClasses = images.internal.iptnumerictypes;
attributes = {'nonempty','nonsparse','real','nonnan','finite', 'integer', ...
    '<=',100,'positive','nonzero','vector'};
validateattributes(percentResponse,supportedClasses,attributes,mfilename, ...
    'percentResponse');
end

function validateROIIndex(ROIIndex)
supportedClasses = images.internal.iptnumerictypes;
attributes = {'nonempty','nonsparse','real','nonnan','finite','integer', ...
    '<=',60,'positive','nonzero','vector'};
validateattributes(ROIIndex,supportedClasses,attributes,mfilename, ...
    'ROIIndex');
end

function validateParentAxis(Parent)
validateattributes(Parent, {'matlab.graphics.axis.Axes'},{'nonempty','nonsparse'});
end

function validateROIOrientation(ROIOrientation)

supportedClasses = {'char','string'};
attributes = {'nonempty'};
validateattributes(ROIOrientation,supportedClasses,attributes,mfilename, ...
    'ROIOrientation');
end


function validateInputImage(A)
supportedClasses = {'uint8','uint16','single','double'};
attributes = {'nonempty','nonsparse','real','nonnan','finite'};

validateattributes(A,supportedClasses,attributes,...
    mfilename,'A',1);

validColorImage = (ndims(A) == 3) && (size(A,3) == 3);
if ~validColorImage
    error(message('images:esfrChart:invalidImageFormat','A'));
end

[row, col, ~] = size(A);
sizeFlag = (row >= 20) && (col >= 20);
if ~sizeFlag
    error(message('images:esfrChart:smallImageSize','A'));
end
end

function B = validateSensitivity(Sensitivity)

validateattributes(Sensitivity,{'single','double'},{'nonempty','real', ...
    'scalar','>=',0,'<=',1,'finite','nonsparse','nonnan'},...
    mfilename,'Sensitivity');

B = true;

end

function B = validateRegistrationPoints(RegistrationPoints)

validateattributes(RegistrationPoints,images.internal.iptnumerictypes,{'nonempty','real', ...
    'finite','nonsparse','nonnan', 'size', [4 2]},...
    mfilename,'RegistrationPoints');

B = true;

end

function validateChart(chart)
supportedClasses = {'esfrChart'};
attributes = {'nonempty','nonsparse','vector'};

validateattributes(chart,supportedClasses,attributes,...
    mfilename,'chart',1);
end

function validateGrayData(grayLabData)
supportedClasses = images.internal.iptnumerictypes;
attributes = {'nonempty','nonsparse','real','finite','size', [20 3]};

validateattributes(grayLabData,supportedClasses,attributes,...
    mfilename,'ReferenceGrayLab');

end

function validateColorData(colorLabData)
supportedClasses = images.internal.iptnumerictypes;
attributes = {'nonempty','nonsparse','real','finite','size', [16 3]};

validateattributes(colorLabData,supportedClasses,attributes,...
    mfilename,'ReferenceColorLab');

end

function validateDisplayFlag(flag)
supportedClasses = {'logical'};
attributes = {'nonempty','finite','nonsparse','scalar','nonnan'};
validateattributes(flag,supportedClasses,attributes,...
    mfilename);
end
