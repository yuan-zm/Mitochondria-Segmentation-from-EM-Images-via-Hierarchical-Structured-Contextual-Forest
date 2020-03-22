function imgInd = getSeq(allImgNum,batch)
if(batch==2),imgInd{1}=1:2:allImgNum;imgInd{2}=2: 2:allImgNum;return;end
choose = [];c= [];
imgInd = cell(batch,1);
seq = 1:1:allImgNum; seqCopy = seq; eachNum = ceil(allImgNum /( batch-1));
for i = 1:batch-1
    if(~isempty(choose)),c =  randperm(size(choose,2),min(10,size(choose,1)));c = choose(c);end
    ind = randperm(size(seq,2),min(eachNum,size(seq,2)));
    tImgInd =  seq(ind);
    seq(ind) = []; 
    choose=[choose,tImgInd]; %#ok
    tImgInd = unique([tImgInd,c]);
    imgInd{i} = tImgInd;
end
if(~isempty(choose)),  c =  randperm(size(choose,2),eachNum);c = choose(c);end

imgInd{batch} = [seq,c];