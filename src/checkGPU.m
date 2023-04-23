function checkGPU(use_gpu)

    % Count the number of GPUs visible by MATLAB
    num_gpu = gpuDeviceCount("all");

    gpu_found = num_gpu > 0;

    % Check if user requests to use a GPU
    if ~gpu_found && use_gpu
        error("No GPU found, aborting setup.")
    end

    return
end