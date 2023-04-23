function [A, B] = astra_projectors(num_pixels, num_angles, num_dets, ...
    angles, proj_model, proj_geom, source_origin, origin_det, det_width)
% Create and return a projector pair from ASTRA

% Ensure that all dependencies are correctly set up
astra_setup();

% Ensure that there is a GPU device
checkGPU();

% Setting up the geometry
% ---------------------------------------------------------------
% Set up projection geometry
projection_id, projection_geometry = setup_projection();




% Setting up the projectors
% ----------------------------------------------------------------
% Create forward projector
A = AstraForwardProjector(num_pixels, num_angles, num_dets, ...
    projection_id, projection_geometry, volume_id, volume_geometry, ...
    sinogram_id, reconstruction_id);

% Create backward projector
B = AstraBackwardProjector(num_pixels, num_angles, num_dets, ...
    projection_id, projection_geometry, volume_id, volume_geometry, ...
    sinogram_id, reconstruction_id);

end