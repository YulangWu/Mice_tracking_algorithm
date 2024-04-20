function [] = estimate_time_range(folder_dir, fps, time_par, width, height, raw_video_name_contents, fixation_points_filename, start_end_time_filename)
    % This function automatically estimates the accurate start and end time
    % of experiments
    
    % Load the fixation points to restrict the estimation within ROI.
    load(fixation_points_filename)
    disp('The file containing the coordinates of the fixation points has been loaded!');

    % The range of time in fps to get maximum amplitude from frames corresponding
    % to remove the white box
    leftmost_start_point = time_par(1)*fps;
    rightmost_start_point = time_par(2)*fps;
    % The end of the time in fps
    rightmost_end_point = time_par(3)*fps;
    
    % Initialize vectors to store the starting and end points
    start_point_vec = [0];
    end_point_vec = [0];

    % The 2D data to store the amplitude of frame for each video
    num_of_videos = 0;
    for m = 1 : length(folder_dir)
        if folder_dir(m).name ~= "." && folder_dir(m).name ~= ".."
            subfolder_dir = dir(fullfile([folder_dir(m).folder '/' folder_dir(m).name],raw_video_name_contents));
            for n = 1 : length(subfolder_dir)
                if subfolder_dir(n).name ~= "." && subfolder_dir(n).name ~= ".."
                    num_of_videos = num_of_videos + 1;
                end
            end
        end
    end
    frame_amp_gram = zeros(num_of_videos,rightmost_start_point);



    index = 0;

    warning = 0;
    if isfile(start_end_time_filename)
        warning = input([start_end_time_filename ' exists, do you want to overwrite the existing file? yes 1 no 0\n']);
        if ~warning
            input('Press "Enter" to skip time range estimation step and continue!\n','s')
            return
        end
        load(start_end_time_filename)
    end

    if warning
        aa = input(['The ' start_end_time_filename ' will be overwritten, press "Enter" to continue!\n'],'s');
    end

    for m = 1 : length(folder_dir)
        if folder_dir(m).name ~= "." && folder_dir(m).name ~= ".."
            subfolder_dir = dir(fullfile([folder_dir(m).folder '/' folder_dir(m).name],"*Pro.mp4"));
            for n = 1 : length(subfolder_dir)
                if subfolder_dir(n).name ~= "." && subfolder_dir(n).name ~= ".."
                    index = index + 1;

                    % 1.1 Read video
                    inputVideoFile = string([folder_dir(m).folder '/' folder_dir(m).name '/' subfolder_dir(n).name]);
                    image_filename = [folder_dir(m).folder  '/'  folder_dir(m).name  '_plot.jpg'];

                    % Retrieve the coordinates of the fixation point
                    cropX = x_vec(index);
                    cropY = y_vec(index);

                    % Create VideoReader and VideoWriter objects
                    videoReader = VideoReader(inputVideoFile);

                    % Determine the end time
                    end_point_vec(index) = min(rightmost_end_point,videoReader.NumFrames);
                    rightmost_start_point = min(rightmost_start_point,videoReader.NumFrames);   
                    
                    % Determine the start time
                    frame_power = zeros(rightmost_start_point,1);
                    for t = 1: rightmost_start_point
                        frame = readFrame(videoReader);
                        frame = double(rgb2gray(frame));
                        frame = frame(floor(cropY)-height+1:floor(cropY), floor(cropX)-width+1:floor(cropX));
                        frame_power(t) = sum(sum(sum(frame)))/width/height;
                    end
                    frame_amp_gram(index,1:rightmost_start_point) = frame_power(1:rightmost_start_point); 
                    [val max_index] = max(frame_amp_gram(index,leftmost_start_point:rightmost_start_point));
                    start_point_vec(index) = leftmost_start_point + max_index + 1*fps;

                    % Plot the frames at start and end time 
                    videoReader = VideoReader(inputVideoFile);
                    figure(index)
                    subplot(2,2,1)
                    frame = read(videoReader,start_point_vec(index));
                    frame = readFrame(videoReader);
                    frame = double(rgb2gray(frame));
                    frame = frame(floor(cropY)-height+1:floor(cropY), floor(cropX)-width+1:floor(cropX));
                    imagesc(frame);title(num2str(start_point_vec(index)));
                    title(['Start at frame=' num2str(start_point_vec(index))])
                    
                    subplot(2,2,2);
                    plot(frame_power(1:rightmost_start_point),'k')
                    hold on;xlim([1 rightmost_start_point]);%ylim([55 65])
                    plot(start_point_vec(index),frame_power(start_point_vec(index)),'ro')
                    title(subfolder_dir(n).name)
                    
                    subplot(2,2,3)
                    frame = read(videoReader,end_point_vec(index));
                    frame = double(rgb2gray(frame));
                    frame = frame(floor(cropY)-height+1:floor(cropY), floor(cropX)-width+1:floor(cropX));
                    imagesc(frame);title(num2str(start_point_vec(index)));
                    title(['End at frame=' num2str(end_point_vec(index))])

                    saveas(gcf, image_filename, 'jpg');
                end
            end
        end
    end

    save (start_end_time_filename,"start_point_vec","end_point_vec","frame_amp_gram");


end

