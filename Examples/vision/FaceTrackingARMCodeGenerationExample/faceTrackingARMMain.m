function faceTrackingARMMain

% This function is intended to run on MATLAB host only.

% This function acquires video frame from a webcam, sends the frame to face
% tracking algorthm and finally displays the frame with bounding box around
% the face being tracked. This function uses webcam function from 'MATLAB
% Support Package for USB Webcams' and vision.DeployableVideoPlayer system
% object. Both these functions do not support code generation on ARM
% platform.

% For code generation on ARM, the workflow used in this function is
% mimicked in faceTrackingARMMain.c with some modifications. One
% difference is that- in this function the loop terminates when the video
% player window is closed, whereas in faceTrackingARMMain.c, the loop
% terminates if Escape button is pressed.

errorInCodegen();
persistent outVideoPlayer

if isempty(outVideoPlayer)
    outVideoPlayer = vision.DeployableVideoPlayer;
end

cam = webcam;
if isempty(cam)
    warning('No webcam found. You must have a webcam connected to your computer.');
    return;
end

cont = true;
while cont
    inRGB = snapshot(cam);
    outRGB = faceTrackingARMKernel(inRGB);
    step(outVideoPlayer, outRGB);
    cont = isOpen(outVideoPlayer);
end
release(outVideoPlayer);

function errorInCodegen

coder.internal.errorIf(~isempty(coder.target), ...
                       'vision:vision_utils:CodegenUnsupported');


