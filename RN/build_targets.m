function T = build_targets(data)
% Constrói o target binário (one-hot encoding) para as redes neuronais
% Formato MATLAB: classes nas linhas, casos nas colunas (3 x N)
%
% Classes:
%   Normal            → [1; 0; 0]
%   ElectricalFailure → [0; 1; 0]
%   MechanicalFailure → [0; 0; 1]
%
% Entrada: data — tabela com o dataset tratado (com class_cat preenchido)
% Saída:   T    — matriz [3 x N] de doubles (0s e 1s)

N = height(data);
T = zeros(3, N);

for i = 1:N
    classe = string(data.class_cat(i));
    if strcmp(classe, 'Normal')
        T(1, i) = 1;
    elseif strcmp(classe, 'ElectricalFailure')
        T(2, i) = 1;
    elseif strcmp(classe, 'MechanicalFailure')
        T(3, i) = 1;
    end
end

end
