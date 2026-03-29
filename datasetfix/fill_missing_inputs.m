function data = fill_missing_inputs(data)
% Preenche valores NaN nos atributos de entrada
% Entrada: tabela com categóricos já convertidos
% Saída:   tabela sem NaN nos inputs
%
% Estratégias:
%   - Média: variáveis contínuas
%   - Moda:  variáveis com outliers ou categóricas

% Colunas preenchidas com média (valores contínuos)
colunas_media = {'temperature', 'rotation_speed', 'voltage', ...
                 'noise_level', 'efficiency', 'load_val'};

for i = 1:length(colunas_media)

    col = colunas_media{i};              % nome da coluna
    valores_coluna = data.(col);         % dados da coluna

    media = mean(valores_coluna, 'omitnan'); % média sem NaN
    posicoes_nan = isnan(valores_coluna);    % posições com NaN

    data.(col)(posicoes_nan) = media;    % substitui NaN pela média
end

% Colunas preenchidas com moda (outliers ou categorias)
colunas_moda = {'vibration', 'current', 'pressure', 'torque', ...
                'maintenance_level', 'operating_mode', ...
                'cooling_type', 'sensor_status'};

for i = 1:length(colunas_moda)

    col = colunas_moda{i};              % nome da coluna
    valores_coluna = data.(col);        % dados da coluna

    moda = calc_moda(valores_coluna);   % moda sem NaN
    posicoes_nan = isnan(valores_coluna); % posições com NaN

    data.(col)(posicoes_nan) = moda;    % substitui NaN pela moda
end

end

% Função auxiliar: moda ignorando NaN
function m = calc_moda(coluna)
    coluna = coluna(~isnan(coluna)); % remove NaN
    m = mode(coluna);                % calcula moda
end