function [out]  = imtophatDemo_gpu(img,Nhood) %#codegen
coder.gpu.kernelfun;
out = imtophat(img,Nhood);
end