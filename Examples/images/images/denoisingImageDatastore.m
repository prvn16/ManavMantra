%denoisingImageDatastore   Denoising image datastore
%
%   A denoisingImageDatastore object encapsulates a datastore which
%   creates batches of noisy image patches and corresponding noise patches
%   to be fed to a denoising deep neural network for training.
%
%   denoisingImageDatastore properties:
%       PatchesPerImage         - Number of random patches to be extracted per image
%       PatchSize               - Size of the image patches
%       GaussianNoiseLevel      - Standard deviation of Gaussian noise
%       ChannelFormat           - Channel format of output noisy patches
%       MiniBatchSize           - Number of patches returned in each read
%       NumObservations         - Total number of patches in an epoch
%       DispatchInBackground    - Whether background dispatch is used
%
%   denoisingImageDatastore methods:
%       denoisingImageDatastore - Construct a denoisingImageDatastore
%       hasdata                 - Returns true if there is more data in the datastore
%       partitionByIndex        - Partitions a denoisingImageDatastore given indices
%       preview                 - Reads the first image from the datastore
%       read                    - Reads a MiniBatch of data from the datastore
%       readall                 - Reads all observations from the datastore
%       readByIndex             - Random access read from datastore given indices
%       reset                   - Resets datastore to the start of the data
%       shuffle                 - Shuffles the observations in the datastore
%
%   Example - Train a network using denoisingImageDatastore
%   -------
%
%   imds = imageDatastore(pathToGrayscaleNaturalImageData);
%
%   ds = denoisingImageDatastore(imds,...
%       'PatchesPerImage', 512,...
%       'PatchSize', 50,...
%       'GaussianNoiseLevel', [0.01 0.1],...
%       'ChannelFormat', 'grayscale');
%
%   layers = dnCNNLayers();
%
%   opts = trainingOptions('sgdm');
%
%   net = trainNetwork(ds,layers,opts);
%
%   Example - Visualize data in denoisingImageDatastore
%   -------
%
%   imds = imageDatastore(fullfile(matlabroot,'toolbox','images','imdata'));
%   
%   ds = denoisingImageDatastore(imds,...
%       'PatchesPerImage', 512,...
%       'PatchSize', 50,...
%       'GaussianNoiseLevel', [0.01 0.1],...
%       'ChannelFormat', 'grayscale');
%
%   data = read(ds);
%
%   figure
%   montage(data{:,1});
%   title('Noisy input images');
%
%   figure
%   montage(data{:,2})
%   title('Expected noise channel response');
%
%   See also dnCNNLayers, denoiseImage, denoisingNetwork

%   Copyright 2017 The MathWorks, Inc.

classdef denoisingImageDatastore < ...
        matlab.io.Datastore &...
        matlab.io.datastore.MiniBatchable &...
        matlab.io.datastore.Shuffleable &...
        matlab.io.datastore.BackgroundDispatchable &...
        matlab.io.datastore.PartitionableByIndex

    properties (SetAccess = private, GetAccess = public)
        
        %PatchesPerImage - Number of random patches per image
        %
        %  Integer specifying the number of random patches generated
        %  from each image in the imageDatastore.
        PatchesPerImage
        
        %PatchSize - Size of the random patches
        %
        %   Size of the random crops created from the images.
        PatchSize
        
        %GaussianNoiseLevel - Standard deviation of the Gaussian noise
        %
        %   Standard deviation of the additive white Gaussian noise to be added to
        %   the random image patches. It can be a scalar signifying a single
        %   noise level or a vector of two elements specifying the maximum and
        %   minimum noise standard deviation.
        GaussianNoiseLevel
        
        %ChannelFormat - Format of the noisy image patches
        %
        %   Specifies the format of the output noisy image patches as rgb or grayscale.
        ChannelFormat
    end
    
    properties (Dependent)
        
        %MiniBatchSize - MiniBatch Size
        %
        %   The number of observations returned as rows in the table
        %   returned by the read method.
        MiniBatchSize
    end
    
    properties (SetAccess = 'protected', Dependent)
        
        %NumObservations - Number of observations
        %
        %   The number of observations in the datastore. In the case of
        %   denoisingImageDatastore, this is the length of the
        %   imageDatastore multiplied by PatchesPerImage. When used for
        %   training, this is the number of patches in one training epoch.
        NumObservations 
    end
    
    properties (Access = private, Hidden, Dependent)
        TotalNumberOfMiniBatches
    end
    
    properties (Access = private)
        imds
    end
   
    properties (Access = private)        
        CurrentMiniBatchIndex
        NumberOfChannels
        MiniBatchSizeInternal
        OrderedIndices
    end
        
    methods
        
        function batchSize = get.MiniBatchSize(self)
            batchSize = self.MiniBatchSizeInternal;
        end
        
        function set.MiniBatchSize(self, batchSize)
            self.MiniBatchSizeInternal = batchSize;
        end
        
        function tnmb = get.TotalNumberOfMiniBatches(self)
            
            tnmb = floor(self.NumObservations/self.MiniBatchSize) + ...
                (mod(self.NumObservations, self.MiniBatchSize) > 0)*1;
            
        end
        
        function numObs = get.NumObservations(self)
            numObs = length(self.OrderedIndices);
        end
             
        function self = denoisingImageDatastore(imds,varargin)
            %denoisingImageDatastore   Construct a denoising image datastore
            %
            %   ds = denoisingImageDatastore(imds) creates a randomly cropped pristine and
            %            noisy image patch pair datastore using images from ImageDatastore imds.
            %
            %   ds = denoisingImageDatastore(__, Name, Value,__) creates a
            %            randomly cropped pristine and noisy patch pair image
            %            datastore with additional parameters controlling the data
            %            generation process.
            %
            %   Parameters are:
            %
            %   PatchesPerImage           : Integer specifying the number
            %                               of pathces generated
            %                               from an image.
            %                               Default is 512.
            %
            %   PatchSize                 : Size of the random crops. It
            %                               can be an integer scalar
            %                               specifying same row and column
            %                               sizes or a two element integer
            %                               vector specifying different row
            %                               and column sizes.
            %                               Default is 50.
            %
            %   GaussianNoiseLevel        : Specifies the Gaussian noise
            %                               standard deviation as a
            %                               fraction of the image class
            %                               maximum. It can be a scalar
            %                               signifying a single noise level
            %                               or a vector of two elements
            %                               specifying the maximum and
            %                               minimum noise standard
            %                               deviations. When it is a
            %                               vector, the range of noise
            %                               variance is uniformly sampled
            %                               to identify a noise level for a
            %                               particular patch. 
            %                               Default is 0.1.
            %
            %   DispatchInBackground      : Accelerate training patch
            %                               generation by asyncronously
            %                               reading, adding noise, and
            %                               queueing them for use in
            %                               training. Requires Parallel
            %                               Computing Toolbox.
            %                               Default is false.
            %
            %   ChannelFormat             : Specifies the data channel format as rgb or
            %                               grayscale.
            %                               Default is grayscale.
            %
            %   NOTE: This function requires the Neural Network Toolbox.
            %
            %   Class Support
            %   -------------
            %
            %   imds is an ImageDatastore.
            %
            %   Notes:
            %   -----
            %
            %  1. Training a deep neural network for a range of noise variances is a
            %      much more difficult problem compared to a single noise level one.
            %      Hence, it is recommended to create more patches compared to a single noise level
            %      case and training might take more time.
            %
            %  2. If channel format is grayscale, all color images would be converted to grayscale
            %     and if channel format is rgb, grayscale images would be replicated to
            %     simulate an rgb image.
            %
            %   Example - Train a network using denoisingImageDatastore
            %   -------
            %
            %   imds = imageDatastore(pathToGrayscaleNaturalImageData);
            %
            %   ds = denoisingImageDatastore(imds,...
            %       'PatchesPerImage', 512,...
            %       'PatchSize', 50,...
            %       'GaussianNoiseLevel', [0.01 0.1],...
            %       'ChannelFormat', 'grayscale');
            %
            %   layers = dnCNNLayers();
            %
            %   opts = trainingOptions('sgdm');
            %
            %   net = trainNetwork(ds,layers,opts);
            %
            %   Example - Visualize data from denoisingImageDatastore
            %   ------- 
            %   
            %   imds = imageDatastore(fullfile(matlabroot,'toolbox','images','imdata'));
            %
            %   ds = denoisingImageDatastore(imds,...
            %       'PatchesPerImage', 512,...
            %       'PatchSize', 50,...
            %       'GaussianNoiseLevel', [0.01 0.1],...
            %       'ChannelFormat', 'grayscale');
            %
            %   data = read(ds);
            %   figure
            %   montage(data{:,1});
            %   title('Noisy input images');
            %   figure
            %   montage(data{:,2})
            %   title('Expected noise channel for response');
            %
            %   See also dnCNNLayers, denoiseImage, denoisingNetwork
            
            images.internal.requiresNeuralNetworkToolbox(mfilename);
            
            narginchk(1,11);
            
            validateImagedatastore(imds);
            options = parseInputs(varargin{:});
            
            self.PatchesPerImage = options.PatchesPerImage;
            self.ChannelFormat = options.ChannelFormat;
            if strcmp(self.ChannelFormat,'rgb')
                self.NumberOfChannels = 3;
            else
                self.NumberOfChannels = 1;
            end
            if numel(options.PatchSize) == 1
                self.PatchSize = [options.PatchSize options.PatchSize self.NumberOfChannels];
            else
                self.PatchSize = [options.PatchSize self.NumberOfChannels];
            end
            self.GaussianNoiseLevel = options.GaussianNoiseLevel;
            
            self.imds = imds.copy(); % Don't mess with state of imds input.
            self.DispatchInBackground = options.DispatchInBackground;
            self.MiniBatchSize = 128;
            numObservations = length(self.imds.Files) * self.PatchesPerImage;
            self.OrderedIndices = 1:numObservations;
            
            self.reset();
        end
        
    end
    
    methods
        
        function [data,info] = readByIndex(self,indices)
            
            indices = self.OrderedIndices(indices);
            
            startMod = mod(indices(1), self.PatchesPerImage);
            endMod = mod(indices(end), self.PatchesPerImage);
            
            isStartModNonZero = (startMod > 0);
            isEndModNonZero = (endMod > 0);
            startImage = floor(indices(1)/self.PatchesPerImage) + isStartModNonZero*1;
            endImage = floor(indices(end)/self.PatchesPerImage) + isEndModNonZero*1;
            
            % Create datastore partition via a copy and index. This is
            % faster than constructing a new datastore with the new
            % files.
            subds = copy(self.imds);
            subds.Files = self.imds.Files(startImage:endImage);
            images = subds.readall();
            
            if startImage == endImage
                [input,response] = self.getNoisyPatches(images, length(indices));
            else
                startImageNumPatches = isStartModNonZero * ...
                    (self.PatchesPerImage - startMod) + 1;
                endImageNumPatches = (~isEndModNonZero) * ...
                    self.PatchesPerImage + endMod;
                
                numPatches = [startImageNumPatches ...
                    self.PatchesPerImage*ones(1,endImage-startImage-1)...
                    endImageNumPatches];
                
                [input,response] = self.getNoisyPatches(images, numPatches);
            end
            data = table(input,response);
            info.CurrentFileIndices = startImage:endImage;
        end
        
        function [data,info] = read(self)
            
            if ~self.hasdata()
               error(message('images:denoisingImageDatastore:outOfData')); 
            end
            
            batchNumber = self.CurrentMiniBatchIndex;
            startObsIndex = (batchNumber - 1) * self.MiniBatchSize + 1;
            if batchNumber == self.TotalNumberOfMiniBatches
                endObsIndex = self.NumObservations;
            else
                endObsIndex = startObsIndex + self.MiniBatchSize - 1;
            end
            
            self.CurrentMiniBatchIndex = self.CurrentMiniBatchIndex + 1;
            [data,info] = self.readByIndex(startObsIndex:endObsIndex);
        end
        
        function reset(self)
            self.imds.reset();
            self.CurrentMiniBatchIndex = 1;
        end
        
        function newds = shuffle(self)
            newds = copy(self);
            imdsIndexList = randperm(length(self.imds.Files));
            reorderIndexList(newds,imdsIndexList);
        end
        
        function TF = hasdata(self)
           TF = self.CurrentMiniBatchIndex <= self.TotalNumberOfMiniBatches;
        end
        
        function newds = partitionByIndex(self,indices)
            newds = copy(self);
            newds.imds = copy(self.imds);
            newds.OrderedIndices = indices;
        end
               
    end
    
    methods (Hidden)
        
        function frac = progress(self)
            if hasdata(self)
                frac = (self.CurrentMiniBatchIndex - 1) / self.TotalNumberOfMiniBatches;
            else
                frac = 1;
            end
        end
        
    end
   
    methods (Access = private)
        
        function reorderIndexList(self,imdsIndexList)
           % Reorder OrderedIndices to be consistent with a new ordering of
           % the underlying imds. That is, when shuffle is called, we only
           % want to reorder imds, we don't want to end up with a truly
           % random shuffling of all of the observations because that will
           % drastically degrade performance by creating a situation where
           % each image patch is from a different source image.
            
           observationToImdsIndex = floor(( self.OrderedIndices -1) / self.PatchesPerImage) + 1;
           newObservationMapping = zeros(size(observationToImdsIndex),'like',observationToImdsIndex);
           currentIdxPos = 1;
           for i = 1:length(imdsIndexList)
              idx = imdsIndexList(i);
              sortedIdx = find(observationToImdsIndex == idx);
              newObservationMapping(currentIdxPos:(currentIdxPos+length(sortedIdx)-1)) = sortedIdx;
              currentIdxPos = currentIdxPos+length(sortedIdx);
           end
           self.OrderedIndices = newObservationMapping;
        end
        
        function [X,Y] = getNoisyPatches(self, images, numPatches)
            totalPatches = sum(numPatches);
            
            actualPatchSize = [self.PatchSize totalPatches];
            
            X = cell(totalPatches,1);
            Y = cell(totalPatches,1);
            
            isNoiseRange = (numel(self.GaussianNoiseLevel) == 2);
            
            count = 1;
            for imIndex = 1:length(numPatches)
                
                im = images{imIndex};
                
                patchSizeCheck = size(im,1) >= actualPatchSize(1) && ...
                    size(im,2) >= actualPatchSize(2);
                
                if ~patchSizeCheck
                    [~,fn,fe] = fileparts(self.imds.Files{imIndex}); 
                    error(message('images:denoisingImageDatastore:expectPatchSmallerThanImage', [fn fe]));
                end
                                
                if strcmp(self.ChannelFormat,'rgb')
                    im = convertGrayscaleToRGB(im);
                else
                    im = convertRGBToGrayscale(im);
                end
                
                im = im2single(im);
                imNumPatches = numPatches(imIndex);
                
                rowLocations = randi(max(size(im,1)-actualPatchSize(1),1), imNumPatches, 1);
                colLocations = randi(max(size(im,2)-actualPatchSize(2),1), imNumPatches, 1);
                
                for index = 1:imNumPatches
                    patch = im(rowLocations(index):rowLocations(index)+actualPatchSize(1)-1,...
                        colLocations(index):colLocations(index)+actualPatchSize(2)-1, :);
                    
                    if isNoiseRange
                        noiseSigma = min(self.GaussianNoiseLevel) + ...
                            abs(self.GaussianNoiseLevel(2)-self.GaussianNoiseLevel(1))*rand;
                    else
                        noiseSigma = self.GaussianNoiseLevel;
                    end
                    
                    residualNoise = noiseSigma * randn(self.PatchSize,'single');
                    Y{count} = residualNoise;
                    X{count} = patch + residualNoise;
                    count = count + 1;
                end
            end
        end
        
    end
    
    methods(Static, Hidden = true)
        function self = loadobj(S)
            self = denoisingImageDatastore(S.imds, ...
                'ChannelFormat', S.ChannelFormat, ...
                'GaussianNoiseLevel', S.GaussianNoiseLevel,...
                'PatchesPerImage', S.PatchesPerImage,...
                'PatchSize', [S.PatchSize(1) S.PatchSize(2)], ...
                'BackgroundExecution', S.BackgroundExecution);
        end
    end
    
    methods (Hidden)
        function S = saveobj(self)
            
            % Serialize denoisingImageDatastore object
            % Note we that serialize DispatchInBackground under the name
            % BackgroundExecution to make V1 and V2 loadobj work.
            S = struct('imds',self.imds,...
                'ChannelFormat',self.ChannelFormat,...
                'GaussianNoiseLevel',self.GaussianNoiseLevel,...
                'PatchesPerImage',self.PatchesPerImage,...
                'PatchSize',self.PatchSize,...
                'BackgroundExecution',self.DispatchInBackground);            
        end
        
    end
end


function B = validateImagedatastore(ds)

validateattributes(ds, {'matlab.io.datastore.ImageDatastore'}, ...
    {'nonempty','vector'}, mfilename, 'IMDS');
validateattributes(ds.Files, {'cell'}, {'nonempty'}, mfilename, 'IMDS');

B = true;

end

function options = parseInputs(varargin)

parser = inputParser();
parser.addParameter('PatchesPerImage',512,@validatePatchesPerImage);
parser.addParameter('PatchSize',50,@validatePatchSize);
parser.addParameter('GaussianNoiseLevel',0.1,@validateGaussianNoiseLevel);
parser.addParameter('BackgroundExecution',false,@validateBackgroundExecution);
parser.addParameter('DispatchInBackground',false,@validateDispatchInBackground);
parser.addParameter('ChannelFormat','grayscale',@validateChannelFormat);

parser.parse(varargin{:});
options = manageDispatchInBackgroundNameValue(parser);

validOptions = {'rgb','grayscale'};
options.ChannelFormat = validatestring(options.ChannelFormat,validOptions, ...
    mfilename,'ChannelFormat');

end

function B = validatePatchesPerImage(PatchesPerImage)

attributes = {'nonempty','real','scalar', ...
    'positive','integer','finite','nonsparse','nonnan','nonzero'};

validateattributes(PatchesPerImage,images.internal.iptnumerictypes, attributes,...
    mfilename,'PatchesPerImage');

B = true;

end


function B = validatePatchSize(PatchSize)

attributes = {'nonempty','real','vector', ...
    'positive','integer','finite','nonsparse','nonnan','nonzero'};

validateattributes(PatchSize,images.internal.iptnumerictypes, attributes,...
    mfilename,'PatchSize');

if numel(PatchSize) > 2
    error(message('images:denoisingImageDatastore:invalidPatchSize'));
end

B = true;

end

function B = validateBackgroundExecution(BackgroundExecution)

attributes = {'nonempty','scalar', ...
    'finite','nonsparse','nonnan'};
validateattributes(BackgroundExecution,{'logical'}, attributes,...
    mfilename,'BackgroundExecution');

B = true;

end

function B = validateDispatchInBackground(BackgroundExecution)

attributes = {'nonempty','scalar', ...
    'finite','nonsparse','nonnan'};
validateattributes(BackgroundExecution,{'logical'}, attributes,...
    mfilename,'DispatchInBackground');

B = true;

end

function B = validateGaussianNoiseLevel(GaussianNoiseLevel)

supportedClasses = {'single','double'};
attributes = {'nonempty','real','vector', ...
    'nonnegative','finite','nonsparse','nonnan','nonzero','>=',0,'<=',1};

validateattributes(GaussianNoiseLevel, supportedClasses, attributes,...
    mfilename,'GaussianNoiseLevel');

if numel(GaussianNoiseLevel) > 2
    error(message('images:denoisingImageDatastore:invalidNoiseVariance'));
end

B = true;

end

function B = validateChannelFormat(ChannelFormat)

supportedClasses = {'char','string'};
attributes = {'nonempty'};
validateattributes(ChannelFormat,supportedClasses,attributes,mfilename, ...
    'ChannelFormat');

B = true;
end

function im = convertRGBToGrayscale(im)
if ndims(im) == 3
    im = rgb2gray(im);
end
end

function im = convertGrayscaleToRGB(im)
if size(im,3) == 1
    im = repmat(im,[1 1 3]);
end
end

function resultsStruct = manageDispatchInBackgroundNameValue(p)

resultsStruct = p.Results;

DispatchInBackgroundSpecified = ~any(strncmp('DispatchInBackground',p.UsingDefaults,length('DispatchInBackground')));
BackgroundExecutionSpecified = ~any(strncmp('BackgroundExecution',p.UsingDefaults,length('BackgroundExecution')));

% In R2017b, BackgroundExecution was name used to control
% DispatchInBackground. Allow either to be specified.
if BackgroundExecutionSpecified && ~DispatchInBackgroundSpecified
    resultsStruct.DispatchInBackground = resultsStruct.BackgroundExecution;
end

end

