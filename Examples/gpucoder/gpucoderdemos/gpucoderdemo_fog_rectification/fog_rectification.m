function [out]=fog_rectification(input) %#codegen

%   Copyright 2017 The MathWorks, Inc.

coder.gpu.kernelfun;

% restoreOut is used to store the output of restoration
restoreOut = zeros(size(input),'double');

% Changing the precision level of input image to double
input = double(input)./255;

%% Dark channel Estimation from input
darkChannel = min(input,[],3);

% diff_im is used as input and output variable for anisotropic diffusion
diff_im = 0.9*darkChannel;
num_iter = 3;

% 2D convolution mask for Anisotropic diffusion
hN = [0.0625 0.1250 0.0625; 0.1250 0.2500 0.1250; 0.0625 0.1250 0.0625];
hN = double(hN);

%% Refine dark channel using Anisotropic diffusion.
for t = 1:num_iter
      diff_im = conv2(diff_im,hN,'same');
end

%% Reduction with min
diff_im = min(darkChannel,diff_im);

diff_im = 0.6*diff_im ;

%% Parallel element-wise math to compute
%  Restoration with inverse Koschmieder's law
factor=1.0./(1.0-(diff_im));
restoreOut(:,:,1)= (input(:,:,1)-diff_im).*factor; 
restoreOut(:,:,2)= (input(:,:,2)-diff_im).*factor; 
restoreOut(:,:,3)= (input(:,:,3)-diff_im).*factor; 
restoreOut=uint8(255.*restoreOut);
restoreOut=uint8(restoreOut);

%%%%%%% streching performs the histogram streching of the image %%%%%%%
%%%%%%%%% im is the input color image and p is cdf limit
%%%%%% out is the contrast streched image and cdf is the cumulative prob
%%%%%% density function and T is the streching function

 p=5;
 % rgbtograyconversion
 im_gray=rgb2gray(restoreOut);
 [row,col]=size(im_gray);
 
% histogram calculation
[count,~]=imhist(im_gray);
prob=count'/(row*col);

% cumulative Sum calculation
cdf=cumsum(prob(:));

% finding less than particular probability
i1=length(find(cdf<=(p/100)));
i2=255-length(find(cdf>=1-(p/100)));

o1=floor(255*.10);
o2=floor(255*.90);

t1=(o1/i1)*[0:i1];
t2=(((o2-o1)/(i2-i1))*[i1+1:i2])-(((o2-o1)/(i2-i1))*i1)+o1;
t3=(((255-o2)/(255-i2))*[i2+1:255])-(((255-o2)/(255-i2))*i2)+o2;

T=(floor([t1 t2 t3]));

restoreOut(restoreOut == 0) = 1;

u1=(restoreOut(:,:,1));
u2=(restoreOut(:,:,2));
u3=(restoreOut(:,:,3));

% Replacing the value from look up table
out1=T(u1);
out2=T(u2);
out3=T(u3);

out = zeros([size(out1),3], 'uint8');
out(:,:,1) = uint8(out1);
out(:,:,2) = uint8(out2);
out(:,:,3) = uint8(out3);
return
