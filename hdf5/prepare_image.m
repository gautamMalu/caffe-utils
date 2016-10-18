% ------------------------------------------------------------------------
function crops_data = prepare_image(im,mean_data)
% ------------------------------------------------------------------------
% caffe/matlab/+caffe/imagenet/ilsvrc_2012_mean.mat contains mean_data that
% is already in W x H x C with BGR channels
% Convert an image returned by Matlab's imread to im_data in caffe's data
% format: W x H x C with BGR channels
im_data = im(:, :, [3, 2, 1]);  % permute channels from RGB to BGR
im_data = permute(im_data, [2, 1, 3]);  % flip width and height
im_data = single(im_data);  % convert from uint8 to single
%disp(size(im_data))
%disp(size(mean_data))
im_data = im_data - mean_data;  % subtract mean_data (already in W x H x C, BGR)
CROPPED_DIM = 224;
IMAGE_DIM = 256;
% oversample (4 corners, center, and their x-axis flips)
crops_data = zeros(CROPPED_DIM, CROPPED_DIM, 3, 10, 'single');
indices = [0 IMAGE_DIM-CROPPED_DIM] + 1;
n = 1;
for i = indices
  for j = indices
    %fprintf('i: %d i+cd: %d j: %d j+cd: %d\n',i,i+CROPPED_DIM -1, j, j+CROPPED_DIM-1);  
    crops_data(:, :, :, n) = im_data(i:i+CROPPED_DIM-1, j:j+CROPPED_DIM-1, :);
    crops_data(:, :, :, n+5) = crops_data(end:-1:1, :, :, n);
    n = n + 1;
  end
end
center = floor(indices(2) / 2) + 1;
crops_data(:,:,:,5) = ...
  im_data(center:center+CROPPED_DIM-1,center:center+CROPPED_DIM-1,:);
crops_data(:,:,:,10) = crops_data(end:-1:1, :, :, 5);


%crops_data = im_data(16:224+15,16:224+15,:);                                                                                      