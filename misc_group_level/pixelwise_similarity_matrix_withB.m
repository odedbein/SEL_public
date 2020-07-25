function pixelwise_similarity_matrix_withB
num_stim=12;
Root = 'C:\Users\OWNER\Dropbox\Lab.Oded\SEL\SEL12_pilot_scanner2\stimuli';
output = 'C:\Users\OWNER\Dropbox\Lab.Oded\SEL\SEL12_pilot_scanner2\stimuli\pixelwise_sim';
if ~isdir(output)
    mkdir (output)
end

famous_F=zeros(320*290,num_stim,3);
NF_F=zeros(320*290,num_stim,3);
corr_mat=zeros(num_stim*4,num_stim*4,3);
BFace_F=zeros(320*290,num_stim*2,3);

%cond_names={'Famous_M','Famous_F','NF_M','NF_F'};
for i=1:num_stim
   
    fname=sprintf('Famous_F_%s.bmp',int2str(i));
    file = fullfile(Root,fname);
    figure=imread(file);
    figure=reshape(figure,320*290,1,3);
    famous_F(:,i,:)=figure;
   
    fname=sprintf('NF_F_%s.bmp',int2str(i));
    file = fullfile(Root,fname);
    figure=imread(file);
    figure=reshape(figure,320*290,1,3);
    NF_F(:,i,:)=figure;
end

for i=1:num_stim*2
    
    fname=sprintf('BFace_F_%s.bmp',int2str(i));
    file = fullfile(Root,fname);
    figure=imread(file);
    figure=reshape(figure,320*290,1,3);
    BFace_F(:,i,:)=figure;
end


F_faces=[famous_F NF_F BFace_F];

corr_mat(:,:,1)=corrcoef(F_faces(:,:,1));
corr_mat(:,:,2)=corrcoef(F_faces(:,:,2));
corr_mat(:,:,3)=corrcoef(F_faces(:,:,3));
corr_F_faces=mean(corr_mat,3);
FF_BFaceF=corr_F_faces(1:12,25:48);
NF_F_BFaceF=corr_F_faces(13:24,25:48);

vec_FF_BFaceF=reshape(FF_BFaceF,12*24,1);

vec_NF_F_BFaceF=reshape(NF_F_BFaceF,12*24,1);
vec_corr=[vec_FF_BFaceF,vec_NF_F_BFaceF];

cd(output);
save('pixelwise_similarity_Bfaces','corr_F_faces','FF_BFaceF','NF_F_BFaceF','vec_corr');


    