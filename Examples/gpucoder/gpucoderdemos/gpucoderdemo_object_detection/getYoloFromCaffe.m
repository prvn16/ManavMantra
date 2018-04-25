function network = getYoloFromCaffe

%   Copyright 2017 The MathWorks, Inc.

% Use Caffe Importer tool to create a Series network from trained caffe model
protofile = 'yolo_deploy.prototxt';
if exist('yolo.caffemodel','file') == 0
	url = 'https://www.mathworks.com/supportfiles/gpucoder/cnn_models/Yolo/yolo.caffemodel.zip';
	websave('yolo.caffemodel.zip', url);
	system('unzip yolo.caffemodel.zip');
 end 
network = importCaffeNetwork(protofile, 'yolo.caffemodel');


end
