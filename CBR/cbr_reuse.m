function [classe, temp_sugerida] = cbr_reuse(caso_similar, novo_caso, rede, verbose)
% Reuse do CBR
% Copia a classe do caso mais similar e usa rede neuronal para sugerir temperature
% Entradas: caso_similar, novo_caso, rede (já treinada antes do ciclo)
% Saídas:   classe (diagnóstico), temp_sugerida (valor sugerido pela rede)
%           verbose (opcional) controla mensagens no ecrã

if nargin < 4 || isempty(verbose)
	verbose = true;
end

% copiar a classe do caso mais similar
classe = caso_similar.class_cat;

% prever temperature com a rede já treinada

% input do novo caso para a rede (formato: atributos x 1)
novo_input = [novo_caso.vibration; novo_caso.rotation_speed; novo_caso.voltage];

% prever temperature
temp_sugerida = rede(novo_input);

% mostrar resultados
if verbose
	fprintf('\n--- REUSE ---\n');
	fprintf('  Classe sugerida:      %s\n', string(classe));
	fprintf('  Temperatura atual:    %.2f C\n', novo_caso.temperature);
	fprintf('  Temperatura sugerida: %.2f C\n', temp_sugerida);
end

end
