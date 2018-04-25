function responseMap = FastHessian(intImage)  %#codegen

%   Copyright 2017 The MathWorks, Inc.
%
% This function constructs the scale-space by convolving the integral
% image with box filter approximations of various sizes. The following
% constants are used:
%
% Number of Octaves: 5
% Number of Intervals: 4
% Initial Step Size: 2
% Threshold: 0.0004
% Filter Sizes: Octave 1 -  9,  15,  21,  27
%               Octave 2 - 15,  27,  39,  51
%               Octave 3 - 27,  51,  75,  99
%               Octave 4 - 51,  99, 147, 195
%               Octave 5 - 99, 195, 291, 387

% Image dimensions
imgDim   = size(intImage);
i_height = imgDim(1);
i_width  = imgDim(2);

% Initialize response map for various octaves and intervals
init_sample = 2;
w           = floor(i_width/init_sample);
h           = floor(i_height/init_sample);
s           = init_sample;

responseMap =  coder.nullcopy([
    struct('width',w          ,'height',h          ,'step',s   ,'filter',9  ,'responses',zeros(h,w                    ,'single'),'laplacian',zeros(h,w                    ,'uint8')) ...
    struct('width',w          ,'height',h          ,'step',s   ,'filter',15 ,'responses',zeros(h,w                    ,'single'),'laplacian',zeros(h,w                    ,'uint8')) ...
    struct('width',w          ,'height',h          ,'step',s   ,'filter',21 ,'responses',zeros(h,w                    ,'single'),'laplacian',zeros(h,w                    ,'uint8')) ...
    struct('width',w          ,'height',h          ,'step',s   ,'filter',27 ,'responses',zeros(h,w                    ,'single'),'laplacian',zeros(h,w                    ,'uint8')) ...
    struct('width',floor(w/2) ,'height',floor(h/2) ,'step',s*2 ,'filter',39 ,'responses',zeros(floor(h/2),floor(w/2)  ,'single'),'laplacian',zeros(floor(h/2),floor(w/2)  ,'uint8')) ...
    struct('width',floor(w/2) ,'height',floor(h/2) ,'step',s*2 ,'filter',51 ,'responses',zeros(floor(h/2),floor(w/2)  ,'single'),'laplacian',zeros(floor(h/2),floor(w/2)  ,'uint8')) ...
    struct('width',floor(w/4) ,'height',floor(h/4) ,'step',s*4 ,'filter',75 ,'responses',zeros(floor(h/4),floor(w/4)  ,'single'),'laplacian',zeros(floor(h/4),floor(w/4)  ,'uint8')) ...
    struct('width',floor(w/4) ,'height',floor(h/4) ,'step',s*4 ,'filter',99 ,'responses',zeros(floor(h/4),floor(w/4)  ,'single'),'laplacian',zeros(floor(h/4),floor(w/4)  ,'uint8')) ...
    struct('width',floor(w/8) ,'height',floor(h/8) ,'step',s*8 ,'filter',147,'responses',zeros(floor(h/8),floor(w/8)  ,'single'),'laplacian',zeros(floor(h/8),floor(w/8)  ,'uint8')) ...
    struct('width',floor(w/8) ,'height',floor(h/8) ,'step',s*8 ,'filter',195,'responses',zeros(floor(h/8),floor(w/8)  ,'single'),'laplacian',zeros(floor(h/8),floor(w/8)  ,'uint8')) ...
    struct('width',floor(w/16),'height',floor(h/16),'step',s*16,'filter',291,'responses',zeros(floor(h/16),floor(w/16),'single'),'laplacian',zeros(floor(h/16),floor(w/16),'uint8')) ...
    struct('width',floor(w/16),'height',floor(h/16),'step',s*16,'filter',387,'responses',zeros(floor(h/16),floor(w/16),'single'),'laplacian',zeros(floor(h/16),floor(w/16),'uint8')) ]);

responseMap(1).width=w;           responseMap(1).height=h         ;responseMap(1).step=s   ;responseMap(1).filter=9;
responseMap(2).width=w          ;responseMap(2).height=h          ;responseMap(2).step=s   ;responseMap(2).filter=15;
responseMap(3).width=w          ;responseMap(3).height=h          ;responseMap(3).step=s   ;responseMap(3).filter=21;
responseMap(4).width=w          ;responseMap(4).height=h          ;responseMap(4).step=s   ;responseMap(4).filter=27;
responseMap(5).width=floor(w/2) ;responseMap(5).height=floor(h/2) ;responseMap(5).step=s*2 ;responseMap(5).filter=39;
responseMap(6).width=floor(w/2) ;responseMap(6).height=floor(h/2) ;responseMap(6).step=s*2 ;responseMap(6).filter=51;
responseMap(7).width=floor(w/4) ;responseMap(7).height=floor(h/4) ;responseMap(7).step=s*4 ;responseMap(7).filter=75;
responseMap(8).width=floor(w/4) ;responseMap(8).height=floor(h/4) ;responseMap(8).step=s*4 ;responseMap(8).filter=99;
responseMap(9).width=floor(w/8) ;responseMap(9).height=floor(h/8) ;responseMap(9).step=s*8 ;responseMap(9).filter=147;
responseMap(10).width=floor(w/8) ;responseMap(10).height=floor(h/8) ;responseMap(10).step=s*8 ;responseMap(10).filter=195;
responseMap(11).width=floor(w/16);responseMap(11).height=floor(h/16);responseMap(11).step=s*16;responseMap(11).filter=291;
responseMap(12).width=floor(w/16);responseMap(12).height=floor(h/16);responseMap(12).step=s*16;responseMap(12).filter=387;

heightArray = [h floor(h/2) floor(h/4) floor(h/8) floor(h/16)];
 widthArray = [w floor(w/2) floor(w/4) floor(w/8) floor(w/16)];

% Compute box filter convolution for 12 unique filter sizes
for i = coder.unroll(1:12)
    
    switch i
        case {1,2,3,4}
            index = 1;
        case {5,6}
            index = 2;
        case {7,8}
            index = 3;
        case {9,10}
            index = 4;
        otherwise
            index = 5;
    end
    
    height = heightArray(index);
    width  = widthArray(index);
    filter = responseMap(i).filter;
    step   = responseMap(i).step;
    
    [respMatrix, lapMatrix] = FastHessianCalc(intImage, height, width, step, filter);
    
    responseMap(i).responses = respMatrix;
    responseMap(i).laplacian = lapMatrix;
    
end

end



