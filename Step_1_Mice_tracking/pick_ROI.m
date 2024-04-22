function [] = pick_ROI(folder_dir, raw_video_name_contents, fixation_points_filename)
    % This function allows user to manually pick the fixation point (the
    % lower-right corner)
    
    % Check whether the fixation_points_filename exists
    if exist(fullfile(folder_dir(1).folder,fixation_points_filename), 'file') == 2
        disp([fullfile(folder_dir(1).folder,fixation_points_filename) ' exists!'])
        input('Press "Enter" to skip fixation points picking step and continue!\n','s')
        return;
    end
    
    %x and y coordinate arrays of the starting points in all videos
    x_vec = [0];
    y_vec = [0];

    %Iteratively open the first frame of each video to mannualy select
    %fixation point (i.e., lower-right corner point)
    index = 0;
    for m = 1 : length(folder_dir)
        if folder_dir(m).name ~= "." && folder_dir(m).name ~= ".."
            subfolder_dir = dir(fullfile([folder_dir(m).folder '/' folder_dir(m).name],raw_video_name_contents));
            for n = 1 : length(subfolder_dir)
                if subfolder_dir(n).name ~= "." && subfolder_dir(n).name ~= ".."
                    index = index + 1;

                    inputVideoFile = string([folder_dir(m).folder '/' folder_dir(m).name '/' subfolder_dir(n).name]);
                    disp(inputVideoFile)

                    disp(['Process: ' inputVideoFile])
                    % Create VideoReader and VideoWriter objects
                    videoReader = VideoReader(inputVideoFile);

                    % Read the firsst frame for picking fixation point
                    if hasFrame(videoReader)
                        imageData = readFrame(videoReader);
                        imshow(imageData)
                        title('The first frame in the video')
                    end

                    % Prompt the user to click with the mouse and get cursor coordinates
                    disp('Click on the figure to get cursor coordinates.');
                    % Call ginput with the number of points you want to obtain (e.g., 1 for a single point)
                    nPoints = 1;
                    [x, y] = ginput(nPoints);
                    x_vec(index) = x;
                    y_vec(index) = y;
                end
            end
        end
    end
    disp('Fixation picking is done. Please close the figure!')
    save (fullfile(folder_dir(m).folder,fixation_points_filename),"x_vec","y_vec");

end

