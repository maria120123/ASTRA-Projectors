classdef AstraBackwardProjector < AstraProjector

    methods
        % Constructor
        function B = AstraBackwardProjector()

            % Check if GPU requirements are fulfilled
            checkGPU(use_gpu);

            % --- INSERT CODE HERE ---

        end

        % Matrix multiplication B*b
        function y = mtimes(b,vol_geom,proj_geom,num_angles,num_dets,proj_id)
            % Inputs:
            %   b:
            %   vol_geom: 
            %   proj_geom: Projection geometry 'parallel' or 'fanflat'
            %   num_angles: Number of view angles
            %   num_dets:   Number of detector elements
            %   proj_id:
            %
            % Output:
            %   y: Back projection B*b

            
            % Size check

            % Call ASTRA
            % --- INSERT CODE HERE ---
            sinogram_id = astra_mex_data2d('create', '-sino', proj_geom, reshape(b,num_angles,num_dets));
            recon_id = astra_mex_data2d('create', '-vol', vol_geom, 0);

            cfg = astra_struct('BP_CUDA');
            cfg.ProjectorId = proj_id;
            cfg.ProjectionDataId = sinogram_id;
            cfg.ReconstructionDataId = recon_id;

            bp_id = astra_mex_algorithm('create', cfg);
            astra_mex_algorithm('run', bp_id);
            Bb = astra_mex_data2d('get', recon_id);
            y = Bb(:);

        end
    end

end