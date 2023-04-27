% AstraForwardProjector Abstraction of a CT forward matrix run by ASTRA.
% 
% This operator acts as a matrix and can compute fast and memory efficient
% matrix-vector products.
%
% The AstraProjectors support the following functions
%   Multiplication:         * or mtines().
%   Matrix represntation:   full() or sparse().
%   Size output:            size().
classdef AstraForwardProjector < AstraProjector

    methods
        % Constructor
        function A = AstraForwardProjector(num_angles, num_pixels, ...
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
            A.num_angles     = num_angles;
            A.num_pixels     = num_pixels;
            A.num_detectors  = num_detectors;

            % Store references to ASTRA objects
            A.volume_geometry        = volume_geometry;
            A.projection_id          = projection_id;
            A.projection_geometry    = projection_geometry;

            % Create forward projection algorithm
            if GPU
                A.cfg = astra_struct('FP_CUDA');
            else
                A.cfg = astra_struct('FP');
            end
            A.cfg.ProjectorId = projection_id;
        end

        % Return the size of the operator
        function sz = size(self, dim)
            % sz = size(self, [dim])
            %
            % Return the size of the operator for, optionally, the
            % specified dimension.

            m = self.num_angles * self.num_detectors;
            n = self.num_pixels * self.num_pixels;

            dims = [m, n];

            if nargin == 1
                sz = dims;
            else
                sz = dims(dim);
            end
        end

        function sparse_matrix = sparse(A)
            % sparse create sparse matrix.
            % sparse_matrix = sparse(A) converts an ASTRA projector into a
            % sparse matrix 
            %
            % Inputs:
            %   A: AstraForwardProjector
            %
            % Outputs:
            %   sparse_matrix: Sparse representation of the forward
            %   operator A.
            
            matrix_id = astra_mex_projector('matrix', A.projection_id);
            sparse_matrix = astra_mex_matrix('get', matrix_id);
            astra_mex_matrix('delete', matrix_id);
        end

        
        function y = mtimes(A, x)
            % mtimes Compute forward projection of a CT image.
            % The forward projection is computed as a matrix 
            % multiplication A*x.
            %
            % Inputs:
            %   A: Forward projection operator
            %   x: CT image as a vector
            %
            % Output:
            %   y: Sinogram as a vector

            
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