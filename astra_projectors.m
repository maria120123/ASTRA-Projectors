function [A, B] = astra_projectors(use_gpu, num_pixels, num_angles, ...
    num_detectors, det_width, proj_geom, source_origin, origin_det, ...
    projection_model, angles)
%astra_projectors Create a matched or unmatched projector pair from ASTRA
% 
% OBS! To create an unmatched pair, you need to have an NVIDIA GPU.
% A error will be thrown if no such GPU is found.
%
% [A, B] = astra_projectors(use_gpu, num_pixels, num_angles, ...
%    num_detectors, det_width, proj_geom, source_origin, origin_det, ...
%    projection_model, angles)
%
% ************************************************************************
% Input
% ************************************************************************
% Minimum requirement for astra_projectors() are the first four input
% parameters (use_gpu, num_pixels, num_angles, and num_detectors).
%   use_gpu:          False: the algorithm uses the CPU,
%                     True:  the algorithm uses the GPU.
%  
%   num_pixels:       Number of pixels in a row/coloumn, i.e., the image
%                     is always square of size num_pixels x num_pixels.
%
%   num_angles:       Number of view angles.
%
%   num_detectors:    Number of detector elements.
% 
%   det_width:        Width of detector element; default 1.
% 
%   proj_geom:        Projection geometry, "parallel" or "fanflat";
%                     default is parallel beam geometry.
%
%   source_origin:    Distance from source to origin/center;
%                     no need to include if parallel beam geometry is used.
%
%   origin_det:       Distance from origin/center to detector;
%                     no need to include if parallel beam geometry is used.
%
%   angles:           A vector with all view angles;
%                     default isqeuidistant angles between 0 and pi for
%                     parallel beam geometry and equidistant angles between 
%                     0 and 2*pi for fan beam geoemtry.
% 
%   projection_model: Can be 'line', 'strip' or 'linear' (the latter is
%                     also known as Josept); default is 'line';
%                     no need to include if use_gpu = false.
%
% ************************************************************************
% Output 
% ************************************************************************
% The output consists of a matched or unmatched projector pair A and B,
% depending on the choice of the input use_gpu, in the form of operators.
%
%   A: Forward projection operator.
%
%   B: Back projection operator.
%
% ************************************************************************
% Comments
% ************************************************************************
% To generate the corresponding sparse matrices, use the function sparse.
%
% If use_gpu = false, a matching pair with B = A' is always returned; then
% there are three choices of the discretization model as specified by
% the input parameter projection_model.
%
% If use_gpu = true, an unmatched pair is always returned; then A uses the
% linear (Joseph) model and B always uses the standard back projection model.

% Reference: P.C. Hansen, J.S. Jorgensen, and W.R.B Lionheart (Eds.),
% "Computed Tomography: Algorithms, Insight, and Just Enough Theory",
% SIAM, PA, 2021.

% Written by Maria Knudsen (with minor changes by PCH), May 4, 2023.

% List of arguments
arguments
    use_gpu             logical
    num_pixels          int64
    num_angles          int64
    num_detectors       int64
    det_width           double          = missing
    proj_geom           (1,:)           = missing
    source_origin                       = missing
    origin_det                          = missing
    projection_model    (1,:) char      = 'line'
    angles              (1,:) double    = missing
end

if ismissing(det_width)
    det_width = 1;
end

if ismissing(proj_geom)
    proj_geom = 'parallel';
end

parallel_beam = strcmp(proj_geom, 'parallel');

% Ensure that fan beam has all the inputs it needs
if ~parallel_beam && (ismissing(source_origin) || ismissing(origin_det))
    error("Fan beam geometry requires additional inputs: source_origin and origin_det");
end

if ismissing(angles)
    % Assume equidistant angles
    if parallel_beam
        angles = linspace(0, pi, num_angles + 1);
    else
        angles = linspace(0, 2*pi, num_angles + 1);
    end

    % Remove the end point to avoid duplicate angles
    angles = angles(1:end-1);
else
    if num_angles ~= length(angles)
        error("Mismatch between num_angles and length(angles).")
    end
end

% Error checks
% ---------------------------------------------------------------
% Ensure that all dependencies are correctly set up

% Ensure that there is a GPU device
checkGPU(use_gpu);

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

if use_gpu
    projection_id = astra_create_projector('cuda', projection_geometry,... 
        volume_geometry);  % using GPU
else
    if ~parallel_beam
        projection_model = strcat(projection_model, '_fanflat');
    end

    projection_id = astra_create_projector(projection_model, ...
        projection_geometry, volume_geometry);
end

% Setting up the projectors
% ----------------------------------------------------------------
% Create forward projector
A = AstraForwardProjector(num_angles, num_pixels, num_detectors, ...
    projection_id, projection_geometry, volume_geometry, use_gpu);

% Create backward projector
B = AstraBackwardProjector(num_angles, num_pixels, num_detectors, ...
    projection_id, projection_geometry, volume_geometry, use_gpu);

end