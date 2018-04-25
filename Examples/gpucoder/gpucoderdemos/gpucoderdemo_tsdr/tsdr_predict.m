function [selectedBbox,idx] = tsdr_predict(img)
%#codegen

% This function detects the traffic signs in the image using Detection Network
% (modified version of Yolo) and recognizes(classifies) using Recognition Network
%
% Inputs :
%
% im            : Input test image
%
% Outputs :
%
% selectedBbox  : Detected bounding boxes 
% idx           : Corresponding classes

% Copyright 2017 The MathWorks, Inc.

coder.gpu.kernelfun;

% resize the image
img_rz = imresize(img,[448,448]);

% Converting into BGR format
img_rz = img_rz(:,:,3:-1:1);
img_rz = im2single(img_rz);

%% TSD
persistent detectionnet;
if isempty(detectionnet)   
    detectionnet = coder.loadDeepLearningNetwork('yolo_tsr.mat','Detection');
end

predictions = detectionnet.activations(img_rz,56,'OutputAs','channels');


%% Convert predictions to bounding box attributes
classes = 1;
num = 2;
side = 7;
thresh = 0.2;
[h,w,~] = size(img);


boxes = single(zeros(0,4));    
probs = single(zeros(0,1));    
for i = 0:(side*side)-1
    for n = 0:num-1
        p_index = side*side*classes + i*num + n + 1;
        scale = predictions(p_index);       
        prob = zeros(1,classes+1);
        for j = 0:classes
            class_index = i*classes + 1;
            tempProb = scale*predictions(class_index+j);
            if tempProb > thresh
                
                row = floor(i / side);
                col = mod(i,side);
                
                box_index = side*side*(classes + num) + (i*num + n)*4 + 1;
                bxX = (predictions(box_index + 0) + col) / side;
                bxY = (predictions(box_index + 1) + row) / side;
                
                bxW = (predictions(box_index + 2)^2);
                bxH = (predictions(box_index + 3)^2);
                
                prob(j+1) = tempProb;
                probs = [probs;tempProb];
                                
                boxX = (bxX-bxW/2)*w+1;
                boxY = (bxY-bxH/2)*h+1;
                boxW = bxW*w;
                boxH = bxH*h;
                boxes = [boxes; boxX,boxY,boxW,boxH];
            end
        end
    end
end

%% Run Non-Maximal Suppression on the detected bounding boxess
coder.varsize('selectedBbox',[98, 4],[1 0]);
[selectedBbox,~] = selectStrongestBbox(round(boxes),probs);

%% Recognition

persistent recognitionnet;
if isempty(recognitionnet) 
    recognitionnet = coder.loadDeepLearningNetwork('RecognitionNet.mat','Recognition');
end

idx = zeros(size(selectedBbox,1),1);
inpImg = coder.nullcopy(zeros(48,48,3,size(selectedBbox,1)));
for i = 1:size(selectedBbox,1)
    
    ymin = selectedBbox(i,2);
    ymax = ymin+selectedBbox(i,4);
    xmin = selectedBbox(i,1);
    xmax = xmin+selectedBbox(i,3);

    
    % Resize Image
    inpImg(:,:,:,i) = imresize(img(ymin:ymax,xmin:xmax,:),[48,48]);
end

for i = 1:size(selectedBbox,1)
    output = recognitionnet.predict(inpImg(:,:,:,i));
    [~,idx(i)]=max(output);
end