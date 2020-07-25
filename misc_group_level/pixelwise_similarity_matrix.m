function pixelwise_similarity_matrix
num_stim=12;
Root = 'C:\Users\OWNER\Dropbox\Lab.Oded\SEL\SEL12_pilot_scanner2\stimuli';
output = 'C:\Users\OWNER\Dropbox\Lab.Oded\SEL\SEL12_pilot_scanner2\stimuli\pixelwise_sim';
if ~isdir(output)
    mkdir (output)
end
famous_M=zeros(320*290,num_stim,3);
famous_F=zeros(320*290,num_stim,3);
NF_M=zeros(320*290,num_stim,3);
NF_F=zeros(320*290,num_stim,3);
corr_mat=zeros(num_stim,num_stim,3);

cond_names={'Famous_F','NF_F'};
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

corr_mat(:,:,1)=corrcoef(famous_F(:,:,1));
corr_mat(:,:,2)=corrcoef(famous_F(:,:,2));
corr_mat(:,:,3)=corrcoef(famous_F(:,:,3));
corr_famous_F=mean(corr_mat,3);
corr_mat(:,:,1)=corrcoef(NF_F(:,:,1));
corr_mat(:,:,2)=corrcoef(NF_F(:,:,2));
corr_mat(:,:,3)=corrcoef(NF_F(:,:,3));
corr_NF_F=mean(corr_mat,3);
cd(output);
vec_FF=tril(corr_famous_F,-1);
vec_FF=vec_FF(vec_FF~=0);

vec_NF_F=tril(corr_NF_F,-1);
vec_NF_F=vec_NF_F(vec_NF_F~=0);
vec_corr=[vec_FF,vec_NF_F];

save('pixelwise_similarity','corr_famous_F','corr_NF_F','vec_corr');


    