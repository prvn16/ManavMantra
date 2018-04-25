function [bigImage, cmap] = createMontage(imgSrc, thumbnailSize, montageSize, borderSize, backgroundColor, indices, cmap)

%   Copyright 1993-2017 The MathWorks, Inc.

if isempty(imgSrc)
    bigImage = [];
    cmap = [];
    return
end


if isempty(indices)
    if isa(imgSrc, 'matlab.io.datastore.ImageDatastore')
        nFrames = numel(imgSrc.Files);
    elseif iscell(imgSrc) || isstring(imgSrc)
        nFrames = numel(imgSrc);
    else
        if ndims(imgSrc)==4 %MxNx{1/3}xP
            nFrames = size(imgSrc, 4);
        else% MxNxP
            nFrames = size(imgSrc, 3);
        end
    end
else
    nFrames = numel(indices);
end

%% Auto thumbnail size computation (including parital montageSize computation)
if numel(montageSize)==2 && (sum(isnan(montageSize))==1)
    % Only one nan specified, resolve it
    nanIdx = isnan(montageSize);
    montageSize(nanIdx) = ceil(nFrames / montageSize(~nanIdx));
end

if isequal(thumbnailSize,"auto")
    if ~isempty(montageSize) && ~all(isnan(montageSize))
        % montageSize fully resolved
        [maxNumThumbsAlongAnyDim, dim] = max(montageSize);
    else
        % Assume square montage layout. A more accurate montageSize based
        % on thumbnail aspect ratio is computed later
        maxNumThumbsAlongAnyDim = ceil(sqrt(nFrames));
        dim = 1;
    end
    
    % Max screen size along any dimension (any monitor)
    monitorPositions = get(0,'MonitorPositions');
    monitorSizes = monitorPositions(:,3:4);
    monitorSizes = fliplr(monitorSizes); % height, width
    maxScreenDim = max(monitorSizes(:, dim));
    
    % Min required thumbnail size so no downsizing needs to happen when
    % figure is maximized
    minThumbnailDim = maxScreenDim/maxNumThumbsAlongAnyDim;
    minThumbnailDim = min(max(minThumbnailDim, 20), 1000); % sane limits
    thumbnailSize = [NaN NaN];
    thumbnailSize(dim) = ceil(minThumbnailDim);
end


%% Read images
if iscell(imgSrc) || isstring(imgSrc) || ...
        isa(imgSrc,'matlab.io.datastore.ImageDatastore')
    %MONTAGE(FILENAMES/IMDS/{variables},..)
    imageArray = getImages(imgSrc, thumbnailSize, borderSize, backgroundColor, indices, cmap);
else
    %MONTAGE(I,...) or MONTAGE(X,MAP,...)
    imageArray = imgSrc;
    
    if ndims(imageArray)==3
        % Convert MxNxP to MxNx1xP so rest of the code can fall through
        imageArray = reshape(imageArray,...
            [size(imageArray,1), size(imageArray,2), 1, size(imageArray,3)]);
    end
    
    % Validate cmap
    if isa(imageArray,'int16') && ~isempty(cmap)
        error(message('images:montage:invalidIndexedImage', 'double, single, or logical.'));
    end
    validateattributes(cmap,{'double'},{},'montage','MAP',1);
    
    % Indices
    if ~isempty(indices)
        imageArray = imageArray(:,:,:,indices);
    end       
    
    % Resize
    for pInd = 1:size(imageArray,4)
        % Resize each slice
        slice = imageArray(:,:,:,pInd);
        if ~isempty(cmap) && size(imageArray,3)==1
            % Conver to RGB with supplied colormap
            slice = ind2rgb(slice, cmap);
        end
        slice = resizeToThumbnail(slice, thumbnailSize, borderSize, backgroundColor);
        Ir(:,:,:,pInd) = slice; %#ok<AGROW>
    end
    imageArray = Ir;
    
end


%% More accurate montage size computation is non specified (or [nan nan])
nRows   = size(imageArray,1);
nCols   = size(imageArray,2);

if isempty(montageSize) || all(isnan(montageSize))
    %Calculate montageSize for the user
    % Estimate nMontageColumns and nMontageRows given the desired
    % ratio of Columns to Rows to be one (square montage).
    aspectRatio = 1;
    montageCols = sqrt(aspectRatio * nRows * nFrames / nCols);
    
    % Make sure montage rows and columns are integers. The order in
    % the adjustment matters because the montage image is created
    % horizontally across columns.
    montageCols = ceil(montageCols);
    montageRows = ceil(nFrames / montageCols);
    montageSize = [montageRows montageCols];
elseif prod(montageSize) < nFrames
    error(message('images:montage:sizeTooSmall'));
end

%% Stitch images
nMontageRows = montageSize(1);
nMontageCols = montageSize(2);
nBands = size(imageArray, 3);

sizeOfBigImage = [nMontageRows*nRows nMontageCols*nCols nBands];

if isempty(backgroundColor)
    % default is black
    if islogical(imageArray)
        bigImage = false(sizeOfBigImage);
    else
        bigImage = zeros(sizeOfBigImage,'like',imageArray);
    end
else
    if isa(imageArray,'double')
        backgroundColor = im2double(backgroundColor);
    end
    bigImage = repmat(backgroundColor, sizeOfBigImage(1:2));
end

rows = 1 : nRows;
cols = 1 : nCols;
k = 1;
for i = 0 : nMontageRows-1
    for j = 0 : nMontageCols-1
        if k>nFrames
            break;
        end
        bigImage(rows + i * nRows, cols + j * nCols, :) = ...
            imageArray(:,:,:,k);
        k = k + 1;
    end
end

end


function I = getImages(imgSource, thumbnailSize, borderSize, backgroundColor, idxs, cmap)

if isempty(imgSource)
    error(message('images:montage:invalidType'))
end

% Number of frames
if iscell(imgSource) || isstring(imgSource)
    nframes = numel(imgSource);
elseif isa(imgSource,'matlab.io.datastore.ImageDatastore')
    nframes = numel(imgSource.Files);
else
    validateattributes(imgSource, ...
        {'uint8' 'double' 'uint16' 'logical' 'single' 'int16'}, {}, ...
        mfilename, 'I, BW, or RGB', 1);
    nframes = size(imgSource,4);
end

if isa(imgSource,'matlab.io.datastore.ImageDatastore')
    % Create a copy and reset the local copy.
    imgSource = imgSource.copy();
    imgSource.reset();
end

if isempty(idxs)
    useIndexedRead = false;
    idxs = 1:nframes;
else
    useIndexedRead = true;
end

% Read first image, thumbnailSize may be empty or contain a NaN
img = getOneImage(imgSource,useIndexedRead, idxs(1), cmap);
nanDim = isnan(thumbnailSize);
img = resizeToThumbnail(img, thumbnailSize, borderSize, backgroundColor, nanDim);

% This is the explicit thumbnail size for the rest 
thumbnailSize = [size(img,1), size(img,2)];
thumbnailSize = thumbnailSize - 2*borderSize;

if islogical(img)
    % Show BW as uint8
    img = im2uint8(img);
end

% Initialize output
class1stImg = class(img);
size1stImg  = size(img);
sizeImageArray = [size1stImg(1) size1stImg(2) size(img,3) nframes];
if islogical(img)
    I = false(sizeImageArray);
else
    I = zeros(sizeImageArray, class1stImg);
end

I(:,:,:,1) = img;
montageIsCurrentlyGray = size(img,3)==1;

% setup wait bar mechanics
displayWaitbar = true;
wait_bar = [];
cleanup_waitbar = [];

update_increments = 1:numel(idxs);
update_counter = 1;

% inner loop starts
start_tic = tic;


for k = 2 : numel(idxs)
    img = getOneImage(imgSource,useIndexedRead, idxs(k), cmap);
    img = resizeToThumbnail(img, thumbnailSize, borderSize, backgroundColor, nanDim);
    
    if ~isa(img, class(I))
        % class mismatch, always upconvert to double
        if ~isa(I, 'double')
            I = im2double(I);
        end
        img = im2double(img);
    end
    
    if montageIsCurrentlyGray && size(img,3)==3
        % Convert to RGB, replicate gray scale image into 3 planes
        I = repmat(I, [ 1 1 3 1]);
        montageIsCurrentlyGray = false;
    end
    
    if ~montageIsCurrentlyGray && size(img,3)==1
        I(:,:,:,k) = repmat(img,[1 1 3]);
    else
        I(:,:,:,k) = img;
    end
    
    if updateWaitbar(k)
        % Cancelled, fall through and show empties for the rest
        break;
    end
end

    function abort = updateWaitbar(k)
        abort = false;
        
        if(displayWaitbar == false)
            return;
        end
        
        % only update for specific values of k, updates are expensive
        if k >= update_increments(update_counter)
            update_counter = update_counter + 1;
            
            % keep a running total of how long we've taken
            elapsed_time = toc(start_tic);
            
            if isempty(wait_bar)
                % decide if we need a wait bar or not
                remaining_time = elapsed_time / k * (numel(idxs) - k);
                if elapsed_time > 7 && remaining_time > 1
                    total_blocks = numel(idxs);
                    wait_bar = iptui.cancellableWaitbar(...
                        getString(message('images:montage:waitBarTitle')),...
                        getString(message('images:montage:waitBarProcessing', '%d')),...
                        total_blocks,k);
                    cleanup_waitbar = onCleanup(@() destroy(wait_bar)); %#ok<SETNU>
                end
                
            elseif wait_bar.isCancelled()
                % we had a waitbar, but the user hit the cancel button
                abort = true;
            else
                % we have a waitbar and it has not been canceled
                wait_bar.update(k);
                drawnow;                
            end
        end
        
    end % updateWaitbar

end


function I = getOneImage(imgSource,useIndexedRead, k, cmap)

map = [];
if isstring(imgSource)
    [I, map] = images.internal.getImageFromFile(imgSource(k).char);
elseif isa(imgSource,'matlab.io.datastore.ImageDatastore')
    if useIndexedRead
        I = imgSource.readimage(k);
    else
        % Default indices, read in order all the image one by one, this is
        % more efficient in some cases than readimage
        I = imgSource.read();
    end
elseif isempty(imgSource{k}) || (isstring(imgSource{k}) && imgSource{k}.strlength==0)
    % Use blanks
    I = 0;
elseif isnumeric(imgSource{k})||islogical(imgSource{k})
    I = imgSource{k};
else
    [I, map] = images.internal.getImageFromFile(imgSource{k});
end

% Validate size. I should be MxN or MxNx3
if (ndims(I)==3 && size(I,3)~=3) || ndims(I)>3
    error(message('MATLAB:images:imageDisplayValidateParams:unsupportedDimension'));
end

% Valdiate type
validateattributes(I, ...
    {'uint8' 'double' 'uint16' 'logical' 'single' 'int16'}, {}, ...
    mfilename);

if ~isempty(map) % indexed image
    if ~isempty(cmap)
        % cmap specified in command line, override
        map = cmap;
    end
    I = ind2rgb(I, map);
end
end


function I = resizeToThumbnail(I, thumbnailSize, borderSize, backgroundColor, nanDim)

if nargin<5
    nanDim = [];
end

if isempty(thumbnailSize)
   thumbnailSize = [size(I,1), size(I,2)];
else    
    if any(isnan(thumbnailSize))
        I = imresize(I, thumbnailSize);
    else
        if isempty(nanDim) || all(nanDim==0)
            % Resize the larger dim first
            if(size(I,1)>size(I,2))
                I = imresize(I, [thumbnailSize(1), NaN]);
            else
                I = imresize(I, [NaN, thumbnailSize(2)]);
            end
        else
            % Use NaN in the same dimension as was originally specified, even
            % though this time around we have a non-nan input thumbnailSize
            ts = thumbnailSize;
            ts(nanDim)= NaN;
            I = imresize(I, ts);
        end
        
        % Handle images which are larger than thumbnailSize after first resize
        if size(I,1)>thumbnailSize(1)
            I = imresize(I, [thumbnailSize(1), NaN]);
        end
        if size(I,2)>thumbnailSize(2)
            I = imresize(I, [NaN, thumbnailSize(2)]);
        end
    end
end

% Center thumbnail in a bed of background color
padSize = thumbnailSize-[size(I,1), size(I,2)];
prePad = max(floor(padSize/2),0);
pstPad = max(padSize-prePad,0);
prePad = prePad + borderSize;
pstPad = pstPad + borderSize;

if isempty(backgroundColor)
    % black
    backgroundColor = uint8([0 0 0]);
else
    % HAS to be RGB, uint8
    I = im2uint8(I);
    if size(I,3) == 1
        I = repmat(I, [1 1 3]);
    end
end

if any(prePad)
    if size(I,3)==1
        % Default background color is black (0)
        I = padarray(I, prePad, 0, 'pre');
    else
        r = padarray(I(:,:,1), prePad, backgroundColor(1), 'pre');
        g = padarray(I(:,:,2), prePad, backgroundColor(2), 'pre');
        b = padarray(I(:,:,3), prePad, backgroundColor(3), 'pre');
        I = cat(3, r, g, b);
    end
end

if any(pstPad)
    if size(I,3)==1
        % Default background color is black (0)
        I = padarray(I, pstPad, 0, 'post');
    else
        r = padarray(I(:,:,1), pstPad, backgroundColor(1), 'post');
        g = padarray(I(:,:,2), pstPad, backgroundColor(2), 'post');
        b = padarray(I(:,:,3), pstPad, backgroundColor(3), 'post');
        I = cat(3, r, g, b);
    end
end

end
