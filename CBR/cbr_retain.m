function data = cbr_retain(data, novo_caso, solucao)

novo_caso.target = solucao;

data = [data; novo_caso];

end