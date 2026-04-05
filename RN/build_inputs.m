function X = build_inputs(data)
% BUILD_INPUTS Constrói a matriz de entrada X para redes neuronais
%
% Formato esperado
% - Cada coluna representa um caso (amostra)
% - Cada linha representa um atributo (feature)
% → Dimensão final: [14 x N]
% Entrada:
%   data — tabela (table) com os dados já tratados
%
% Saída:
%   X — matriz numérica (double) com dimensão [14 x N]

    % Lista das colunas (features) que serão usadas como entrada
    % Cada uma corresponde a uma linha da matriz X
    colunas = {'temperature', 'vibration', 'rotation_speed', 'voltage', ...
               'current', 'pressure', 'noise_level', 'efficiency', ...
               'load_val', 'torque', 'maintenance_level', 'operating_mode', ...
               'cooling_type', 'sensor_status'};

    % Número de amostras (linhas da tabela)
    N = height(data);

    % Inicialização da matriz X com zeros
    % Linhas = número de atributos (14)
    % Colunas = número de amostras (N)
    X = zeros(length(colunas), N);

    % Preenchimento da matriz X
    % Para cada atributo:
    for i = 1:length(colunas)
        
        % Acede à coluna da tabela dinamicamente
        % Transpõe (') para garantir formato linha (1 x N)
        % e coloca na i-ésima linha de X
        X(i, :) = data.(colunas{i})';
    end

end