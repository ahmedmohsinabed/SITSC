clc
clear all
close all

%% Initialization
Test=0; % for right key encryption
Test=1; % for key sensitivity test
addpath functions
Images_Path='Images\Original\';
fname={'Lena','baboon','panda'}; % filename
ext='.jpg';
fid=3; % file ID 1 for lena
IS =256; % Image size
Data=imread(strcat(Images_Path,fname{fid},ext));
if (size(Data,3)==3)
    Data=rgb2gray(Data);
end
Data=imresize(Data,[IS IS]); % Image Size

[row,col]=size(Data);
[Data,padding]=Scalling(Data,8);
Data_binary=convert2bin(Data);

hex_key = 'AAAAAAAAAAAAAAAA';
[bin_key] = Hex2Bin( hex_key );
[K1,K2,K3,K4,K5]=SF_Key_Gen(bin_key);

Original_msg=[];
encrypt_msg=[];
decrypt_msg=[];

%% Encryption Process
for kk=1:2
  for i=1:size(Data_binary,1)
    Original=Data_binary(i,:);
    tic
    [cipher]=SF_Encrypt(Original,K1,K2,K3,K4,K5);
    encryption_time(i)=toc;
    tK1=[K1(1:8),Original(1:8)];tK2=Original(9:24);tK3=Original(25:40);tK4=Original(41:56);tK5=[Original(57:64),K5(9:16)];
    K1=tK1;K2=tK2;K3=tK3;K4=tK4;K5=tK5;
    
    encrypt_msg(:,i)=Binary2Dec(cipher);
    cipher_data(i,:)=double(cipher);
    if(kk<2)
    Data_binary(i,:)=cipher_data(i,:);
    end
  end
if (kk==1)
D=reshape(encrypt_msg,[row,col]);
D=D';
[row,col]=size(D);
[D,padding]=Scalling(D,8);
% Data=[Data Data];
Data_binary=double(convert2bin(D));
    TT=[K1,K2,K3,K4,K5];
encrypt_msg=[];
end
end

TTT=TT;
%% Decryption
if (Test==1)
 K1(end)=~K1(end);
 TT=[K1,K2,K3,K4,K5];
end

for kk=kk:-1:1
if(kk==2)
    K11=TT(1:16);K12=TT(17:32);K13=TT(33:48);K14=TT(49:64);K15=TT(65:80);
else
    [K11,K12,K13,K14,K15]=SF_Key_Gen(bin_key);
    D=reshape(decrypt_msg,[row,col]);
D=D';
[row,col]=size(D);
[D,padding]=Scalling(D,8);
cipher_data=double(convert2bin(D));

decrypt_msg=[];
end
for i=1:size(Data_binary,1)
    cipher=cipher_data(i,:);
    [plaintext]=SF_Decryption(cipher,K11,K12,K13,K14,K15);
    K11=[K11(1:8),plaintext(1:8)];K12=plaintext(9:24);K13=plaintext(25:40);K14=plaintext(41:56);K15=[plaintext(57:64),K15(9:16)];

    decrypt_msg(:,i)=Binary2Dec(plaintext);
    cipher_data(i,:)=double(plaintext);
end
end

% %% Results
% 5 Original Image
Original=uint8(reshape(Data,[row,col]));
% 6 Encrypted Image
Encrypted=uint8(reshape(encrypt_msg,[row,col]));
% 7(Wrong Key Decyption (Key Sensitivity))
Decrypted=uint8(reshape(decrypt_msg,[row,col]));
% %% 5 6 7
figure
subplot(1,3,1)
imshow(Original)
title('Original')
subplot(1,3,2)
imshow(Encrypted)
title('Encrypted')
subplot(1,3,3)
imshow(Decrypted)
title('Decrypted')
% 
% 8 Histogram
figure
subplot(2,1,1)
imhist(Original);
subplot(2,1,2)
imhist(Encrypted);

% 14 Image Entropy
Y=(imhist(Encrypted)+0.00001)/(row*col);%(length(Data)-padding);
Y=-sum(Y.*log2(Y));
X=(imhist(Original)+0.00001)/(row*col);%(length(Data)-padding);
X=-sum(X.*log2(X));
Re=[X Y]
% 
% 9 Correlation
figure
subplot(1,2,1)
scatter(Original(1:end-1),Original(2:end),'.')
axis([0 255 0 255])
subplot(1,2,2)
scatter(Encrypted(1:end-1),Encrypted(2:end),'.')
axis([0 255 0 255])
% 
% % 1 NPCR(%)
NPCR=sum(sum(Encrypted~=Original))*100/(row*col)
% 2 UACI(%) 
UACI=sum(sum(abs(Encrypted-Original)))*100/(row*col*255)

display(sprintf('Total encryption time: %f',sum(encryption_time)))

display('correlation coefficient of Original image')
corrcoef(double(Original(1:end-1)),double(Original(2:end)))
display('correlation coefficient of encrypted image')
corrcoef(double(Encrypted(1:end-1)),double(Encrypted(2:end)))


save(strcat('Images\Results\',fname{fid},'.mat'))