function Q=Eq(q)

%四元数和向量的乘法系数矩阵

Q=[-q(2:4).'
    (q(1)*eye(3)+X_Matrix(q(2:4)))];


end



