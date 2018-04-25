function generateColorSegmentationCode(hToolGroup)
    % generateColorSegmentationCode - Internal function used to generate
    % code for Color Thresholder app
    
    %   Copyright 2016 The MathWorks, Inc.

    codeGenerator = iptui.internal.CodeGenerator();

    addFunctionDeclaration(codeGenerator)
    codeGenerator.addReturn()
    codeGenerator.addHeader('colorThresholder')

    % If we normalized Double data, insert normalization into
    % generated code
    if isfloat(hToolGroup.imRGB) && (hToolGroup.massageNansInfs)
        codeGenerator.addComment('Replace nan values with 0');
        codeGenerator.addLine('RGB(isnan(RGB)) = 0;');

        codeGenerator.addComment('Replace inf values with 1');
        codeGenerator.addLine('RGB(RGB==Inf) = 1;');

        codeGenerator.addComment('Replace -inf values with 0');
        codeGenerator.addLine('RGB(RGB==-Inf) = 0;');
    end

    if isfloat(hToolGroup.imRGB) && (hToolGroup.normalizedDoubleData)
        codeGenerator.addComment('Normalize input data to range [0 1]');
        codeGenerator.addLine('RGB = mat2gray(RGB);');
    end

    % Convert image to current selected color space
    codeGenerator.addComment('Convert RGB image to chosen color space');
    codeGenerator.addLine(getColorspaceConversionString(hToolGroup));

    hRightPanel = findobj(hToolGroup.hFigCurrent,'tag','RightPanel');
    histHandles = getappdata(hRightPanel,'HistPanelHandles');

    % Define thresholds per channel
    codeGenerator.addComment('Define thresholds for channel 1 based on histogram settings');    
    hChanHist = histHandles{1};
    histLimits1 = hChanHist.currentSelection;
    codeGenerator.addLine(sprintf('channel1Min = %3.3f;',histLimits1(1)));
    codeGenerator.addLine(sprintf('channel1Max = %3.3f;',histLimits1(2)));

    codeGenerator.addComment('Define thresholds for channel 2 based on histogram settings');
    hChanHist = histHandles{2};
    histLimits2 = hChanHist.currentSelection;
    codeGenerator.addLine(sprintf('channel2Min = %3.3f;',histLimits2(1)));
    codeGenerator.addLine(sprintf('channel2Max = %3.3f;',histLimits2(2)));

    codeGenerator.addComment('Define thresholds for channel 3 based on histogram settings');
    hChanHist = histHandles{3};
    histLimits3 = hChanHist.currentSelection;
    codeGenerator.addLine(sprintf('channel3Min = %3.3f;',histLimits3(1)));
    codeGenerator.addLine(sprintf('channel3Max = %3.3f;',histLimits3(2)));

    codeGenerator.addComment('Create mask based on chosen histogram thresholds');         

    if strcmp(get(hToolGroup.hFigCurrent,'Tag'),'HSV') && (histLimits1(1) >= histLimits1(2))
        % Handle circular behavior of H channel in HSV as a special
        % case
        codeGenerator.addLine('sliderBW = ( (I(:,:,1) >= channel1Min) | (I(:,:,1) <= channel1Max) ) & ...');
    else
        % For every other colorspace and for HSV when H does not
        % span the discontinuity around red.
        codeGenerator.addLine('sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...');
    end
    codeGenerator.addLine('  (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...');
    codeGenerator.addLine('  (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);');

    if iptui.internal.hasValidROIs(hToolGroup.hFigCurrent,hToolGroup.hPolyROIs) && ~hToolGroup.hHidePointCloud.Value
        codeGenerator.addComment('Create mask based on selected regions of interest on point cloud projection');
        codeGenerator.addLine('I = double(I);');
        codeGenerator.addLine('[m,n,~] = size(I);');
        codeGenerator.addLine('polyBW = false([m,n]);');
        codeGenerator.addLine('I = reshape(I,[m*n 3]);');

        switch get(hToolGroup.hFigCurrent,'Tag')
            case 'HSV'
                codeGenerator.addComment('Convert HSV color space to canonical coordinates');
                codeGenerator.addLine('Xcoord = I(:,2).*I(:,3).*cos(2*pi*I(:,1));'); 
                codeGenerator.addLine('Ycoord = I(:,2).*I(:,3).*sin(2*pi*I(:,1));'); 
                codeGenerator.addLine('I(:,1) = Xcoord;'); 
                codeGenerator.addLine('I(:,2) = Ycoord;');
                codeGenerator.addLine('clear Xcoord Ycoord');
            case {'YCbCr','L*a*b*'}
                codeGenerator.addLine('temp = I(:,1);');
                codeGenerator.addLine('I(:,1) = I(:,2);');
                codeGenerator.addLine('I(:,2) = I(:,3);');
                codeGenerator.addLine('I(:,3) = temp;');
                codeGenerator.addLine('clear temp');
        end

        
        codeGenerator.addComment('Project 3D data into 2D projected view from current camera view point within app');
        codeGenerator.addLine('J = rotateColorSpace(I);');
        codeGenerator.addComment('Apply polygons drawn on point cloud in app');
        codeGenerator.addLine('polyBW = applyPolygons(J,polyBW);');
        
        codeGenerator.addComment('Combine both masks');
        codeGenerator.addLine('BW = sliderBW & polyBW;');
    else
        codeGenerator.addLine('BW = sliderBW;');
    end

    % Honor state of Invert Mask button by complementing mask if
    % necessary
    if hToolGroup.hInvertMaskButton.Value
        codeGenerator.addComment('Invert mask');
        codeGenerator.addLine('BW = ~BW;');
    end

    % Add code to form 2nd LHS argument containing masked RGB
    % image.
    codeGenerator.addComment('Initialize output masked image based on input image.');
    codeGenerator.addLine('maskedRGBImage = RGB;');
    codeGenerator.addComment('Set background pixels where BW is false to zero.');
    codeGenerator.addLine('maskedRGBImage(repmat(~BW,[1 1 3])) = 0;');
    codeGenerator.addReturn();
    codeGenerator.addLine('end');
    
    if iptui.internal.hasValidROIs(hToolGroup.hFigCurrent,hToolGroup.hPolyROIs) && ~hToolGroup.hHidePointCloud.Value
        tMat = getappdata(hRightPanel,'TransformationMat');
        shiftVec = getappdata(hRightPanel,'ShiftVector');
        codeGenerator.addReturn();
        codeGenerator.addLine('function J = rotateColorSpace(I)');
        codeGenerator.addComment('Translate the data to the mean of the current image within app');
        codeGenerator.addLine(sprintf('shiftVec = [%f %f %f];',shiftVec(1),shiftVec(2),shiftVec(3)));
        codeGenerator.addLine('I = I - shiftVec;');
        codeGenerator.addLine('I = [I ones(size(I,1),1)]'';');
        codeGenerator.addComment('Apply transformation matrix');
        codeGenerator.addLine(sprintf('tMat = [%f %f %f %f;',...
            tMat(1,1),tMat(1,2),tMat(1,3),tMat(1,4)));
        codeGenerator.addLine(sprintf(' %f %f %f %f;',...
            tMat(2,1),tMat(2,2),tMat(2,3),tMat(2,4)));
        codeGenerator.addLine(sprintf(' %f %f %f %f;',...
            tMat(3,1),tMat(3,2),tMat(3,3),tMat(3,4)));
        codeGenerator.addLine(sprintf(' %f %f %f %f];',...
            tMat(4,1),tMat(4,2),tMat(4,3),tMat(4,4)));
        codeGenerator.addReturn();
        codeGenerator.addLine('J = (tMat*I)'';');
        codeGenerator.addLine('end');
        codeGenerator.addReturn();
        
        codeGenerator.addLine('function polyBW = applyPolygons(J,polyBW)');
        % We need the manually entered points
        hROIs = iptui.internal.findROIs(hToolGroup.hFigCurrent,hToolGroup.hPolyROIs);

        inc = 1;

        for p = 1:numel(hROIs)
            if isvalid(hROIs(p))
                hPoints = hROIs(p).getPosition;
                codeGenerator.addComment('Define each manually generated ROI'); 
                codeGenerator.addLine(sprintf('hPoints(%d).data = [%f %f;',inc,hPoints(1,1),hPoints(1,2)));
                for ii = 2:size(hPoints,1)-1
                    codeGenerator.addLine(sprintf('	%f %f;',hPoints(ii,1),hPoints(ii,2)));
                end
                codeGenerator.addLine(sprintf('	%f %f];',hPoints(end,1),hPoints(end,2)));
                inc = inc + 1;
            end
        end

            codeGenerator.addComment('Iteratively apply each ROI');
            codeGenerator.addLine('for ii = 1:length(hPoints)');
            codeGenerator.addLine('    if size(hPoints(ii).data,1) > 2');
            codeGenerator.addLine('        in = inpolygon(J(:,1),J(:,2),hPoints(ii).data(:,1),hPoints(ii).data(:,2));');
            codeGenerator.addLine('        in = reshape(in,size(polyBW));');
            codeGenerator.addLine('        polyBW = polyBW | in;');
            codeGenerator.addLine('    end');
            codeGenerator.addLine('end');
            codeGenerator.addReturn();
            codeGenerator.addLine('end');
        
    end

    % Terminate the file with carriage return
    codeGenerator.addReturn();

    % Output the generated code to the MATLAB editor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    codeGenerator.putCodeInEditor();
    
end

%-------------------------------------------
function str = getColorspaceConversionString(hToolGroup)

   switch(get(hToolGroup.hFigCurrent,'Tag'))     
        case 'RGB'
            str = 'I = RGB;';
        case 'HSV'
            str = 'I = rgb2hsv(RGB);';
        case 'YCbCr'
            str = 'I = rgb2ycbcr(RGB);';
        case 'L*a*b*'
            str = 'I = rgb2lab(RGB);';
    end

end

function addFunctionDeclaration(generator)
    fcnName = 'createMask';
    inputs = {'RGB'};
    outputs = {'BW', 'maskedRGBImage'};

    h1Line = ' Threshold RGB image using auto-generated code from colorThresholder app.';

    description = ['thresholds image RGB using auto-generated code' ...
        ' from the colorThresholder app. The colorspace and' ...
        ' range for each channel of the colorspace were set within' ...
        ' the app. The segmentation mask is returned in BW, and a' ...
        ' composite of the mask and original RGB images is' ...
        ' returned in maskedRGBImage.'];

    generator.addFunctionDeclaration(fcnName,inputs,outputs,h1Line);
    generator.addSyntaxHelp(fcnName,description,inputs,outputs);
end