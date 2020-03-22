function  ids = chooseFaultSample(data,pdSz)
gt = data.lab;  result = data.pro>0.5;

gt([1:pdSz end-pdSz+1:end],:,:)=0;
gt(:,[1:pdSz end-pdSz+1:end],:)=0;
gt(:,:,[1:pdSz end-pdSz+1:end])=0;

result([1:pdSz end-pdSz+1:end],:,:)=0;
result(:,[1:pdSz end-pdSz+1:end],:)=0;
result(:,:,[1:pdSz end-pdSz+1:end])=0;


ids =  find(gt ~= result);
%ids = ids(1:5:end);

%numPic = size(gt,3);
% ids = cell(numPic,1);
% for i = 1:numPic
%     ids{i} = single( find(gt(:,:,i) ~= result(:,:,i)));
% end
    
   