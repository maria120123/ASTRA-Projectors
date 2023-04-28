% AstraProjector Superclass of forward and backward-projectors wrapping
% ASTRA calls.
classdef AstraProjector

    properties
        % Size of operators
        num_angles;
        num_detectors;
        num_pixels;

        % Astra stuff
        projection_id;
        projection_geometry;
        volume_geometry;
        cfg;                % ASTRA algorithm struct
    end

    % Methods that are common for both forward and back projectors
    methods

        % Return a sparse matrix of the projector
        function sparse_matrix = sparse(AB)
            % sparse create sparse matrix.
            % sparse_matrix = sparse(A) converts an ASTRA projector into a
            % sparse matrix 
            %
            % Inputs:
            %   A: AstraProjector
            %nargin
            % Outputs:
            %   sparse_matrix: Sparse representation of the forward
            %   operator A.

            % Size of the matrix
            sz = size(AB);
            m = double(sz(1)); n = double(sz(2));

            % Allocate unit vector
            e = zeros(n, 1);

            num_nz = 0;
            tol = 1e-6; % Tolerance for when a number is nonzero

            % Status text
            f = waitbar(0, 'starting');

            % Count the number of nonzeroes
            % ----------------------------------------------------
            for i = 1:n
                if mod(i, 500) == 0
                    prog = sprintf("\rCounting nonzeroes: %.2f%%", ...
                        round(i/n * 100, 1, 'decimals'));
                    waitbar(i/n, f, prog)
                end
                % Set unitvector
                e(i) = 1.0;

                % Perform matrix vector product (get the i'th column)
                y = AB * e;

                % Count the number of nonzeroes
                num_nz = num_nz + nnz(y > tol);

                % Unset unit vector
                e(i) = 0.0;
            end

            % Fill the matrix
            % ----------------------------------------------------
            rows = zeros(num_nz, 1);
            cols = zeros(num_nz, 1);
            vals = zeros(num_nz, 1);

            % Reset counter
            cnt = 1;

            for i = 1:n
                if mod(i, 500) == 0
                    prog = sprintf("\rFilling matrix: %.2f%%", ...
                        round(i/n * 100, 1, 'decimals'));
                    waitbar(i/n, f, prog)
                end
                % Set unitvector
                e(i) = 1.0;

                % Perform matrix vector product (get the i'th column)
                y = AB * e;

                % Find the nonzero indices
                [rw, ~, vl] = find(y);
                num_nz = length(rw);

                % Save sparse components
                id_end = cnt+num_nz-1;
                rows(cnt : id_end) = rw;
                cols(cnt : id_end) = i;
                vals(cnt : id_end) = vl;

                % Increment counter
                cnt = cnt + num_nz;

                % Unset unit vector
                e(i) = 0.0;
            end

            close(f);

            % Create sparse projector
            sparse_matrix = sparse(rows, cols, vals, m, n);
        end

        function full_matrix = full(AB)
            % full Compute a matrix representation of the projector.
            %
            % Inputs:
            %   AB - AstraProjector
            %
            % Output:
            %   full_matrix - Matrix representation of the operator.

            % Size of the matrix
            sz = size(AB);
            m = sz(1); n = sz(2);

            % Allocate the matrix
            full_matrix = zeros(m, n);

            % Allocate unit vector
            e = zeros(n, 1);

            f = waitbar(0, 'Initializing full matrix');

            for i = 1:n
                if mod(i, 500) == 0
                    prog = sprintf("\rFilling matrix: %.1f%%", ...
                        round(i/n * 100, 1, 'decimals'));
                    waitbar(i/n, f, prog)
                end
                % Set unitvector
                e(i) = 1.0;

                % Perform matrix vector product (get the i'th column)
                y = AB * e;

                % Save column
                full_matrix(:, i) = y;

                % Unset unit vector
                e(i) = 0.0;
            end

            close(f);
        end
    end

end