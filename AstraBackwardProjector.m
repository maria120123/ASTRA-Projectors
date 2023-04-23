classdef AstraBackwardProjector < AstraProjector

    methods
        % Constructor
        function B = AstraBackwardProjector(self, projection_geometry,... 
                volume_geometry, num_angles, num_detectors, projection_id)
            % Input:
            %   projection_geometry: 
            %   volume_geometry:
            %   num_angles: Number of view angles
            %   num_detectors:   Number of detector elements
            %   projection_id: 

            self.projection_geometry = projection_geometry;
            self.volume_geometry = volume_geometry;
            self.num_angles = num_angles;
            self.num_detectors = num_detectors;

            % --- INSERT CODE HERE ---
            self.cfg = astra_struct('BP_CUDA');
            self.cfg.ProjectorId = projection_id;

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