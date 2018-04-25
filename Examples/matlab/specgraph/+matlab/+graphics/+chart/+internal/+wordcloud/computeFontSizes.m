function args = computeFontSizes(args,axesratio,rampSize,shape,power)
% This internal helper function may be removed in a future release.

% Copyright 2016-2017 The MathWorks, Inc.

args.weights = applyPower(double(args.weights), power);

refSize = getRefWeight(args.weights, rampSize);

% keep at most MaxNumWords entries
if length(args.weights) > args.MaxDisplayWords
    n = args.MaxDisplayWords + 1;
    args.weights(n:end) = [];
    args.words(n:end) = [];
end

args.fontsize = args.weights;

if ~isempty(args.weights)
    prefRange = getPrefFontRange(shape);
    args.fontsize = weightsToFontSize(args.weights,axesratio,refSize,prefRange);
end
end

function newWeights = weightsToFontSize(weights,axesratio,refSize,prefRange)

% heuristic algorithm to pick linear font size targets. Target values
% are font size in normalized units (which uses the axes height). Heuristic
% is based on the default axes aspect ratio.
max_font_size = prefRange(2);
min_font_size = prefRange(1);

max_w = weights(1); % assumes weights have been sorted already
min_w = refSize;
newWeights = scaleWeights(weights, min_w, max_w, min_font_size, max_font_size);

% The heuristics are based on the default axes aspect ratio. Now scale
% for non-standard aspect ratios, with a maximum cutoff to prevent
% text larger than the height.
defaultRatio = 0.7883;
scale = max(1,defaultRatio/axesratio);

maxFontSize = 0.99; % maximum font size in normalized units (rel to axes height)
if newWeights(1)*scale > maxFontSize
    scale = maxFontSize/newWeights(1);
end
newWeights = newWeights.*scale;
end

function newWeights = scaleWeights(weights, min_w, max_w, low, high)
if max_w == min_w
    newWeights = repmat(high, length(weights), 1);
else
    newWeights = (weights - min_w)/(max_w - min_w)*(high - low) + low;
end
newWeights = max(newWeights, 0.01); % avoid negative font sizes
end

function ref = getRefWeight(w,rampSize)
    n = length(w);
    if n == 0
        ref = 1;
    else
        n100 = min(rampSize,n);
        ref = w(n100);
    end
end

function prefRange = getPrefFontRange(shape)
% Adjust the minimum size based on the shape. Rectangle
% uses more of the area so it gets a larger minimum.
    if strcmp(shape,'oval')
        prefRange = [0.02 0.2];
    else
        prefRange = [0.03 0.2];
    end
end

function w = applyPower(w, power)
% compute w.^power with numeric checking 
    w = min(realmax, max(realmin,w.^ power));
end
