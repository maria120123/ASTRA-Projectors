classdef AstraBackwardProjector < AstraProjector

    methods
        % Constructor
        function B = AstraBackwardProjector()

            % Check if GPU requirements are fulfilled
            checkGPU(use_gpu);

            % --- INSERT CODE HERE ---

        end

        % Matrix multiplication
        function y = mtimes(B, x)
            % Size check

            % Call ASTRA
            % --- INSERT CODE HERE ---
        end
    end

end