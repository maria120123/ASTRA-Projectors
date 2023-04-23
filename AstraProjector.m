classdef (Abstract) AstraProjector


    properties (Abstract)
        % Size of operators
        num_angles;
        num_detectors;
        num_pixels;

        % Astra stuff
        projector_id;
        projector_geometry;

        volume_id;          % Is defined on the fly
        volume_geometry;    

        sinogram_id;        % Is defined on the fly

        cfg;                % ASTRA algorithm struct
    end

    % Methods that are common for both forward and back projectors
    methods
        % Tell ASTRA to deallocate memory when MATLAB tries to delete the
        % object.
        function delete(self)
            % Call ASTRA cleanup


        end

        % Return the size of the operator
        function sz = size(self, dim)
            m = self.num_angles * self.num_detectors;
            n = self.num_pixels;

            dims = [m, n];

            if nargin == 1
                sz = dims;
            else
                sz = dims(dim);
            end

            return;
        end

        % Return a sparse matrix of the projector
        function M = sparse()

        end


        % Return a full amtrix of the projector
        function M = ful()

        end
    end

end