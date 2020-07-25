function pixelwise_similarity_matrix_gray
num_stim=6;
Root = 'C:\Users\OWNER\Dropbox\Lab.Oded\SEL\SEL10_pilot_scanner2\stimuli';
output = 'C:\Users\OWNER\Dropbox\Lab.Oded\SEL\SEL10_pilot_scanner2\stimuli\pixelwise_sim';
if ~isdir(output)
    mkdir (output)
end
famous_M=zeros(320*290,num_stim);
famous_F=zeros(320*290,num_stim);
NF_M=zeros(320*290,num_stim);
NF_F=zeros(320*290,num_stim);
corr_mat=zeros(num_stim,num_stim);

cond_names={'Famous_M','Famous_F','NF_M','NF_F'};
for i=1:num_stim
    fname=sprintf('Famous_M_%s.bmp',int2str(i));
    file = fullfile(Root,fname);
    figure=rgb2gray(imread(file));
    figure=reshape(figure,320*290,1);
    famous_M(:,i)=figure;
    fname=sprintf('Famous_F_%s.bmp',int2str(i));
    file = fullfile(Root,fname);
    figure=rgb2gray(imread(file));
    figure=reshape(figure,320*290,1);
    famous_F(:,i)=figure;
    fname=sprintf('NF_M_%s.bmp',int2str(i));
    file = fullfile(Root,fname);
    figure=rgb2gray(imread(file));
    figure=reshape(figure,320*290,1);
    NF_M(:,i)=figure;
    fname=sprintf('NF_F_%s.bmp',int2str(i));
    file = fullfile(Root,fname);
    figure=rgb2gray(imread(file));
    figure=reshape(figure,320*290,1);
    NF_F(:,i)=figure;
end


corr_famous_M=corrcoef(famous_M);
corr_famous_F=corrcoef(famous_F);
corr_NF_M=corrcoef(NF_M);
corr_NF_F=corrcoef(NF_F);
cd(output);
vec_FM=tril(corr_famous_M,-1);
vec_FM=vec_FM(vec_FM~=0);
vec_FF=tril(corr_famous_F,-1);
vec_FF=vec_FF(vec_FF~=0);
vec_NF_M=tril(corr_NF_M,-1);
vec_NF_M=vec_NF_M(vec_NF_M~=0);
vec_NF_F=tril(corr_NF_F,-1);
vec_NF_F=vec_NF_F(vec_NF_F~=0);
vec_corr=[vec_FM,vec_FF,vec_NF_M,vec_NF_F];

save('pixelwise_similarity_grayscale','corr_famous_M','corr_famous_F','corr_NF_M','corr_NF_F','vec_corr');


    