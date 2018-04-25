%brisqueModel Blind/Referenceless Image Spatial Quality Evaluator (BRISQUE) Model
%
%   A brisqueModel object encapsulates a model that can be used to calculate
%   the BRISQUE perceptual quality score of an image. It contains a support
%   vector regressor (SVR) model which can be trained using fitBRISQUE.
%
%   brisqueModel properties:
%       Alpha               - Coefficients obtained by solving the dual problem.
%       Bias                - Bias term.
%       SupportVectors      - Support vectors.
%       Kernel              - The kernel function.
%       Scale               - Scale factor used to divide predictor values.
%
%   brisqueModel methods:
%      brisqueModel - Construct brisqueModel object
%
%   Example
%   -------
%   This example shows how to use a custom brisqueModel object to calculate
%   the BRISQUE score for an image.
%
%   I = imread('lighthouse.png');
%
%   % Any pre-computed Alpha, Bias, SupportVectors and Scale can be used to
%   % initialize a brisqueModel object. Random initializations are shown for 
%   % illustrative purposes only.
%   model = brisqueModel(rand(10,1), 10, rand(10,36), 0.25);
%
%   score = brisque(I, model);
%
%   See also BRISQUE, FITBRISQUE, RegressionSVM, NIQE, FITNIQE, brisqueModel

% Copyright 2016 The MathWorks, Inc.


classdef brisqueModel
    properties(SetAccess = private, GetAccess = public)
        
        %ALPHA Coefficients obtained by solving the dual problem.
        %   The Alpha property is a vector with M elements for M support
        %   vectors. The regression scores are computed for predictor
        %   matrix X as
        %
        %   F = G(X,SupportVectors)*Alpha + Bias
        %
        %   where G(X,SupportVectors) is an N-by-M matrix of kernel products for N
        %   rows in X and M rows in SupportVectors.
        %
        %   Alpha can be uint8, uint16, uint32, int8, int16, int32, single
        %   or double.
        %
        %   See also classreg.learning.regr.CompactRegressionSVM,
        %   Bias, SupportVectors.
        Alpha 
        
        %BIAS Bias term.
        %   The Bias property is a scalar specifying the bias term in the SVM
        %   model. The regression scores are computed for predictor
        %   matrix X as
        %
        %   F = G(X,SupportVectors)*Alpha + Bias
        %
        %   where G(X,SupportVectors) is an N-by-M matrix of kernel products for N
        %   rows in X and M rows in SupportVectors.
        %
        %   Bias can be uint8, uint16, uint32, int8, int16, int32, single
        %   or double.
        %        
        %   See also classreg.learning.regr.CompactRegressionSVM, Alpha,
        %   Alpha, SupportVectors.
        Bias 
        
        %SUPPORTVECTORS Support vectors.
        %   The SupportVectors property is an M-by-P matrix for M support vectors
        %   and P predictors. The regression scores are computed for predictor
        %   matrix X as
        %
        %   F = G(X,SupportVectors)*Alpha + Bias
        %
        %   where G(X,SupportVectors) is an N-by-M matrix of kernel products for N
        %   rows in X and M rows in SupportVectors.
        %
        %   SUPPORTVECTORS can be uint8, uint16, uint32, int8, int16, int32, single
        %   or double.
        %        
        %   See also classreg.learning.regr.CompactRegressionSVM,
        %   Alpha, Bias.
        SupportVectors 
        
        %KERNEL The kernel function.
        %   Name of the kernel function, a character vector.
        %   The SVR computes a kernel product between vectors x and z
        %   using Kernel(x/Scale,z/Scale).
        %
        %   Kernel is always 'gaussian'.
        %
        %   See also Scale, classreg.learning.regr.CompactRegressionSVM.
        Kernel 
        
        %SCALE The kernel scale factor.
        %   Scale factor used by the SVR kernel.
        %   The SVR computes a kernel product between vectors x and z
        %   using Kernel(x/Scale,z/Scale).
        %
        %   SCALE can be uint8, uint16, uint32, int8, int16, int32, single
        %   or double.
        %        
        %   See also Kernel, classreg.learning.regr.CompactRegressionSVM.
        Scale 
    end
    
    
    methods
        function obj = brisqueModel(Alpha, Bias, SupportVectors, Scale)
            % brisqueModel Construct a brisqueModel object.
            %
            %   obj = brisqueModel() constructs the default BRISQUE model
            %   with a Gaussian kernel.
            %
            %   obj = brisqueModel(Alpha, Bias, SupportVectors, Scale)            
            %   constructs a brisqueModel object containing a support
            %   vector regressor (SVR) given a N-by-1 Alpha vector where N
            %   is the number of support vectors, a scalar Bias, a N-by-36
            %   matrix of N support vectors, and a scalar Scale. The kernel
            %   of the SVR is Gaussian.            
            
            if (nargin ~= 0)&&(nargin ~= 4)
                error(message('images:brisque:expectZeroORFourInputs'));
            end
            
            if nargin == 0
                obj = brisqueModel.loadDefaultBRISQUEModel();
            else
                validateAlpha(Alpha);
                validateBias(Bias);
                validateSupportVectors(SupportVectors);                
                validateScale(Scale);
                
                if(size(Alpha,1)~=size(SupportVectors,1))
                    error(message('images:brisque:AlphaSVmismatch'));
                end
                
                obj.Alpha = double(Alpha);
                obj.Bias = double(Bias);
                obj.SupportVectors = double(SupportVectors);
                obj.Kernel = 'gaussian';
                obj.Scale = double(Scale);
            end
        end
        
    end
    
    methods(Static, Hidden = true)
        
        function obj = loadDefaultBRISQUEModel()
            persistent defaultBRISQUEModel
            if(isempty(defaultBRISQUEModel))
                fname = fullfile(toolboxdir('images'),'imdata','defaultBRISQUEModel.mat');
                md = load(fname);
                defaultBRISQUEModel = md.defaultBRISQUEModel;
            end
            obj = defaultBRISQUEModel;
        end
        
        function self = loadobj(S)
            self = brisqueModel(S.Alpha,S.Bias,S.SupportVectors,S.Scale);
        end
        
        function obj = computeBRISQUEModel(imds, dmos_scores)
            num_features = 18;
            num_scales = 2;
            numFiles = size(imds.Files,1);
            full_NSSfeatures = zeros(numFiles,num_features*num_scales);
            dmos_scores = double(dmos_scores);
            
            waitObj = iptui.textWaitUpdater('Extracting features from %d images.','Completed %d of %d images.',numFiles,0);
            c = onCleanup(@()waitObj.destroy());
            
            index = 1;
            for i = 1:size(imds.Files,1)
                waitObj.update(i);
                im = readimage(imds,i);
                        
                validImage = isa(im,'uint8') || isa(im,'uint16') || isa(im,'int16') || isa(im,'single') || isa(im,'double');
                
                if(~validImage)                    
                    [~,fn,fe] = fileparts(imds.Files{i});
                    warning(message('images:brisque:expectValidImage',class(im),[fn fe]));
                    dmos_scores(i) = [];
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
                
                NSSfeatures = computeBRISQUEFeatures(im);
                full_NSSfeatures(index,:) = NSSfeatures;
                index = index + 1;
            end
            full_NSSfeatures(index:end,:) = [];
            
            if(isempty(full_NSSfeatures))
                error(message('images:brisque:EmptyFeatureVector'));
            end

            
            % Train support vector regressor
            msg = message('images:brisque:SVRTraining');
            disp(getString(msg));

            if all(sum(isnan(full_NSSfeatures),2))
                error(message('images:brisque:AllFeatureRowsHaveNan'));
            else
                svrmdl = fitrsvm(full_NSSfeatures,dmos_scores,'KernelFunction','rbf','KernelScale','auto');
                obj = brisqueModel(svrmdl.Alpha, svrmdl.Bias, svrmdl.SupportVectors, svrmdl.KernelParameters.Scale);
            end
        end
        
    end
    methods(Hidden = true)
        
        function score = calculateBRISQUEscore(obj,im)
            full_NSSfeatures = computeBRISQUEFeatures(im);
            if(any(isnan(full_NSSfeatures)))
                warning(message('images:brisque:expectFiniteFeatures'));
            end
            score = scoreBRISQUE(full_NSSfeatures, obj);
        end
        
        function S = saveobj(self)
            
            % Serialize brisqueModel object
            S = struct('Alpha',self.Alpha,'Bias',self.Bias,'SupportVectors',self.SupportVectors,...
                'Kernel',self.Kernel, 'Scale', self.Scale);
            
        end
        
    end
end

function full_NSSfeatures = computeBRISQUEFeatures(im)
% computeBRISQUEFeatures computes the Natural Scene Statistics based
%   BRISQUE features which are used for predicting the BRISQUE score and
%   training the SVR model

% Copyright 2016 The MathWorks, Inc.

num_features = 18;
num_scales = 2;

full_NSSfeatures = zeros(num_features*num_scales,1);

for i = 1:num_scales
    
    % Normalize image to zero mean and ~unit std
    immean = imgaussfilt(im,7/6,'FilterSize',7,'Padding','replicate');
    imstd = sqrt(abs(imgaussfilt(im.*im,7/6,'FilterSize',7,'Padding','replicate') - immean.*immean));
    imnorm = (im-immean)./(imstd+1);
    
    % Compute the AGGD parameters
    NSSfeats = images.internal.computeNSSFeatures(imnorm);
    full_NSSfeatures((i-1)*num_features+1:i*num_features) = NSSfeats';
    
    im =imresize(im,0.5);
end
end

function score = scoreBRISQUE(full_NSSfeatures, obj)
% scoreBRISQUE computes the SVR regression score when provided with the
%   natural scene statistics features and the brisqueModel object which
%   contains the SVR parameters. The SVR kernel is always Gaussian.

% Copyright 2016 The MathWorks, Inc.

% SVR Predict
svT = obj.SupportVectors'./obj.Scale;
svInnerProduct = dot(svT,svT);

scale = cast(obj.Scale,'like',full_NSSfeatures);
X = full_NSSfeatures'/scale;

kernelProduct = cast(-2,'like',X)*X*svT+X*X';
kernelProduct = kernelProduct+svInnerProduct;
kernelProduct = exp(-kernelProduct);

score = kernelProduct*obj.Alpha + obj.Bias;
end

function validateAlpha(Alpha)

validateattributes(Alpha,images.internal.iptnumerictypes,{'nonempty','real', 'column' ...
    'finite','nonsparse','nonnan'},...
    mfilename,'Alpha');
end

function validateBias(Bias)
validateattributes(Bias,images.internal.iptnumerictypes,{'nonempty','real', 'scalar',...
    'finite','nonsparse','nonnan'},...
    mfilename,'Bias');
end

function validateSupportVectors(SupportVectors)
validateattributes(SupportVectors,images.internal.iptnumerictypes,{'nonempty','real', 'ncols', 36,...
    'finite','nonsparse','nonnan'},...
    mfilename,'SupportVectors');
end

function validateScale(Scale)
validateattributes(Scale,images.internal.iptnumerictypes,{'nonempty','real', 'scalar',...
    'finite','nonsparse','nonnan'},...
    mfilename,'Scale');
end
