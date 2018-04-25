function net = getSegNet

% return a trained DAG network object for SegNet

pretrainedURL = 'https://www.mathworks.com/supportfiles/vision/data/segnetVGG16CamVid.mat';
pretrainedSegNet = 'segnetVGG16CamVid.mat';
[status,errmsg] = license('checkout','video_and_image_blockset');
if ~status
    error(errmsg);  
end
if ~exist(pretrainedSegNet,'file')
    disp('Downloading pretrained SegNet (107 MB)...');
    websave(pretrainedSegNet,pretrainedURL);
end
segnet = load(pretrainedSegNet,'net');
net = segnet.net;
save('SegNet.mat','net');

end