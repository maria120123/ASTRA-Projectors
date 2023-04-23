classdef AstraForwardProjector < AstraProjector

    methods
        % Constructor
        function A = AstraForwardProjector(self, ....)
            self.bla = 1
            self.
            

            % Check if GPU requirements are fulfilled
            checkGPU(use_gpu);


            % --- INSERT CODE HERE ---
            cfg = astra_struct('FP_CUDA');
            cfg.ProjectorId = proj_id;
        end

        % Matrix multiplication A*x
        function y = mtimes(A, x)
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

            % Allocate memory
            % Set up sinogram in ASTRA
            sinogram_id = astra_mex_data2d('create', '-sino', ...
                projection_geometry, 0);

            % Set up memory for reconstruction in ASTRA
            volume_id = astra_mex_data2d('create', '-vol', ...
                A.vol_geom, reshape(x, A.num_pixels, A.num_pixels));

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