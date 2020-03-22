function  data= redirectionData(sdata,direction)

data.img = permute(sdata.img,direction);
data.lab = permute(sdata.lab,direction);
data.pro = permute(sdata.pro,direction);

