% AstraBackwardProjector Abstraction of a CT forward matrix run by ASTRA.
% 
% This operator acts as a matrix and can compute fast and memory efficient
% matrix-vector products.
%
% The AstraProjectors support the following functions
%   Multiplication:         * or mtines().
%   Matrix represntation:   full() or sparse().
%   Size output:            size().
classdef AstraBackwardProjector < AstraProjector

    methods
        % Constructor
        function B = AstraBackwardProjector(num_angles, num_pixels, ...
                num_detectors, projection_id, projection_geometry, ...
                volume_geometry, GPU)
            % Input:
            %   num_angles:          Number of view angles
            %   num_pixels:          Number of pixels in column/row of 
            %                        image x (square image)  
            %   num_detectors:       Number of detector elements
            %   projection_id:       ASTRA id
            %   projection_geometry: ASTRA struct
            %   volume_geometry:     ASTRA struct
            %   GPU:                 Boolean indicating use of GPU

            % Store sizes of the CT problem
            B.num_angles     = num_angles;
            B.num_pixels     = num_pixels;
            B.num_detectors  = num_detectors;

            % Store references to ASTRA objects
            B.volume_geometry        = volume_geometry;
            B.projection_id          = projection_id;
            B.projection_geometry    = projection_geometry;

            if GPU
                B.cfg = astra_struct('BP_CUDA');
            else
                B.cfg = astra_struct('BP');
            end
            B.cfg.ProjectorId = projection_id;

        end

        
        function sz = size(self, dim)
            % sz = size(self, [dim])
            %
            % Return the size of the operator for, optionally, the
            % specified dimension.
            
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

        function y = mtimes(B, b)
            % mtimes Compute backward projection of a CT image.
            % The backward projection is computed as a matrix 
            % multiplication B*b.
            %
            % Inputs:
            %   B: Back projection operator
            %   b: Sinogram as a vector
            %
            % Output:
            %   y: CT image as a vector

            
            % Size check
            if size(B, 2) ~= length(b)
                error("Dimension mismatch in forward projection.")
            end

            % Call ASTRA
            % Set up sinogram in ASTRA
            sinogram_id = astra_mex_data2d('create', '-sino', ...
                B.projection_geometry, reshape(b,B.num_angles, B.num_detectors));

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
            Bb = astra_mex_data2d('get', reconstruction_id);
            y = Bb(:);

            % Delete the ASTRA memory that was allocated
            astra_mex_data2d('delete', sinogram_id, reconstruction_id);
            astra_mex_algorithm('delete', bp_id);
        end
    end

end