% label splitter - divide sets of combined mha labels into individual ROIs per label
% Adam Zimmerman 2020
clc  % begin generic file management code...
cd 'C:\Users\amc39\Google Drive\ABC\Vignesh_SP\';
fds = fileDatastore('*Seeded.mha', 'ReadFcn', @importdata); % grab all label sets
fullFileNames = fds.Files; % get set names, e.g. ROI1.mha, ROI2.mha...
setCount = size(fullFileNames, 1); % loop through several sets
for set = 1:setCount
    fullName = fullFileNames(set);
    [rt, name, ext] = fileparts(fullName{1}); % set name and ext
    [volume,vol_info] = ReadData3D(fullFileNames{set}); % import volume data
    [labelMatrix, labelCount] = bwlabeln(volume, 26); % search for 26-connected objects
    report = sprintf('%d labels found in %s', labelCount, name); disp(report);
    for label = 1:labelCount % for each label in set, dilate, crop, clean exterior, save
       tic
       temp_vol = labelMatrix == label; % make a volume of just n
       se = strel('sphere',50); % set structured element for dilation
       dilated_vol = imdilate(temp_vol,se);
       % save
       mhaWriter(['test_', name, sprintf('label_%d',label), ext], dilated_vol, [1,1,1], 'uint8'); % save
       size(dilated_vol, 1)
       toc
       
       
    end
    
end

%% crop and erode
fds2 = fileDatastore('test*', 'ReadFcn', @importdata); % grab all label sets
fullFileNames = fds2.Files; % get set names, e.g. ROI1.mha, ROI2.mha...
Count = size(fullFileNames, 1); % loop through several sets
se2 = strel('sphere',3)
for blob = 27:27 % Count % NOTE ME <<<<<<<<<<<<<<<<<
    fullName = fullFileNames(blob);
    [rt, name, ext] = fileparts(fullName{1}); % set name and ext
    [volume,vol_info] = ReadData3D(fullFileNames{blob}); % import volume data
    report = sprintf('%d labels found in %s', Count, rt); disp(report);
    center = regionprops3(volume, 'centroid') % get centroid
    
    % crop alongside raw data
    Vout = imcrop3(volume,[center{:,:} 85 85 85]); % BUG?
    mhaWriter(['test_crop_', name, sprintf('_%d',blob), ext], Vout, [1,1,1], 'uint8'); % save


end
% %%
%     % erode
%     CC = bwconncomp(Vout, 26); %survey the volume for connected components
%     % discard small components (assumed to be noise or debris on glass slide)
%     csize = cellfun(@numel, CC.PixelIdxList); % size of all objects in voxels
%     idx = csize>=500; % <<<<<<<<<<<<<<<<<<< EXPERIMENT WITH THIS
%     CC.NumObjects = sum(idx);
%     CC.PixelIdxList = CC.PixelIdxList(idx);
%     mask = labelmatrix(CC)~=0;
%     mask = imdilate(mask, se2); % dilate to connect disconnected objects from earlier erosion
%     newim_2 = zeros(size(im),'uint8'); % reinitialize raw data
%     newim_2(mask) = im(mask); % set everything outside the mask to zero
%     tic
%     fn_newim_2 = [rt filesep p.AnalysisPath filesep 'segCh3_' 'ekr' num2str(p.ekr) '_dkrbb' num2str(p.dkr_bb) '_dkrc' num2str(p.dkr_c) '_min_P_bb' num2str(p.min_P_bb) '_max_p_bk' num2str(p.max_p_bk) '_minBBsize' num2str(p.minBBsize) '_' fn_probabilities];
%     % writetiff(newim_2, fn_newim_2);
%     mhaWriter(['test_erode_', name, sprintf('_%d',blob), ext], Vout, [1,1,1], 'uint8'); % save
%     toc
% end 

