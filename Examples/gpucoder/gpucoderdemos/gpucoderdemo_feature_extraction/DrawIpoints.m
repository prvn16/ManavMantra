function DrawIpoints(imageFile,interestPoints) %#codegen

%   Copyright 2017 The MathWorks, Inc.

fRound = @(value) int32(floor(value+single(0.5)));
img = imread(imageFile);
imshow(img);
hold on;

for i = 1:length(interestPoints)
    ipt = interestPoints(i);
    s = single(2.5) * ipt.scale;
    o = ipt.orientation;
    lap = ipt.laplacian;
    r1 = fRound(ipt.y);
    c1 = fRound(ipt.x);
    c2 = fRound(s * cos(o)) + c1;
    r2 = fRound(s * sin(o)) + r1;
    
    if (o) % Green line indicates orientation       
        plot([c1,c2],[r1,r2],'Color','g')
    end
    
    
    if lap == 1
        % Blue circles indicate dark blobs on light backgrounds
        viscircles([c1,r1],fRound(s),'Color','b','LineWidth',0.01,'EnhanceVisibility',false);
    else
        if lap == 0
            % Red circles indicate light blobs on dark backgrounds
            viscircles([c1,r1],fRound(s),'Color','r','LineWidth',0.01,'EnhanceVisibility',false);
        end
    end
    
end

end