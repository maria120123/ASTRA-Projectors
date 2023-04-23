classdef AstraForwardProjector < AstraProjector

    methods
        % Constructor
        function A = AstraForwardProjector(self, projection_geometry,... 
                volume_geometry, num_pixels, projection_id)
            % Input:
            %   projection_geometry: 
            %   volume_geometry: 
            %   num_pixels:          Number of pixels in a row/coloumn
            %   projection_id:

            % Store sizes of the CT problem
            self.num_angles     = num_angles;
            self.num_pixels     = num_pixels;
            self.num_detectors  = num_detectors;

            % Store references to ASTRA objects
            self.volume_geometry        = volume_geometry;
            self.projection_geometry    = projection_geometry;

            % Create forward projection algorithm
            self.cfg = astra_struct('FP_CUDA');
            self.cfg.ProjectorId = projection_id;
        end

        % Matrix multiplication A*x
        function y = mtimes(A, x)
            % Inputs:
            %   A: Struct
            %   x: CT image as a vector
            %
            % Output:
            %   y: Forward projection multiplication

            
            % Size check
            if size(A, 2) ~= length(x)
                error("Dimension mismatch in forward projection.")
            end

            % Allocate memory
            % Set up sinogram in ASTRA
            sinogram_id = astra_mex_data2d('create', '-sino', ...
                A.projection_geometry, 0);

            % Set up memory for reconstruction in ASTRA
            volume_id = astra_mex_data2d('create', '-vol', ...
                A.volume_geometry, reshape(x, A.num_pixels, A.num_pixels));

            % Initialize ASTRA algorithm
            A.cfg.ProjectionDataId = sinogram_id;
            A.cfg.VolumeDataId = volume_id;

            fp_id = astra_mex_algorithm('create', A.cfg);

            % Call ASTRA
            astra_mex_algorithm('run', fp_id);

            % Extract results
            sinogram = astra_mex_data2d('get', sinogram_id);
            y = sinogram(:);

            % Delete the ASTRA memory that was allocated
            astra_mex_data2d('delete', sinogram_id, volume_id);
            astra_mex_algorithm('delete', fp_id);
        end

    end

end