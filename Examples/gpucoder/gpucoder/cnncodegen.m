function cnncodegen( net, varargin )
%CNNCODEGEN Generate CUDA code and build static library for a given SeriesNetwork
%
%   CNNCODEGEN(net) generates CUDA/C/C++ code from the specified
%   SeriesNetwork, 'net', using default values for all properties.
%
%
%   CNNCODEGEN(net, 'PropertyName', PropertyValue, ...) generates CUDA/C/C++
%   from the specified SeriesNetwork, 'net', explicitly specifying one or
%   more code generation options as property/value pairs.
%
%
%   Possible property-value pairs include:
%
%
%   'codegenonly'                        Boolean flag that, when enabled,
%                                        will generate code without
%                                        generating a makefile and building.
%                                        Default value is 0 (false).
%
%
%   'batchsize'                          Integer value specifying the
%                                        number of observations to operate
%                                        on in a single call to
%                                        network predict. When calling
%                                        network->predict(), the
%                                        size of the input data
%                                        must match the 'batchsize' value
%                                        specified during cnncodegen.
%                                        Default value is 1.
%
%   'targetarch', ['host' | 'tx1' | 'tx2']  Specify the target architecture to
%                                           build for. 'host' will generate code
%                                           for the current host device. 'tx1'
%                                           will generate code for the NVIDIA
%                                           Tegra X1 board. 'tx2' will generate
%                                           code for the NVIDIA Tegra X2 board.
%                                           Default value is 'host'.
%
%   'computecapability'                  String specifying the
%                                        compute capability to
%                                        compile with. Argument
%                                        should take the format
%                                        of #.#, such as 5.3.
%
%   'targetlib'                         String specifying the platform type.
%                                        Supported values are 'cudnn','mkldnn',
%                                        'tensorrt','arm-compute'.
%                                        Default value is 'cudnn'.
%
%   'targetparams'                       Structure specifying the additional
%                                        properties for tensorrt target platform.
%                                        Structure value has the following fields,
%                                        - DataType : 'INT8' or 'FP32'.
%                                        - DataPath : location of
%                                                     image dataset used during calibration.
%                                        - NumCalibrationBatches : number of batches for tensorRT int8 calibration.
%                                         Default values are :
%                                         struct with fields:
%                                                DataType: 'FP32'
%                                                DataPath: ''
%                                                NumCalibrationBatches: ''
%
%   See also codegen, coder.loadDeepLearningNetwork.
%
%
%
%   Copyright 2016-2017 The MathWorks, Inc.
%

    gpucoder.internal.cnncodegenpriv(net, varargin{:});

end

% LocalWords:  gpucoder batchsize Cnn targetdir targetfile cnn
% LocalWords:  targetarch tk cudnnversion cnnbuild
