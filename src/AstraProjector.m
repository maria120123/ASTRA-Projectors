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
        % Note: memory efficient, but twice as slow as full()

            % Size of the matrix
            sz = size(AB);
            m = sz(1); n = sz(2);

            % Allocate unit vector
            e = zeros(n, 1);

            num_nz = 0;
            tol = 1e-6; % Tolerance for when a number is nonzero

            % Count the number of nonzeroes
            % ----------------------------------------------------
            for i = 1:n
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

            % Create sparse projector
            sparse_matrix = sparse(rows, cols, vals, m, n);
        end


        % Return a full matrix of the projector
        function full_matrix = full(AB)
            % Size of the matrix
            sz = size(AB);
            m = sz(1); n = sz(2);

            % Allocate the matrix
            full_matrix = zeros(m, n);

            % Allocate unit vector
            e = zeros(n, 1);

            for i = 1:n
                if mod(i, 500) == 0
                    fprintf("Filling matrix: %f%%\r", round(i/n * 100))
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
        end
    end

end