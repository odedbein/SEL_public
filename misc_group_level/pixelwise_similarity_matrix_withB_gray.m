function pixelwise_similarity_matrix_withB_gray
num_stim=9;
Root = 'C:\Users\OWNER\Dropbox\Lab.Oded\SEL\SEL_6_no_similarity\stimuli';
output = 'C:\Users\OWNER\Dropbox\Lab.Oded\SEL\SEL_6_no_similarity\stimuli\pixelwise_sim';
if ~isdir(output)
    mkdir (output)
end
famous_M=zeros(320*290,num_stim);
famous_F=zeros(320*290,num_stim);
NF_M=zeros(320*290,num_stim);
NF_F=zeros(320*290,num_stim);
corr_mat=zeros(num_stim*4,num_stim*4);
BFace_M=zeros(320*290,num_stim*2);
BFace_F=zeros(320*290,num_stim*2);

%cond_names={'Famous_M','Famous_F','NF_M','NF_F'};
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

for i=1:num_stim*2
    fname=sprintf('BFace_M_%s.bmp',int2str(i));
    file = fullfile(Root,fname);
    figure=rgb2gray(imread(file));
    figure=reshape(figure,320*290,1);
    BFace_M(:,i)=figure;
    fname=sprintf('BFace_F_%s.bmp',int2str(i));
    file = fullfile(Root,fname);
    figure=rgb2gray(imread(file));
    figure=reshape(figure,320*290,1);
    BFace_F(:,i)=figure;
end

M_faces=[famous_M NF_M BFace_M];
F_faces=[famous_F NF_F BFace_F];


corr_M_faces=corrcoef(M_faces);
corr_F_faces=corrcoef(F_faces);

FM_BFaceM=corr_M_faces(1:9,19:36);
FF_BFaceF=corr_F_faces(1:9,19:36);
NF_M_BFaceM=corr_M_faces(10:18,19:36);
NF_F_BFaceF=corr_F_faces(10:18,19:36);
vec_FM_BFaceM=reshape(FM_BFaceM,9*18,1);
vec_FF_BFaceF=reshape(FF_BFaceF,9*18,1);
vec_NF_M_BFaceM=reshape(NF_M_BFaceM,9*18,1);
vec_NF_F_BFaceF=reshape(NF_F_BFaceF,9*18,1);
vec_corr=[vec_FM_BFaceM,vec_FF_BFaceF,vec_NF_M_BFaceM,vec_NF_F_BFaceF];

cd(output);
save('pixelwise_similarity_Bfaces_gray','corr_M_faces','corr_F_faces','FM_BFaceM','FF_BFaceF','NF_M_BFaceM','NF_F_BFaceF','vec_corr');


    