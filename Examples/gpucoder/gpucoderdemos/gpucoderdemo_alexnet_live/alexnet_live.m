% Copyright 2017 The MathWorks, Inc.

function alexnet_live

% Connect to a camera
camera = webcam; 

% Prepare synset words for mapping classification output.
% The labels with top 5 prediction scores are 
% mapped to corresponding words in the synset dictionary.
fid = fopen('synsetWords.txt');
synsetOut = textscan(fid,'%s', 'delimiter', '\n');
synsetOut = synsetOut{1};
fclose(fid);

imfull = zeros(227,400,3, 'uint8');

fps = 0;

ax = axes;

while true
    % Take a picture
    ipicture = camera.snapshot;       
    
    % Resize and cast the picture to single        
    picture = imresize(ipicture,[227,227]);  
    
    % Call MEX function for alexnet prediction
    tic;    
    pout = alexnet_predict(single(picture));
    newt = toc;
       
    % fps 
    fps = .9*fps + .1*(1/newt);
    
    % top 5 scores
    [top5labels, scores] = getTopFive(pout, synsetOut);
    
    % display
    if isvalid(ax)
        dispResults(ax, imfull, picture, top5labels, scores, fps);   
    else
        break;
    end
end

end

function dispResults(ax, imfull, picture, top5labels, scores, fps)
for k = 1:3
    imfull(:,174:end,k) = picture(:,:,k);
end

h = imshow(imfull, 'InitialMagnification',200, 'Parent', ax);
scol = 1;
srow = 20;
text(get(h, 'Parent'), scol, srow, sprintf('Alexnet Demo'), 'color', 'w', 'FontSize', 20);
srow = srow + 20;

text(get(h, 'Parent'), scol, srow, sprintf('Fps = %2.2f', fps), 'color', 'w', 'FontSize', 15);
srow = srow + 20;
for k = 1:5
    t = text(get(h, 'Parent'), scol, srow, top5labels{k}, 'color', 'w','FontSize', 15);
    pos = get(t, 'Extent');
    text(get(h, 'Parent'), pos(1)+pos(3)+5, srow, sprintf('%2.2f%%', scores(k)), 'color', 'w', 'FontSize', 15);
    srow = srow + 20;
end

drawnow;
end

function [labels, scores] = getTopFive(predictOut, synsetOut)
[val,indx] = sort(predictOut, 'descend');
scores = val(1:5)*100;
labels = synsetOut(indx(1:5));
end

% LocalWords:  synset
