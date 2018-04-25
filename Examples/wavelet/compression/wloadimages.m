function [X,map,imgFormat] = wloadimages(inputFile,optCONVERT)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Feb-2008.
%   Last Revision: 21-Jul-2012.
%   Copyright 1995-2012 The MathWorks, Inc.

if nargin<2 , optCONVERT = ''; end

[~,ext] = strtok(inputFile,'.');
if ~isempty(ext) , ext = ext(2:end); end
try
    varInFile = whos('-file',inputFile);
    sizes = cat(1,varInFile(:).size);
    minSiz = min(sizes,[],2);
    idxMin = find(minSiz==1);
    nbMin  = length(idxMin);
    if nbMin>0
        sizes(idxMin,:) = zeros(nbMin,2);
    end
    minSiz = prod(sizes,2);
    [tmp,idx] = max(minSiz);
    if tmp>0
        varName = varInFile(idx).name;
        S = load(inputFile);
        fn = fieldnames(S);
        X = S.(varName);
    else
        error(message('Wavelet:FunctionInput:FileVal'));
    end
    idx = find(strcmp(fn,'map'));
    if ~isempty(idx)
        map = S.(fn{idx});
    else
        map = pink(max(X(:)));
    end
    colorType = 'mat';
    imgFormat = 'mat';
    
catch %#ok<*CTCH>
    try
        switch ext
            case {'bmp','hdf','jpg','jpeg','pcx','tif','tiff','gif'}
                info = imfinfo(inputFile,ext);
            otherwise
                info = imfinfo(inputFile);
        end
        imgFormat = info.Format;
        colorType = lower(info.ColorType);
        [X,map]   = imread(inputFile,ext);
        
    catch
        X = wtcmngr('read',inputFile);
        imgFormat = 'wtc';
        colorType = 'mat';
        maxi = double(max(X(:)));
        map = pink(maxi);
    end
end

if isempty(optCONVERT) , return; end
[X,map,err] = convertImage(optCONVERT,X,colorType,map); %#ok<NASGU>


%--------------------------------------------------------------------------
function [X,map,err] = convertImage(optCONVERT,X,colorType,map)


err = 0;
conv2BW = isequal(optCONVERT,'BW');
switch optCONVERT
    case 'BW'
        if (length(size(X))<3)
            X = double(X);
            map = jet(max(X(:)));
            return;
        end

    case 'COL'
end

if conv2BW
    try
        X = double(round(0.299*X(:,:,1) + 0.587*X(:,:,2) + 0.114*X(:,:,3)));
    catch
        switch colorType
            case {'indexed','grayscale','mat'}
            otherwise , err = 1;
        end        
    end
    if isempty(map) , map = pink(max(X(:))); end
else
    % The grayscale images are converted in true color images.
    if length(size(X))<3
        if min(X(:))<1
            % The following line was suppressed the 21 Jul 2012
            % X = X + 1;
            maxX = max(X(:));
            nbCOL = size(map,1);
            if nbCOL<maxX
                map = [map ; map(nbCOL*ones(1,maxX-nbCOL),:)];
            end
        end
        IMAP = 256*map;
        Z = cell(1,3);
        for k = 1:3
            tmp = zeros(size(X));
            tmp(:) = IMAP(X(:),k);
            Z{k} = tmp;
        end
        X = uint8(cat(3,Z{:}));
    else
        X = uint8(X);
    end
end
%--------------------------------------------------------------------------
