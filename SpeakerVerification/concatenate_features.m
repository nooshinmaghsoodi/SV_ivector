addpath('Utilities');

fea1_dir = '/mnt/matylda6/zeinali/Part3/MFCC_E_D_A_60/Features/';
fea2_dir = '/mnt/matylda6/zeinali/Part3/SBN80_16kHz_9kPost/Features/';
output_dir = '/mnt/matylda6/zeinali/Part3/MFCC60_BN80/Features/';

if (~exist(output_dir, 'dir'))
    mkdir(output_dir);
end
file_list = dir([fea1_dir '*.fea']);
for i=1:length(file_list)
    file_name= file_list(i).name;
    out_file = [output_dir file_name];
    if (exist(out_file, 'dir'))
        continue
    end
    fea1 = htkread([fea1_dir file_name]);
    fea2 = htkread([fea2_dir file_name]);
    [d11, d12] = size (fea1);
    [d21, d22] = size (fea2);

    if ((d11>d12 && d21<d22)||(d11<d12 && d21>d22))
        fea2 = fea2';
    end
    if (d11>d12)
        out_fea = [fea1(1:min(d11,d21),:) fea2(1:min(d11,d21),:)];
    else
        out_fea = [ fea1(:,1:min(d12,d22)); fea2(:, 1:min(d12,d22))];
    end

    htkwrite(out_file, out_fea);

end
