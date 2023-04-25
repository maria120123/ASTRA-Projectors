function astra_setup(astra_root)
% 
    % Save old directory
    old_dir = pwd;

    % Move to astra root
    cd(astra_root);

    % Ensure that all folders are present
    try
        cd("matlab/mex");
        cd("../tools");
    catch
        cd(old_dir);
        error("Incorrect file path.");
    end

    % Return to old directory
    cd(old_dir)

    % Save file path
    save(".astra_root.mat", "astra_root");

    % Exit message
    fprintf("ASTRA-Projectors is now set up.\n");
end