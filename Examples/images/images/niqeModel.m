%niqeModel Naturalness Image Quality Evaluator (NIQE) Model
%
%   A niqeModel object encapsulates a model that can be used to calculate
%   the NIQE perceptual quality score of an image.
%
%   niqeModel properties:
%       Mean                - Mean feature vector.
%       Covariance          - Covariance matrix of feature vectors.
%       BlockSize           - Block size used to compute feature vectors.
%       SharpnessThreshold  - Sharpness threshold used to compute feature
%                             vectors.
%
%   niqeModel methods:
%      niqeModel - Construct niqeModel object
%     
%   Example 
%   -------
%   This example shows how to use a custom niqeModel object to calculate
%   the NIQE score for an image.
%
%   I = imread('lighthouse.png');
%
%   % Any pre-computed mean and covariance matrices can be used to
%   % initialize a niqeModel object along with the BlockSize and
%   % SharpnessThreshold settings used to compute the mean and covariance.
%   % Random initializations are shown for illustrative purposes only.
%   model = niqeModel(rand(1,36),rand(36,36),[10 10], 0.25);
%   
%   score = niqe(I, model);
%   
%   See also NIQE, FITNIQE, BRISQUE, FITBRISQUE, niqeModel

% Copyright 2016 The MathWorks, Inc.

classdef niqeModel
    
    properties(SetAccess = private, GetAccess = public)
        
        %Mean - Mean feature vector of the model
        %
        %   Mean of the natural scene statistics (NSS) based image
        %   feature vectors. It is a 1-by-36 vector.
        Mean 
        
        %Covariance - Covariance matrix of feature vectors
        %   
        %   Covariance matrix of the NSS based image feature vectors. It is
        %   a 36-by-36 matrix.
        Covariance 
        
        %BlockSize - Block size used to compute the features
        %
        %   BlockSize used to partition an image into non-overlapping
        %   blocks to compute the NSS based image feature vectors.
        %   It is a two element row vector [rowsize, columnsize]. Default
        %   is [96, 96].
        BlockSize 
        
        %SharpnessThreshold - Sharpness threshold used to calculate feature
        %                       vectors
        %
        %   Sharpness threshold used to select the image blocks to be used
        %   to compute the feature vectors. It is a scalar in the range
        %   [0,1]. Default is 0.
        SharpnessThreshold 
    end
    
    methods
        function obj = niqeModel(Mean, Covariance, BlockSize, SharpnessThreshold)
            % niqeModel Construct a niqeModel object.
            %   
            %   obj = niqeModel() constructs the default NIQE model 
            %
            %   obj = niqeModel(Mean, Covariance, BlockSize, SharpnessThreshold) 
            %   constructs a niqeModel object given a 1-by-36 NSS based
            %   Mean feature vector, 36-by-36 NSS based feature Covariance
            %   matrix, 1-by-2 BlockSize in the format [rowsize, columnsize] 
            %   and a real scalar SharpnessThreshold in the range [0, 1].
            
            if (nargin ~= 0)&&(nargin ~= 4)
                error(message('images:niqe:expectZeroORFourInputs'));
            end
            
            if nargin == 0
                obj = niqeModel.loadDefaultniqeModel();
            else
                validateMean(Mean);
                validateCovariance(Covariance);
                validateBlockSize(BlockSize);
                validateSharpnessThreshold(SharpnessThreshold);
                
                obj.Mean = double(Mean);
                obj.Covariance = double(Covariance);
                obj.BlockSize = double(BlockSize);
                obj.SharpnessThreshold = double(SharpnessThreshold);
            end
        end
        
    end
    
    methods(Static, Hidden = true)
        function obj = loadDefaultniqeModel()
            persistent defaultNIQEModel
            if(isempty(defaultNIQEModel))
                fname = fullfile(toolboxdir('images'),'imdata',...
                    'defaultNIQEModel.mat');
                md = load(fname);
                defaultNIQEModel = md.defaultNIQEModel;
            end
            obj = defaultNIQEModel;
        end
        
        function obj = computeNIQEModel(imds, BlockSize, SharpnessThreshold)
            BlockSize = double(BlockSize);
            full_NSSfeatures = [];
            numFiles = size(imds.Files,1);
            
            waitObj = iptui.textWaitUpdater('Extracting features from %d images.',...
                'Completed %d of %d images.',numFiles,0);
            c = onCleanup(@()waitObj.destroy());

            for i = 1:numFiles
                waitObj.update(i);
                im = readimage(imds,i);

                validImage = isa(im,'uint8') || isa(im,'uint16') || isa(im,'int16') ...
                    || isa(im,'single') || isa(im,'double');                                
                
                if(~validImage)
                    [~,fn,fe] = fileparts(imds.Files{i});
                    warning(message('images:niqe:expectValidImage',class(im),[fn fe]));
                    continue;
                end                                
                
                if(size(im,3)==3)
                    if isa(im,'int16')
                        % Since rgb2gray does not support int16
                        im = im2double(im);
                    end
                    im = rgb2gray(im);
                end
                im = 255*im2double(im);
                
                % Call compute function
                NSSfeatures = computeBlockNSSFeatures(im, ...
                    BlockSize, SharpnessThreshold);
                full_NSSfeatures = [full_NSSfeatures; NSSfeatures]; %#ok<*AGROW>
            end

            if(isempty(full_NSSfeatures))
                error(message('images:niqe:EmptyFeatureVector'));
            end
            
            
            obj = niqeModel(nanmean(full_NSSfeatures,1),...
                nancov(full_NSSfeatures), BlockSize, SharpnessThreshold);

        end
        
        function self = loadobj(S)
            self = niqeModel(S.Mean,S.Covariance,S.BlockSize,...
                S.SharpnessThreshold);
        end

    end
    
    methods(Hidden)
        
        function score = calculateNIQEscore(obj,im)
            full_NSSfeatures = computeBlockNSSFeatures(im, ...
                obj.BlockSize, obj.SharpnessThreshold);
            % Fit a MVG model to patch features
            mu_testparam     = nanmean(full_NSSfeatures);
            cov_testparam    = nancov(full_NSSfeatures);
            % Compute quality
            if(any(isnan(full_NSSfeatures)))
                warning(message('images:niqe:expectFiniteFeatures'));
                score = nan;
            else
                invcov_param     = pinv((obj.Covariance+cov_testparam)/2);
                score = sqrt((obj.Mean-mu_testparam) * invcov_param *(obj.Mean-mu_testparam)');
            end
        end
        
            
        function S = saveobj(self)
            
            % Serialize niqeModel object 
            S = struct('Mean',self.Mean,'Covariance',self.Covariance,'BlockSize',self.BlockSize,...
                'SharpnessThreshold',self.SharpnessThreshold);
            
        end
        
    end
        
end

function full_NSSfeatures = computeBlockNSSFeatures(im, BlockSize, SharpnessThreshold)
% computeBlockNSSFeatures computes the blockwise natural scene statistics
% based features for calculating the NIQE score.

% Copyright 2016 The MathWorks, Inc.


num_features = 18;
num_scales = 2;

% Truncate image to row and column sizes which are integer multiples of blk
% row and col sizes
[row, col] = size(im);
blksizerow = BlockSize(1);
blksizecol = BlockSize(2);

num_rowpatches = max(floor(row/blksizerow),1);
num_colpatches = max(floor(col/blksizecol),1);

if(num_rowpatches==1)
    blksizerow = row;
end

if(num_colpatches==1)
    blksizecol = col;
end

im = im(1:num_rowpatches*blksizerow,1:num_colpatches*blksizecol);

fun = @(block_struct) images.internal.computeNSSFeatures(block_struct.data);
full_NSSfeatures = zeros(num_rowpatches*num_colpatches, num_features*num_scales);
for i = 1:num_scales
    % Normalize image to zero mean and ~unit std
    immean = imgaussfilt(im,7/6,'FilterSize',7,'Padding','replicate');
    imstd = sqrt(abs(imgaussfilt(im.*im,7/6,'FilterSize',7,'Padding','replicate') - immean.*immean));
    imnorm = (im-immean)./(imstd+1);
    
    NSSfeats = blockproc(imnorm,[round(blksizerow/i) round(blksizecol/i)],fun);
    NSSfeats = reshape(NSSfeats,num_features,[]);
    full_NSSfeatures(:,(i-1)*num_features+1:i*num_features) = NSSfeats';
    
    % Compute sharpness
    if(i==1)
        computesharpness = @(block_struct) mean2(block_struct.data);
        sharpness = blockproc(imstd,[round(blksizerow/i) round(blksizecol/i)],computesharpness);
        sharpness = sharpness(:);
    end
    
    im = imresize(im,0.5);
end

index = sharpness>=SharpnessThreshold*max(sharpness(:));
full_NSSfeatures = full_NSSfeatures(index,:);
end


function validateMean(Mean)
validateattributes(Mean,images.internal.iptnumerictypes,{'nonempty','real','size',[1 36], ...
    'finite','nonsparse','nonnan'},...
    mfilename,'Mean');
end

function validateCovariance(Covariance)
validateattributes(Covariance,images.internal.iptnumerictypes,{'nonempty','real','size',[36 36], ...
    'finite','nonsparse','nonnan'},...
    mfilename,'Covariance');
end

function validateBlockSize(BlockSize)
validateattributes(BlockSize,images.internal.iptnumerictypes,{'nonempty','real','size',[1 2], ...
    'positive','integer','finite','nonsparse','nonnan','nonzero','even'},...
    mfilename,'BlockSize');
end

function validateSharpnessThreshold(SharpnessThreshold)
validateattributes(SharpnessThreshold,{'single','double'},{'nonempty','real', ...
    'scalar','>=',0,'<=',1,'finite','nonsparse','nonnan'},...
    mfilename,'SharpnessThreshold');
end