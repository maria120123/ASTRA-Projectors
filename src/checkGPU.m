function checkGPU(use_gpu)
%checkGPU  returns 'true' if GPU-use is required but a GPU is not available
%
% Requires that the Paralle Computing Toolbox is installed.

% Written by Maria Knudsen, April 28, 2023.

    % Internal error codes
    passed          = 10;
    missing_package = 11;
    missing_gpu     = 12;

    if use_gpu
        % Count the number of GPUs visible by MATLAB
        try
            num_gpu = gpuDeviceCount("available");

            % Check if a GPU is available
            if num_gpu == 0
                error_check = missing_gpu;
            else
                error_check = passed;
            end
        catch
            error_check = missing_package;
        end

        % Pass errors to the user if any occured
        if error_check == missing_gpu
            error("A GPU is not available.")
        elseif error_check == missing_package
            error("Parallel Computing Toolbox is not installed, " + ...
                "unable to use a GPU.")
        end
    end

    return
end