function varargout = wcompress(option,varargin)
%WCOMPRESS True compression of images using wavelets.
%
% The WCOMPRESS command performs either compression or uncompression of
% grayscale or truecolor images.
%
% Compression:
% ===========
%   WCOMPRESS('c',X,SAV_FILENAME,COMP_METHOD) compresses the image X using
%   the compression method COMP_METHOD. The compressed image is saved in
%   the file SAV_FILENAME. If you do not have write permission in the
%   current working directory, WCOMPRESS changes directory to tempdir and
%   writes the .wtc file in that directory.
%
%   X can be either a 2-D array containing an indexed image or a 3-D array
%   of uint8 containing a truecolor image.
%
%   Both the row and column size of the image must be powers of two.
%
%   WCOMPRESS('c',FILENAME,...) loads the image X from the file FILENAME
%   which is a MATLAB Supported Format(MSF) file: MAT-file or other
%   image files (see IMREAD).
%
%   WCOMPRESS('c',I,...) converts the indexed image X = I{1}
%   to a truecolor image Y using the colormap map = I{2} and then
%   compresses Y.
%
%   The valid compression methods are divided in three categories.
%     1) Progressive Coefficients Significance Methods (PCSM):
%       - 'ezw':   Embedded Zerotree Wavelet.
%       - 'spiht': Set Partitioning in Hierarchical Trees.
%       - 'stw':   Spatial-orientation Tree Wavelet.
%       - 'wdr':   Wavelet Difference Reduction.
%       - 'aswdr': Adaptively Scanned Wavelet Difference Reduction
%       - 'spiht_3d': Set Partitioning in Hierarchical Trees 3D
%                     for truecolor images.
%       For more details on these methods, see the references and
%       specially Walker and also Said and Pearlman.
%
%     2) Coefficients Thresholding Methods (CTM-1):
%       - 'lvl_mmc':   Subband thresholding of coefficients and
%                      Huffman encoding.
%       For more details on this method, see the Strang and Nguyen
%       reference.
%
%     3) Coefficients Thresholding Methods (CTM-2):
%       - 'gbl_mmc_f': Global thresholding of coefficients and
%                      fixed encoding.
%       - 'gbl_mmc_h': Global thresholding of coefficients and
%                      Huffman encoding.
%
%   -------------------------------------------------------------------
%   NOTE: The Discrete Wavelet Transform uses the periodized extension
%   mode.
%   -------------------------------------------------------------------
%
%   All the compression methods use parameters which have default values.
%   These values may be changed using the following syntax:
%      WCOMPRESS(... ,'ParName1',ParVal1,'ParName2',ParVal2, ...)
%   Some of the parameters are related to display or to data transform
%   functionalities. The others are linked to the compression process
%   itself.
%
%   Data transform parameters.
%       - 'ParName' = 'wname' or 'WNAME' sets the wavelet name.
%         ParVal is a string (see waveletfamilies). The default is bior4.4.
%
%       - 'ParName' = 'level' or 'LEVEL' sets the level of decomposition.
%         ParVal is an integer such that: 1 <= level <= levmax which is
%         the maximum possible level (see wmaxlev).
%         The default level depends on the method:
%            . for PCSM methods level is equal levmax.
%            . for CTM methods level is equal to fix(levmax/2).
%
%       If you specify a level greater than levmax, wcompress uses levmax.
%
%       - 'ParName' = 'it' or 'IT' sets Image type Transform.
%         ParVal must be one of the following strings:
%           'n' : no conversion (default), image type (truecolor or
%                 grayscale) is automaticaly detected.
%           'g' : grayscale transformation type.
%           'c' : color transformation type (RGB uint8).
%
%       - 'ParName' = 'cc' or 'CC' sets Color Conversion parameter
%         if X is a truecolor image.
%         ParVal must be one of the following strings:
%           'rgb' or 'none' : No conversion (default).
%           'yuv' : YUV color space transform.
%           'klt' : Karhunen-Loeve transform.
%           'yiq' : YIQ color space transform.
%           'xyz' : CIEXYZ color space transform.
%
%   Parameter for Progressive Coefficients Significance Methods (PCSM)
%       - 'ParName' = 'maxloop' or 'MAXLOOP' sets the maximum number of
%         steps for the compression algorithm.
%         ParVal must be a positive integer or Inf (default is 10).
%
%   Parameters for Coefficients Thresholding Methods (CTM-1)
%     One among the two following parameters may be used:
%       - 'ParName' = 'bpp' or 'BPP' sets the bit-per-pixel ratio.
%         ParVal must be such that:
%               0 <= ParVal <= 8 (grayscale) or 24 (truecolor)
%
%       - 'ParName' = 'comprat' or 'COMPRAT' sets the compression ratio.
%         ParVal must be such that: 0 <= ParVal <= 100.
%
%   Parameters for Coefficients Thresholding Methods (CTM-2)
%     Two parameters may be used. The first one is related to
%     the threshold and the second one is the number of classes for
%     quantization.
%
%       1) The first one may be chosen among the five following
%          parameters:
%       - 'ParName' = 'threshold' or 'THRESHOLD' sets the threshold value
%          for compression.
%          ParVal must be a positive (or zero) real number.
%
%       - 'ParName' = 'nbcfs' or 'NBCFS' sets the number of preserved
%         coefficients in the wavelet decomposition.
%         ParVal must be an integer such that: 0 <= ParVal <= total
%         number of coefficients of wavelet decomposition.
%
%       - 'ParName' = 'percfs' or 'PERCFS' sets the percentage of
%         preserved coefficients in the wavelet decomposition.
%         ParVal must be a real number such that: 0 <= ParVal <= 100.
%
%       - 'ParName' = 'bpp' or 'BPP' sets the bit-per-pixel ratio.
%         ParVal must be such that:
%               0 <= ParVal <= 8 (grayscale) or 24 (truecolor)
%
%       - 'ParName' = 'comprat' or 'COMPRAT' sets the compression ratio.
%         ParVal must be such that: 0 <= ParVal <= 100.
%
%       2) The second parameter sets the number of classes for
%          quantization:
%       - 'ParName' = 'nbclas' or 'NBCLAS' sets the number of classes.
%         ParVal must be a real number such that: 2 <= ParVal <= 200.
%
%   Display parameter.
%       - 'ParName' = 'plotpar' or 'PLOTPAR' sets the plot parameter.
%         ParVal must be one of the following strings or numbers:
%           'plot' or 0: plots only the compressed image.
%           'step' or 1: displays each step of the encoding process
%                        (only for PCSM methods).
%
%   [COMPRAT,BPP] = WCOMPRESS('c',...) allows also to return the
%    compression ratio COMPRAT and the bit_per_pixel ratio BPP.
%
% Uncompression:
% =============
%	XC = WCOMPRESS('u',SAV_FILENAME) uncompresses the file
%   SAV_FILENAME and returns the image XC. Depending on the
%   initial compressed image, XC can be a 2-D array containing
%   an indexed image or a 3-D array of uint8 containing a
%   truecolor image.
%
%   The directory containing SAV_FILENAME must be on the MATLAB path. If
%   WCOMPRESS does not find the .wtc file on the path, WCOMPRESS changes
%   directory to tempdir and attempts to read the .wtc file from tempdir.
%
%	XC = WCOMPRESS('u',SAV_FILENAME,'plot') plots the
%   uncompressed image.
%
%	XC = WCOMPRESS('u',SAV_FILENAME,'step') shows the
%   step by step uncompression only for PCSM methods.
%
% The behavior of wcompress has changed. This includes:
%   - The default behavior for writing and reading .wtc files. Prior to
%     R2016b, the majority of data written to .wtc files used unit32
%     precision. In R2016b, this was changed to uint64.
%
% If this change in behavior has adversely affected your code, you may
% preserve the previous behavior while compressing with:
%
%   WCOMPRESS('c',X,SAV_FILENAME,COMP_METHOD,'legacy')
%   
%
% Example 1:
%   %--------------------------------------------------------------
%   % This example shows first how to compress a
%   % jpeg image using the 'stw' compression method and
%   % save it to a file.
%   % Then, it shows how to load the stored image from
%   % the file and display the step by step uncompression.
%   %--------------------------------------------------------------
%   wcompress('c','arms.jpg','comp_arms.wtc','stw');
%   wcompress('u','comp_arms.wtc','step');
%
% Example 2:
%   %--------------------------------------------------------------
%   % This example shows first how to compress a
%   % jpeg image using the 'aswdr' compression method and
%   % save it to a file.
%   % During the compression process 3 parameters are used:
%   % - Conversion color (cc) set to Karhunen-Loeve transform 'klt'
%   % - Maximum number of loops for computing (maxloop) set to 11
%   % - Plot type (plotpar) set to step by step display
%   % Then, it shows how to load the stored image from
%   % the file and display the step by step uncompression.
%   %--------------------------------------------------------------
%   [cr,bpp] = wcompress('c','woodstatue.jpg','woodstatue.wtc', ...
%           'aswdr','cc','klt','maxloop',11,'plotpar','step')
%   wcompress('u','woodstatue.wtc','step');
%   delete('woodstatue.wtc')
%
% Example 3:
%   %--------------------------------------------------------------
%   % Compression and uncompression of a grayscale image
%   % and computed MSE and PSNR error values.
%   %
%   % Two measures are commonly used to quantify the error between
%   % two images: the Mean Square Error(MSE) and the Peak Signal
%   % to Noise Ratio (PSNR) which is expressed in decibels.
%   %
%   % This example shows first how to compress the mask image
%   % using the 'spiht' compression method and save it to the file
%   % 'mask.wtc'.
%   % Then, it shows how to load the stored image from the file
%   % 'mask.wtc', uncompress it and delete the file 'mask.wtc'.
%   %--------------------------------------------------------------
%   load mask;
%   [cr,bpp] = wcompress('c',X,'mask.wtc','spiht','maxloop',12)
%   Xc = wcompress('u','mask.wtc');
%   delete('mask.wtc')
%   D = abs(X-Xc).^2;
%   mse = sum(D(:))/numel(X)
%   psnr = 10*log10(255*255/mse)
%   % Display the original and the compressed image
%   colormap(pink(255))
%   subplot(1,2,1); image(X); title('Original image'); axis square
%   subplot(1,2,2); image(Xc); title('Compressed image'); axis square
%
% Example 4:
%   %--------------------------------------------------------------
%   % Compression and uncompression of a truecolor image
%   % and computed MSE and PSNR error values.
%   % Compression parameters are the same as those used for example 3,
%   % but using the 'spiht_3d' method give better performance yet.
%   %--------------------------------------------------------------
%   X = imread('wpeppers.jpg');
%   [cr,bpp] = wcompress('c',X,'wpeppers.wtc','spiht','maxloop',12)
%   Xc = wcompress('u','wpeppers.wtc');
%   delete('wpeppers.wtc')
%   D = abs(double(X)-double(Xc)).^2;
%   mse = sum(D(:))/numel(X)
%   psnr = 10*log10(255*255/mse)
%   % Display the original and the compressed image
%   subplot(1,2,1); image(X); title('Original image'); axis square
%   subplot(1,2,2); image(Xc); title('Compressed image'); axis square
%
%   See also IMREAD, IMWRITE, WMAXLEV, TEMPDIR, MATLABPATH

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 11-Feb-2008.
%   Last Revision: 12-Apr-2012.
%   Copyright 1995-2012 The MathWorks, Inc.

%Check for 'legacy' flag, remove from varargin. Set typeSAVE
[typeSAVE,varargin] = getlegacyoption('legacy',varargin);
nbIN = length(varargin);
option = lower(option(1));
switch lower(option)
    case 'c'	% COMPRESS
        if ischar(varargin{1})
            try
                [X,map,imgFormat] = wloadimages(varargin{1}); %#ok<NASGU>
            catch ME
                throw(ME);
            end
        elseif iscell(varargin{1})
            X = varargin{1}{1};
            map = varargin{1}{2};
        else
            X = varargin{1};
        end
        Sav_filename = varargin{2};
        method_COMP  = varargin{3};
        
        % Default Wavelet Transform Settings (WTS).
        %------------------------------------------
        validateattributes(X,{'numeric'},{'real','nonempty','finite'},...
            'wcompress','X');
        if isrow(X) || iscolumn(X)
            error(message('Wavelet:FunctionArgVal:InvalidXYSizes'));
        end
        sX = size(X);
        
        SS = log2(sX(1:2));
        if any(SS~=fix(SS))
            error(message('Wavelet:divGUIRF:WTC_Pow2_Size'));
        end
        
        if (size(X,3) ~= 1 && size(X,3) ~= 3)
            error(message('Wavelet:FunctionArgVal:InvalidThirdDim'));
        end
        
        
        level_MAX = wmaxlev(sX,'haar');
        wname_DEF   = 'bior4.4';
        extMode_DEF = 'per';
        
        % Other Defaults.
        %----------------
        ColCONV_DEF = 'rgb';        % Default Color Transform.
        stepFLAG_DEF = NaN;         % Default for plot param (none).
        nbclas_DEF  = 75;
        switch method_COMP
            case {'gbl_mmc_h','gbl_mmc_f'}
                methodPARAMS_DEF = struct('percfs',0.05,'nbclas',nbclas_DEF);
                level_DEF = round(level_MAX/2);
            case 'lvl_mmc'
                methodPARAMS_DEF = 0.25;  % Default Fixed_BitRate
                level_DEF = round(level_MAX/2);
            otherwise
                methodPARAMS_DEF = [];
                level_DEF = level_MAX;
        end
        MaxLoop_DEF = level_DEF+2;
        
        % Initialization of parameters.
        %------------------------------
        wname = [];
        level = [];
        extMode = [];
        bpp     = [];
        comprat = [];
        percfs  = [];
        nbcfs   = [];
        nbclas  = [];
        threshold = [];
        MaxLoop = [];
        methodPARAMS = [];
        ColCONV = [];
        stepFLAG = [];
        imgTypeTRANS = [];
        
        % Check arguments.
        %-----------------
        for k=4:2:nbIN
            argNAM = varargin{k};
            argVAL = varargin{k+1};
            switch lower(argNAM)
                case 'it' ,    imgTypeTRANS = argVAL;
                case 'wname' , wname = argVAL;
                case 'level' , level = argVAL;
                case 'wt'
                    if iscell(argVAL)
                        switch length(argVAL)
                            case 1 ,  wname = argVAL{1};
                            case 2 , [wname,level] = deal(argVAL{:});
                            case 3 , [wname,level,extMode] = deal(argVAL{:});
                        end
                    elseif isstruct(argVAL)
                        fn = lower(fieldnames(argVAL));
                        for j = 1:length(fn)
                            currFN = fn{j}(1:3);
                            switch currFN
                                case 'wna' , wname = argVAL.(fn{j});
                                case 'lev' , level = argVAL.(fn{j});
                                case 'ext' , extMode = argVAL.(fn{j});
                            end
                        end
                    end
                case 'cc' ,      ColCONV = varargin{k+1};
                case 'bpp'     , bpp = varargin{k+1};
                case 'comprat' , comprat = varargin{k+1};
                case 'percfs' ,  percfs  = varargin{k+1};
                case 'nbclas' ,  nbclas  = varargin{k+1};
                case 'thr'    ,  threshold  = varargin{k+1};
                case 'maxloop' , MaxLoop = varargin{k+1};
                case 'params'  , methodPARAMS = varargin{k+1};
                case 'plotpar'
                    if isequal(argVAL,'plot') || isequal(argVAL,0)
                        stepFLAG = 0;
                    elseif isequal(argVAL,'step') || isequal(argVAL,1)
                        stepFLAG = 1;
                    elseif isequal(argVAL,2)
                        stepFLAG = 2;
                    else
                        stepFLAG = NaN;
                    end
            end
        end
        if isempty(wname) ,   wname = wname_DEF; end
        if isempty(level) ,   level = level_DEF; end
        if isempty(extMode) , extMode = extMode_DEF; end
        if isempty(ColCONV),  ColCONV = ColCONV_DEF; end
        if isempty(stepFLAG) , stepFLAG = stepFLAG_DEF; end
        
        if level>level_DEF
            level = level_DEF;
        end
        
        
        
        
        % Image type transform and properties.
        %-------------------------------------
        if ~isempty(imgTypeTRANS)
            switch imgTypeTRANS(1)
                case 'g' , X = wconvimg('col2idx',X);
                case 'c' , X = wconvimg('idx2col',X,map);
            end
            sX = size(X);
        else
            if exist('map','var') && ~isempty(map) && ...
                    ~isequal(map(:,1),map(:,2))
                X = wconvimg('idx2col',X,map);
                sX = size(X);
            end
        end
        nb_Cfs = prod(sX);
        if length(sX)==2 , nbPlan = 1; else  nbPlan = 3; end
        
        
        % Compress image with the selected method.
        %------------------------------------------
        switch method_COMP
            case {'gbl_mmc_h','gbl_mmc_f'}
                if isempty(nbclas) , nbclas = nbclas_DEF; end
                if isempty(methodPARAMS)
                    if ~isempty(threshold)
                        methodPARAMS = {threshold,nbclas};
                    else
                        okParams = false;
                        if ~isempty(bpp)
                            typeARG ='bpp'; valARG = bpp;
                        elseif ~isempty(comprat)
                            typeARG ='comprat'; valARG = comprat;
                        elseif ~isempty(nbcfs)
                            typeARG ='nbcfs'; valARG = nbcfs;
                        elseif ~isempty(percfs)
                            typeARG ='percfs'; valARG = percfs;
                        else
                            okParams = true;
                            methodPARAMS = methodPARAMS_DEF;
                        end
                        if ~okParams
                            [~,nb_Kept_Cfs] = getcompresspar(method_COMP, ...
                                nb_Cfs,nbPlan,typeARG,valARG);
                            methodPARAMS = ...
                                struct('nbcfs',nb_Kept_Cfs,'nbclas',nbclas);
                        end
                    end
                else
                    if isstruct(methodPARAMS) && ...
                            ~isfield(methodPARAMS,'nbclas')
                        methodPARAMS.nbclas = nbclas;
                    end
                end
                Encoded_wtbx_DEC = wtcmngr('enc',typeSAVE,method_COMP,...
                    X,{level,wname,extMode},methodPARAMS,ColCONV);
                
            case 'lvl_mmc'
                if isempty(methodPARAMS)
                    if ~isempty(bpp)
                        methodPARAMS = bpp;
                    elseif ~isempty(comprat)
                        bpp = (comprat*8*size(X,3))/100;
                        methodPARAMS = bpp;
                    else
                        methodPARAMS = methodPARAMS_DEF;
                    end
                end
                Encoded_wtbx_DEC = wtcmngr('enc',typeSAVE,method_COMP,...
                    X,{level,wname,extMode},methodPARAMS,ColCONV);
                
            case {'ezw','spiht','spiht_3d','wdr','aswdr','stw'}
                if isempty(MaxLoop)
                    if ~isempty(bpp)
                        [~,MaxLoop,~,comprat] = getcompresspar(...
                            method_COMP,nb_Cfs,nbPlan,'bpp',bpp); %#ok<NASGU>
                    elseif ~isempty(comprat)
                        [~,MaxLoop,~,comprat] = getcompresspar(...
                            method_COMP,nb_Cfs,nbPlan,'comprat',comprat); %#ok<NASGU>
                    else
                        MaxLoop = MaxLoop_DEF;
                    end
                end
                Encoded_wtbx_DEC = wtcmngr('enc',typeSAVE,method_COMP,X, ...
                    wname,level,extMode,MaxLoop,ColCONV,stepFLAG);
                
        end
        fileSize = wtcmngr('save',typeSAVE,Sav_filename,method_COMP,Encoded_wtbx_DEC);
        
        % Compute Compression Ratio.
        %--------------------------
        varargout{1} = 100*fileSize/numel(X);           % Compression Ratio
        varargout{2} = (fileSize*8*size(X,3))/numel(X); % Bits Per Pixel
        
    case 'u'    % UNCOMPRESS
        inputFile = varargin{1};
        stepFLAG = NaN;
        if nbIN>1
            plotPARAM = varargin{2};
            if isequal(plotPARAM,'plot') || isequal(plotPARAM,0)
                stepFLAG = 0;
            elseif isequal(plotPARAM,'step') || isequal(plotPARAM,1)
                stepFLAG = 1;
            elseif isequal(plotPARAM,2)
                stepFLAG = 2;
            else
                stepFLAG = NaN;
            end
        end
        X_decoded = wtcmngr('read',typeSAVE,inputFile,stepFLAG);
        varargout{1} = X_decoded;
end

function [typeSAVE,arglist] = getlegacyoption(legacyflag,arglist)

found = false;
typeSAVE = 3;
iarg = 1;
while iarg <= numel(arglist)
  arg = arglist{iarg};
  if ischar(arg) && isrow(arg)
    matches = find(strncmpi(arg,legacyflag,length(arg))); %#ok<EFIND>
    if ~isempty(matches)
      if ~found
        found = true;
        typeSAVE = 2;
        arglist(iarg) = [];
      
      end
    else
      iarg = iarg + 1;
    end
  else
   iarg = iarg + 1;
  end
end

