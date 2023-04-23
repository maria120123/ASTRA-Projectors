function gpu_found = checkGPU()

    % Count the number of GPUs visible by MATLAB
    num_gpu = gpuDeviceCount("all");

    gpu_found = num_gpu > 0;

    return
end