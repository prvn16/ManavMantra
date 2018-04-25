function gpuFFT = isGpuFFT(aOption)
    if (~isequal(aOption, []) && ...
        ~isempty(aOption.getConfigProp('GpuConfig')) && ...
        aOption.getConfigProp('GpuConfig').Enabled && ...
        aOption.getConfigProp('GpuConfig').EnableCUFFT)
        gpuFFT = true;
    else
        gpuFFT = false;
    end
end
