classdef (Abstract) AstraProjector


    properties (Abstract)
        % Size of operators
        num_angles;
        num_detectors;
        num_pixels;

        % Logical if we use GPU or CPU
        use_gpu;

        % Astra stuff
        projector_id;
        projector_geometry;

        volume_id;
        volume_geometry;

        sinogram_id;

    end

    % Methods that are common for both forward and back projectors
    methods

        % Return the size of the operator
        function m, n = size(self, dim)
            
        end
    end

end