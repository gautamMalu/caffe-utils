images_labels = '/home/gautam/Desktop/test/train03.txt';
result_file = '/home/gautam/deepImageAestheticsAnalysis/experiments/train_score_h5/train03.h5';
image_size = [256, 256];
run_demo = false;
chunksz = 1000;

for i = 10:12
    image_labels = sprintf('/home/gautam/Desktop/test/train%d.txt',i);
    result_file = sprintf('/home/gautam/deepImageAestheticsAnalysis/experiments/train_score_h5/train%d.h5',i);
    disp(result_file);
    disp(image_labels);
    generate_hdf5_dataset(images_labels, result_file, image_size, run_demo, chunksz);
end
%