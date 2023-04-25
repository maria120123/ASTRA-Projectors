function [A, B] = astra_projectors(GPU, num_pixels, num_angles, num_detectors, ...
    det_width, proj_geom, source_origin, origin_det, angles)
% Create and return an unmatched projector pair from ASTRA
% 
% OBS! You need to have a GPU - a warning will be printed if no GPU is
% found.
%
% ************************************************************************
% Input
% ************************************************************************
% Minimum requirement for astra_projectors() are the first four input
% parameters (num_pixels, num_angles, num_detectors, and det_width).
%   GPU:            False (0) the algorithm uses the CPU and True (1) the
%                   algorithm uses CPU.
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
% ************************************************************************
% Output 
% ************************************************************************
% astra_projectors() outputs an unmatched projector pair A and B.
%
% A: Forward projector
%
% B: Back projector
%

% Default setup is parallel beam
if nargin < 6
    proj_geom = "parallel";
end

% Determine CT beam type
if strcmp(proj_geom, "parallel")
    parallel_beam = true;
else
    parallel_beam = false;
end

% Ensure that fan beam has all the inputs it needs
if ~parallel_beam && nargin < 8
    error("Fan beam geometry requires additional inputs: source_origin and origin_det");
end

if nargin < 9
    % Assume equidistant angles
    if parallel_beam
        angles = linspace(0, pi, num_angles + 1);
    else
        angles = linspace(0, 2*pi, num_angles + 1);
    end

    % Remove the end point to avoid duplicate angles
    angles = angles(1:end-1);
end

% Error checks
% ---------------------------------------------------------------
% Ensure that all dependencies are correctly set up
include_paths();

% Ensure that there is a GPU device
check_failed = checkGPU(GPU);

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

if GPU
    try
        projection_id = astra_create_projector('cuda', projection_geometry,... 
            volume_geometry);  % using GPU
    catch err
        if check_failed
            warning("MATLAB could not detect a GPU device ensure you" + ...
                " have installed the GPU computing package. ")
        end
        rethrow(err)
    end
else
    projection_id = astra_create_projector('linear', projection_geometry,...
    volume_geometry);
end

% Setting up the projectors
% ----------------------------------------------------------------
% Create forward projector
A = AstraForwardProjector(num_angles, num_pixels, num_detectors, ...
    projection_id, projection_geometry, volume_geometry, GPU);

% Create backward projector
B = AstraBackwardProjector(num_angles, num_pixels, num_detectors, ...
    projection_id, projection_geometry, volume_geometry, GPU);

end


function include_paths()
    old_dir       = pwd();
    projector_dir = my_filepath();
    
    cd(projector_dir);
    
    try
        addpath("src/")
        if isfile(".astra_root.mat")
            load(".astra_root.mat")
            addpath(astra_root + "/matlab/mex")
            addpath(astra_root + "/matlab/tools")
        end
    catch
        cd(old_dir);
    end
    cd(old_dir);
end

% Magic
function out = my_filepath()

    mfilePath = mfilename('fullpath');
    
    if contains(mfilePath,'LiveEditorEvaluationHelper')
        mfilePath = matlab.desktop.editor.getActiveFilename;
    end

    out = extractBefore(mfilePath,"/astra_projectors");

end


