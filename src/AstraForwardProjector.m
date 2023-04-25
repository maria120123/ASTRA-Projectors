classdef AstraForwardProjector < AstraProjector

    methods
        % Constructor
        function A = AstraForwardProjector(num_angles, num_pixels, ...
                num_detectors, projection_id, projection_geometry, ...
                volume_geometry)
            % Input:
            %   projection_geometry: 
            %   volume_geometry: 
            %   num_pixels:          Number of pixels in a row/coloumn
            %   projection_id:

            % Store sizes of the CT problem
            A.num_angles     = num_angles;
            A.num_pixels     = num_pixels;
            A.num_detectors  = num_detectors;

            % Store references to ASTRA objects
            A.volume_geometry        = volume_geometry;
            A.projection_geometry    = projection_geometry;

            % Create forward projection algorithm
            A.cfg = astra_struct('FP');
            A.cfg.ProjectorId = projection_id;
        end

        % Return the size of the operator
        function sz = size(self, dim)
            m = self.num_angles * self.num_detectors;
            n = self.num_pixels * self.num_pixels;

            dims = [m, n];

            if nargin == 1
                sz = dims;
            else
                sz = dims(dim);
            end

            return;
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