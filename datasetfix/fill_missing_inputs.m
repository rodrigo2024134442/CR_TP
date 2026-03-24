function data = fill_missing_inputs(data)
% Preenche os valores em falta (NaN) nos atributos de entrada
% Entrada: data — tabela com categóricos já convertidos
% Saída:   data — mesma tabela sem NaN nos atributos de entrada
%
% Estratégias usadas:
%   - Média: atributos numéricos contínuos (temperature, rotation_speed,
%            voltage, noise_level, efficiency, load_val)
%   - Moda:  atributos com possíveis outliers ou que representam categorias
%            (vibration, current, pressure, torque, maintenance_level,
%             operating_mode, cooling_type, sensor_status)

% -------------------------------------------------------------------------
% Colunas a preencher com MÉDIA
% Justificação: são atributos contínuos com distribuição equilibrada,
%               a média representa bem o valor típico do sistema
% -------------------------------------------------------------------------
colunas_media = {'temperature', 'rotation_speed', 'voltage', ...
                 'noise_level', 'efficiency', 'load_val'};

% percorre cada coluna da lista de colunas para preencher com média
for i = 1:length(colunas_media)

    % obter o nome da coluna atual
    col = colunas_media{i};
    % extrair os valores da coluna para uma variável temporária
    valores_coluna = data.(col);

    % calcular a média da coluna ignorando os NaN
    % 'omitnan' = não conta os valores vazios no cálculo
    media = mean(valores_coluna, 'omitnan');

    % encontrar as posições onde o valor é NaN
    posicoes_nan = isnan(valores_coluna);
    % substituir os NaN pela média
    data.(col)(posicoes_nan) = media;

end

% -------------------------------------------------------------------------
% Colunas a preencher com MODA
% Justificação: atributos com possíveis outliers (vibration, current,
%               pressure, torque) ou que representam categorias convertidas
%               (maintenance_level, operating_mode, cooling_type,
%               sensor_status) — a moda é mais robusta nestes casos
% -------------------------------------------------------------------------
colunas_moda = {'vibration', 'current', 'pressure', 'torque', ...
                'maintenance_level', 'operating_mode', ...
                'cooling_type', 'sensor_status'};

% percorre cada coluna da lista de colunas para preencher com moda
for i = 1:length(colunas_moda)

    % obter o nome da coluna atual
    col = colunas_moda{i};
    % extrair os valores da coluna para uma variável temporária
    valores_coluna = data.(col);
    % calcular a moda ignorando os NaN
    %NOTA: o calc_moda já ignora os NaN internamente antes de calcular
    moda = calc_moda(valores_coluna);
    % encontrar as posições onde o valor é NaN
    posicoes_nan = isnan(valores_coluna);
    % substituir os NaN pela moda
    data.(col)(posicoes_nan) = moda;

end

end

% -------------------------------------------------------------------------
% Função auxiliar — calcula a moda ignorando NaN
% -------------------------------------------------------------------------
function m = calc_moda(coluna)
    coluna = coluna(~isnan(coluna));  % remove os NaN
    m = mode(coluna);                 % calcula a moda dos valores válidos
end
