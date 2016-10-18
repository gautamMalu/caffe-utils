function generate_hdf5_dataset(images_labels, result_file, image_size, run_demo, chunksz)
% *images_labels* is the list of images along with labels (in the example
% each image is labelled with 4 labels)
% *results_file* is .h5 file in which the images are stored along with labels 
% *image_size* is 1x2 matrix in which the width and height of images are
% defined
% *run_demo* if the list of images is large and would like to test the procedure by creating a dataset of first 1000 images from the list, set the parameter to true 
% *chunksz* defines the size of the chunk
%
% This procedure is adapted for 4 labels. In case of different number of
% labels and/or types of labels, change the first two lines of code
% accordingly.
%
%NOTE: If the you want to change the compression rate, change the 'Deflate'
%parameter in store2hdf5.m file:
%h5create(filename, '/data', [dat_dims(1:end-1) maxSize], 'Datatype', 'single', 'ChunkSize', [dat_dims(1:end-1) chunksz], 'Deflate',9);  

%% Pattern for reading list of images from .txt file
pattern = '%s %f';
[names, l1] = textread(images_labels, pattern);
%disp(names)
labels = [l1];
%%
list_filename = strrep(result_file, '.h5', '.txt');
switch nargin
    case 3
        run_demo = false;
        chunksz = 100;
    case 4
        chunksz = 100;
end

num_total_samples=size(names,1);
% if run_demo == true
%     if num_total_samples > 1000
%         num_total_samples = 1000;
%     end
% end

if chunksz < 10
    chunksz = 100;
end
created_flag=false;
totalct=0;
d = load('/home/gautam/deepImageAestheticsAnalysis/experiments/aadb_mean.mat');
mean_data = d.mean_data;
CROPPED_DIM = 224;
for batchno=1:num_total_samples*10/chunksz
  fprintf('batch no. %d\n', batchno);
  last_read=(batchno-1)*chunksz/10;
  batchImages = [];
  batchLabels = [];
  count = 0;
  for i = 1 : chunksz/10
      %upperleft,lowerleft,upperright,lowerright and mirror images
     
      imgPath = names(last_read+i);
     % disp (last_read+i)
     % disp (imgPath)
      img = imread(imgPath{1});
      label = labels(last_read+i,:);
    %  disp(size(label));
    %  disp(size(labels));
      all_labels = repmat(label,10,1);
   %   disp(size(all_labels));
	  if size(img,1) ~= size(image_size,1) || size(img,2) ~= size(image_size,2)
		img = imresize(img, image_size);
      end
    %  disp(size(img))  
      if size(img,3) ==3
        start = (count)*10 + 1;
        ending = start+9;
        batchImages(:,:,:,start:ending) = prepare_image(img,mean_data);
        batchLabels = [batchLabels; all_labels];
        count = count + 1;
      end
        
     
  end
  num = size(batchImages,4);
  shuf_order = randperm(num);
  %disp(size(batchLabels));
  %disp(size(batchImages));
  batchImages = batchImages(:,:,:,shuf_order);
  batchLabels = batchLabels(shuf_order,:);
  % store to hdf5
  startloc=struct('dat',[1,1,1,totalct+1], 'lab', [1,totalct+1]);
  curr_dat_sz=store2hdf5(result_file, batchImages, batchLabels', ~created_flag, startloc, chunksz, Inf); 
  created_flag=true;% flag set so that file is created only once
  totalct=curr_dat_sz(end);% updated dataset size (#samples)
end

% display structure of the stored HDF5 file
h5disp(result_file);

% CREATE list.txt containing filename, to be used as source for HDF5_DATA_LAYER
FILE=fopen(list_filename, 'w');
fprintf(FILE, '%s', result_file);
fclose(FILE);
fprintf('HDF5 filename listed in %s \n', list_filename);

% NOTE: In net definition prototxt, use list.txt as input to HDF5_DATA as: 
% layers {
%   name: "data"
%   type: HDF5_DATA
%   top: "data"
%   top: "labelvec"
%   hdf5_data_param {
%     source: "/path/to/list.txt"
%     batch_size: 64
%   }
% }