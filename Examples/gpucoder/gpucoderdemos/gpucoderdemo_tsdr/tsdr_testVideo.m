function tsdr_testVideo

%   Copyright 2017 The MathWorks, Inc.

% Input video
v = VideoReader('stop.avi');


%% Integrated codegeneration for Traffic Sign Detection and Recognition

% Generate MEX
cfg = coder.config('mex');
cfg.GpuConfig = coder.gpu.config;
cfg.GpuConfig.Enabled = true;

cfg.GenerateReport = false;
cfg.TargetLang = 'C++';

% Create a GPU Configuration object for MEX target setting target language to C++. 
% Run the |codegen| command specifying an input of input video frame size. 
% This corresponds to the input image size of tsdr_predict function.
codegen -config cfg tsdr_predict -args {ones(480,704,3  ,'uint8')}  


fps = 0;


while hasFrame(v)
    % Take a frame
    picture = readFrame(v);
    picture = imresize(picture,[480,704]);
    % Call MEX function for Traffic Sign Detection and Recognition
    tic;
    [bboxes,clases] = tsdr_predict_mex(picture);
    newt = toc;
    
    % fps
    fps = .9*fps + .1*(1/newt);
    
    % display
   
        diplayDetections(picture,bboxes,clases,fps);
end


end


function diplayDetections(im,boundingBoxes,classIndices,fps)

% Function for inserting the detected bounding boxes and recognized classes
% and displaying the result
%
% Inputs :
%
% im            : Input test image
% boundingBoxes : Detected bounding boxes
% classIndices  : Corresponding classes
%



% Traffic Signs (35)
classNames = {'addedLane','slow','dip','speedLimit25','speedLimit35','speedLimit40','speedLimit45',...
    'speedLimit50','speedLimit55','speedLimit65','speedLimitUrdbl','doNotPass','intersection',...
    'keepRight','laneEnds','merge','noLeftTurn','noRightTurn','stop','pedestrianCrossing',...
    'stopAhead','rampSpeedAdvisory20','rampSpeedAdvisory45','truckSpeedLimit55',...
    'rampSpeedAdvisory50','turnLeft','rampSpeedAdvisoryUrdbl','turnRight','rightLaneMustTurn',...
    'yield','yieldAhead','school','schoolSpeedLimit25','zoneAhead45','signalAhead'};

outputImage = insertShape(im,'Rectangle',boundingBoxes,'LineWidth',3);

for i = 1:size(boundingBoxes,1)
    
     ymin = boundingBoxes(i,2);xmin=boundingBoxes(i,1);xmax=xmin+boundingBoxes(i,3);
    
    % inserting class as text at YOLO detection
    classRec = classNames{classIndices(i)};
    outputImage = insertText(outputImage,[xmax ymin-20],classRec,'FontSize',20,'TextColor','red');
    
end
outputImage = insertText(outputImage,round(([size(outputImage,1) 40]/2)-20),['Frame Rate: ',num2str(fps)],'FontSize',20,'TextColor','red');
imshow(outputImage);
end
