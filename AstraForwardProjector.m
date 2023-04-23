classdef AstraForwardProjector < AstraProjector

    methods
        % Constructor
        function A = AstraForwardProjector()

            % Check if GPU requirements are fulfilled
            checkGPU(use_gpu);


            % --- INSERT CODE HERE ---

        end

        % Matrix multiplication A*x
        function y = mtimes(x,vol_geom,proj_geom,num_pixels,proj_id)
            % Inputs:
            %   x:
            %   vol_geom: 
            %   proj_geom: Projection geometry 'parallel' or 'fanflat'
            %   num_pixels: Number of pixels in a row/coloumn
            %   proj_id:    
            %
            % Output:
            %   y: Forward projection A*x

            
            % Size check


            % Call ASTRA
            % --- INSERT CODE HERE ---
            volume_id = astra_mex_data2d('create', '-vol', vol_geom, reshape(x,num_pixels,num_pixels));
            sinogram_id = astra_mex_data2d('create', '-sino', proj_geom, 0);

            cfg = astra_struct('FP_CUDA');

            cfg.ProjectorId = proj_id;            % Id to forward projector A
            cfg.ProjectionDataId = sinogram_id;   % Id to sinogram b (what A should be multiplied with???)
            cfg.VolumeDataId = volume_id;         % Id to size/volume of output

            fp_id = astra_mex_algorithm('create', cfg);
            astra_mex_algorithm('run', fp_id);
            sinogram = astra_mex_data2d('get', sinogram_id);
            y = sinogram(:);

            astra_mex_data2d('delete', sinogram_id, volume_id);
            astra_mex_algorithm('delete', fp_id);
        end

    end

end