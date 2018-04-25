classdef Warper
    
    % Internal, codegen version of images.geotrans.Warper
    
    % Copyright 2017 The MathWorks, Inc.
    
    %#codegen
    
    properties (SetAccess = private)
        InputSize = [];
        OutputSize = [];
        Interpolation = [];
        FillValue = [];
    end
    
    properties (Access = private)
        UseIPP = true; % Not used. Here for parity with toolbox version.
        SourceX = [];
        SourceY = [];
    end
    
    methods
        function warper = Warper(varargin)
            narginchk(2, 7);
            [tform, inputSizeOrRef, OutputReference, FillValue, Interpolation, sourceX, sourceY] ...
                = warper.parseInputsCG(varargin{:});
                        
            if isempty(sourceX)
                if isa(inputSizeOrRef,'imref2d')
                    warper.InputSize = inputSizeOrRef.ImageSize(1:2);
                    refIn  = inputSizeOrRef;
                else
                    warper.InputSize = inputSizeOrRef(1:2);
                    refIn  = imref2d(warper.InputSize);
                end
                
                if isempty(OutputReference)
                    refOut = images.spatialref.internal.applyGeometricTransformToSpatialRef(refIn,tform);
                else
                    refOut = OutputReference;
                end
                
                [dsourceX, dsourceY] = images.geotrans.internal.getSourceMappingInvertible2d(refIn, tform, refOut);
                warper.SourceX = single(dsourceX);
                warper.SourceY = single(dsourceY);
                
            else
                warper.SourceX = sourceX;
                warper.SourceY = sourceY;
            end
            
            warper.Interpolation = coder.const(Interpolation);
            warper.OutputSize = size(warper.SourceX);
            warper.FillValue = FillValue;                        
        end
        
        function out = warp(warper, im)
            coder.internal.errorIf(~(ndims(im)<4),...
                'images:Warper:expected2or3d');
            coder.internal.errorIf(~isempty(warper.InputSize) && ~isequal([size(im,1), size(im,2)], warper.InputSize),...
                'images:Warper:inconsistentSize');
            
            validateattributes(im,...
                {'uint8', 'int16','single'},...
                {'nonsparse'},...
                mfilename, 'A');
                        
            out = coder.nullcopy(...
                zeros([warper.OutputSize, size(im,3)],'single'));
                       
            for pInd = 1:size(im,3)
                switch warper.Interpolation
                    case 'nearest'
                        out(:,:,pInd) = interp2(single(im(:,:,pInd)),...
                            warper.SourceX, warper.SourceY,...
                            'nearest', warper.FillValue);
                    case 'linear'
                        out(:,:,pInd) = interp2(single(im(:,:,pInd)),...
                            warper.SourceX, warper.SourceY,...
                            'linear', warper.FillValue);
                    case 'cubic'
                        out(:,:,pInd) = interp2(single(im(:,:,pInd)),...
                            warper.SourceX, warper.SourceY,...
                            'cubic', warper.FillValue);
                    otherwise
                        out(:,:,pInd) = interp2(single(im(:,:,pInd)),...
                            warper.SourceX, warper.SourceY,...
                            'linear', warper.FillValue);
                end
            end
            out = cast(out, 'like',im);
        end
    end
    
    methods (Access = private)
        function [tform, inputSizeOrRef, OutputReference, FillValue, Interpolation, sourceX, sourceY] = parseInputsCG(~, varargin)
            coder.internal.prefer_const(varargin{:});
            
            % narginchk in caller ensures we have two inputs.
            if isnumeric(varargin{1})
                sourceX = varargin{1};
                checkSourceXY(sourceX, 'sourceX');
                sourceY = varargin{2};
                checkSourceXY(sourceY, 'sourceY');
                inputSizeOrRef = [];
                % Need placeholder values for codegen, values are NOT used.
                tform = affine2d([1 0 0 ;0 1 0; 0 0 1]);                
            else
                tform = varargin{1};
                checktform(tform);
                inputSizeOrRef = varargin{2};
                checkInputSizeOrRef(inputSizeOrRef);
                sourceX = single([]);
                sourceY = single([]);
            end
            
            pvStartInd = 3;
            if numel(varargin)>2 && isa(varargin{3},'imref2d') && ~isnumeric(varargin{1})
                % OutputReference not allowed with source* syntax
                OutputReference = varargin{3};
                checkOutputRef(OutputReference);
                pvStartInd = pvStartInd + 1;
            else
                OutputReference = [];
            end
            
            % Parse PV
            defaultFillValue = uint8(0);
            defaultInterpolation = 'linear';
            params = struct(...
                'FillValue', uint32(0),...
                'Interpolation', uint32(0));
            options = struct(...
                'CaseSensitivity',false, ...
                'StructExpand',   true, ...
                'PartialMatching',true);
            optarg = eml_parse_parameter_inputs(params,options, varargin{pvStartInd:end});
            
            FillValue = eml_get_parameter_value(...
                optarg.FillValue,...
                defaultFillValue,...
                varargin{pvStartInd:end});
            checkFillValues(FillValue);
            
            Interpolation = eml_get_parameter_value(...
                optarg.Interpolation,...
                defaultInterpolation,...
                varargin{pvStartInd:end});
            checkInterpolation(Interpolation);
            Interpolation = validatestring(Interpolation,...
                {'nearest', 'linear', 'cubic'}, mfilename);
        end
    end
    
end




%% Validation functions
function tf = checktform(tform)
validateattributes(tform,...
    {'affine2d', 'projective2d'},...
    {'scalar'}, ...
    mfilename, 'tform');
tf = true;
end

function tf = checkInputSizeOrRef(inputSizeOrRef)
if isa(inputSizeOrRef,'imref2d')
    validateattributes(inputSizeOrRef,...
        {'imref2d'},...
        {'scalar'},...
        mfilename, 'InputReference');
    coder.internal.errorIf(isa(inputSizeOrRef,'imref3d'),...
        'images:Warper:expected2or3d');
else
    % MXN, or MxNxP
    validateattributes(inputSizeOrRef,...
        {'numeric'},...
        {'nonsparse','integer', 'positive', 'finite'},...
        mfilename, 'InputSize');
    coder.internal.errorIf(~(numel(inputSizeOrRef)<4),...
        'images:Warper:expected2or3d');
end
tf = true;
end

function tf = checkSourceXY(srcxy, varName)
validateattributes(srcxy,...
    {'single'},...
    {'2d','finite'},...
    mfilename, varName);
tf = true;
end

function tf = checkOutputRef(outputRef)
validateattributes(outputRef,...
    {'imref2d'},...
    {'scalar'},...
    mfilename, 'OutputReference');
coder.internal.errorIf(isa(outputRef,'imref3d'),...
    'images:Warper:expected2or3d');
tf = true;
end

function tf = checkInterpolation(interpString)
validateattributes(interpString,...
    {'char','string'},...
    {'nonsparse'},...
    mfilename,'Interpolation');
tf = true;
end

function tf = checkFillValues(fillValue)
validateattributes(fillValue,...
    {'numeric'},...
    {'scalar', 'real'}, ...
    mfilename, 'FillValue');
tf = true;
end
