function [A, B] = astra_projectors(num_pixels, num_angles, num_detectors, ...
    angles, proj_geom, source_origin, origin_det, det_width)
% Create and return a projector pair from ASTRA
% 
% Input:
%   proj_geom: Projection geometry - should be "parallel" or "fanflat"

% Todo: 
% - kun source_origin, origin_det for fanbeam
% - default vinkler 0:180 og 0:360
% - default projection geometry

% Ensure that all dependencies are correctly set up
astra_setup();

% Ensure that there is a GPU device
checkGPU();

% Setting up the geometry
% ---------------------------------------------------------------
% Set up projection geometry
volume_geometry = astra_create_vol_geom(num_pixels, num_pixels);

if proj_geom == "parallel"
    projection_geometry = astra_create_proj_geom('parallel', det_width,... 
        num_detectors, angles);
else
    projection_geometry = astra_create_proj_geom('fanflat', det_width,... 
        num_detectors, angles, source_origin, origin_det);
end

projection_id = astra_create_projector('cuda', projection_geometry,... 
    volume_geometry); 




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