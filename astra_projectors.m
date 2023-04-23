function [A, B] = astra_projectors(num_pixels, num_angles, num_detectors, ...
    det_width, proj_geom, source_origin, origin_det, angles)
% Create and return a projector pair from ASTRA
% 
% Input:
%   proj_geom: Projection geometry - should be "parallel" or "fanflat"

% Default setup is parallel beam
if nargin < 5
    proj_geom = "parallel";
end

% Determine CT beam type
if strcmp(proj_geom, "parallel")
    parallel_beam = true;
else
    parallel_beam = false;
end

% Ensure that fan beam has all the inputs it needs
if parallel_beam && nargin < 7
    error("Fan beam geometry requires additional inputs: source_origin and origin_det");
end

if nargin < 8
    % Assume equidistant angles
    if parallel_beam
        angles = linspace(0, pi, num_pixels + 1);
    else
        angles = linspace(0, 2*pi, num_pixels + 1);
    end

    % Remove the end point to avoid duplicate angles
    angles = angles(1:end-1);
end

% Error checks
% ---------------------------------------------------------------
% Ensure that all dependencies are correctly set up
astra_setup();

% Ensure that there is a GPU device
checkGPU();

% Setting up the geometry
% ---------------------------------------------------------------
% Set up projection geometry
volume_geometry = astra_create_vol_geom(num_pixels, num_pixels);

if parallel_beam
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
    projection_id, projection_geometry, volume_geometry);

% Create backward projector
B = AstraBackwardProjector(num_pixels, num_angles, num_dets, ...
    projection_id, projection_geometry, volume_geometry);

end



function flag = astra_setup()
    % Set output as failure for now
    flag = 1;



end