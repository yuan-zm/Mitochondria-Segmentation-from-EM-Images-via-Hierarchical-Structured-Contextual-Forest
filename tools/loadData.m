
function [tarinImg ,labelImg] =  loadData(opts)
% You can change the extension of the training images here
if(opts.train ==1)
    pics = dir([opts.trainImgFolder '*.png']);
    labels = dir([opts.trainAnnFolder '*.png']);
    imgPath = opts.trainImgFolder;
    labPath = opts.trainAnnFolder;
else
    pics = dir([opts.testImgFolder '*.png']);
    labels = dir([opts.testAnnFolder '*.png']); 
    imgPath = opts.testImgFolder;
    labPath = opts.testAnnFolder;
end
label_filename = [labPath labels(1).name];
label = imread(label_filename); % label pic
label = imresize(label,opts.reduceSize);
[m, n] = size(label); numPic = size(pics,1); 
train_img = zeros(m,n,numPic,'single');
label_img = false(m,n,numPic);

for i = 1:numPic %numPic
    img_filename = [imgPath pics(i).name];
    label_filename = [labPath labels(i).name];
    if(opts.reduceSize~=1)
        temp = imread(img_filename);
        train_img(:,:,i) = imresize(temp,opts.reduceSize); %load pic
        temp = imread(label_filename);
        label_img(:,:,i) =  imresize(temp,opts.reduceSize); % label pic
    else
        train_img(:,:,i) = imread(img_filename);
        label_img(:,:,i) = imread(label_filename);   
    end
end

if(opts.train ==1)
    tarinImg = train_img(:,:,1:1:end);
    labelImg = label_img(:,:,1:1:end);
else
    tarinImg = train_img(:,:,1:1:end);
    labelImg = label_img(:,:,1:1:end);
end

parfor i = 1:size(tarinImg,3),[~,tarinImg(:,:,i)] = BM3D(1,tarinImg(:,:,i),8);end
tarinImg =single(tarinImg*255); 