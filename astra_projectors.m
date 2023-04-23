function [A, B] = astra_projectors(num_pixels, num_angles, num_detectors, ...
    det_width, proj_geom, source_origin, origin_det, angles)
% Create and return an unmatched projector pair from ASTRA
% 
% OBS! You need to have a GPU - a warning will be printed if no GPU is
% found.
%
% Input
% ************************************************************************
% Minimum requirement for astra_projectors() are the first four input
% parameters (num_pixels, num_angles, num_detectors, and det_width).
%  
%   num_pixels:     Number of pixels in a row/coloumn (quadratic problem).
%
%   num_angles:     Number of view angles.
%
%   num_detectors:  Number of detector elements.
% 
%   det_width:      Width of detector element.
% 
%   proj_geom:      Projection geometry - should be "parallel" or "fanflat"
%                   - (default) Parallel beam geometry
%
%   source_origin:  Distance from source to origin/center
%                   - No need to include if parallel beam geometry is used.
%
%   origin_det:     Distance from origin/center to detector
%                   - No need to include if parallel beam geometry is used.
%
%   angles:         All view angles
%                   - (default) Equidistant angles between 0 and pi for
%                   parallel beam geometry and equidistant angles between 
%                   0 and 2*pi for fan beam geoemtry. 
%
%
% Output 
% ************************************************************************
% astra_projectors() outputs an unmatched projector pair A and B.
%
% A: Forward projector
%
% B: Back projector
%

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
    projection_id, projection_geometry, volume_id, volume_geometry, ...
    sinogram_id, reconstruction_id);

% Create backward projector
B = AstraBackwardProjector(num_pixels, num_angles, num_dets, ...
    projection_id, projection_geometry, volume_id, volume_geometry, ...
    sinogram_id, reconstruction_id);

end