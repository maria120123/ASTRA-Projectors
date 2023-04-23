classdef AstraBackwardProjector < AstraProjector

    methods
        % Constructor
        function B = AstraBackwardProjector(num_angles, num_pixels, ...
                num_detectors, projection_id, projection_geometry, ...
                volume_geometry)
            % Input:
            %   projection_geometry: 
            %   volume_geometry:
            %   num_angles: Number of view angles
            %   num_detectors:   Number of detector elements
            %   projection_id: 

            % Store sizes of the CT problem
            B.num_angles     = num_angles;
            B.num_pixels     = num_pixels;
            B.num_detectors  = num_detectors;

            % Store references to ASTRA objects
            B.volume_geometry        = volume_geometry;
            B.projection_geometry    = projection_geometry;

            % --- INSERT CODE HERE ---
            B.cfg = astra_struct('BP_CUDA');
            B.cfg.ProjectorId = projection_id;

        end

        % Return the size of the operator
        function sz = size(self, dim)
            m = self.num_pixels * self.num_pixels;
            n = self.num_angles * self.num_detectors;

            dims = [m, n];

            if nargin == 1
                sz = dims;
            else
                sz = dims(dim);
            end

            return;
        end

        % Matrix multiplication B*b
        function y = mtimes(B, b)
            % Inputs:
            %   B: 
            %   b:
            %
            % Output:
            %   y: Back projection B*b

            
            % Size check
            if size(B, 2) ~= length(b)
                error("Dimension mismatch in forward projection.")
            end

            % Call ASTRA
            % Set up sinogram in ASTRA
            sinogram_id = astra_mex_data2d('create', '-sino', ...
                B.projection_geometry, reshape(b,B.num_angles, B.num_dets));

            % Set up memory for reconstruction in ASTRA
            reconstruction_id = astra_mex_data2d('create', '-vol', ...
                B.volume_geometry, 0);

            % Initialize ASTRA algorithm
            B.cfg.ProjectionDataId = sinogram_id;
            B.cfg.ReconstructionDataId = reconstruction_id;
            bp_id = astra_mex_algorithm('create', B.cfg);

            % Do matrix-vector multiplication
            astra_mex_algorithm('run', bp_id);

            % Extract results
            Bb = astra_mex_data2d('get', recon_id);
            y = Bb(:);

            % Delete the ASTRA memory that was allocated
            astra_mex_data2d('delete', sinogram_id, volume_id);
            astra_mex_algorithm('delete', fp_id);
        end
    end

end