function matrix_indexes = apply_pca(matrix_fft)

[coeff,score,variance] = pca(matrix_fft');

[val, index1] = sort(coeff(:,1), 'descend');
[val, index2] = sort(coeff(:,2), 'descend');
[val, index3] = sort(coeff(:,3), 'descend');

matrix_indexes=[index1(1:5,1),index2(1:5,1),index3(1:5,1)];

end
