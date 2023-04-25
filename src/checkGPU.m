function ier = checkGPU(use_gpu)
    ier = 0;

    if use_gpu
        % Count the number of GPUs visible by MATLAB
        try
            num_gpu = gpuDeviceCount("all");
        catch
            ier = 1;
            %warning("Automatic check for present GPU failed. " + ...
            %    "Ensure that your computer has a CUDA compatible GPU.");
            return
        end
        gpu_found = num_gpu > 0;
    
        % Check if user requests to use a GPU
        if ~gpu_found && use_gpu
            error("No GPU found, aborting setup.")
        end
    end

    return
end