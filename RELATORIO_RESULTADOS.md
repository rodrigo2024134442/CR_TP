# Relatório de Resultados — CR_TP

Data: 09/05/2026

## Resumo executivo

- Objetivo: comparar um sistema baseado em CBR com Redes Neuronais (RN) na deteção/classificação de falhas (Normal, ElectricalFailure, MechanicalFailure) usando um dataset tratado.
- Resultado principal: tanto o CBR como as três melhores RN alcançaram 100% de acerto no conjunto de teste externo usado (30 casos), nas condições experimentais descritas.

## 1. Introdução e objetivos

Este relatório sumariza os resultados das tarefas do trabalho: preparação do dataset, implementação e análise de um sistema CBR, estudo de configurações de redes neuronais, análise da influência da normalização e comparação final entre abordagens. Inclui análise crítica, limitações e recomendações para trabalho futuro.

## 2. Metodologia

- Dataset: conjunto inicial com 5000 linhas e 15 colunas. Tratamento dos casos com valores ausentes, conversão de variáveis categóricas e normalização opcional quando necessária.
- Avaliação: divisão treino/val/test conforme especificado nos scripts; para RN foram testadas 120 configurações com 10 repetições cada. Para CBR foram avaliadas várias configurações de pesos e testado com/sem normalização.
- Métricas: acurácia global e acurácia por classe aplicada ao conjunto de teste externo (30 casos) e análises internas de validação.

## 3. Preparação do dataset (Tarefa 3.1)

- Dataset original: 5000 linhas, 15 colunas.
- Antes: 232 casos com missing na classe alvo (`class_cat`).
- Após tratamento: 0 missing na variável alvo; NaN nos inputs reduzidos a 0 após imputação/limpeza.
- Distribuição final de classes:
	- Normal: 1684 (33.7%)
	- ElectricalFailure: 1672 (33.4%)
	- MechanicalFailure: 1644 (32.9%)

Reflexão: a distribuição ficou muito equilibrada, o que facilita a comparação entre métodos sem grande enviesamento de classe.

## 4. Sistema CBR (Tarefa 3.2)

- Implementação: módulos `cbr_retain.m`, `cbr_retrieve.m`, `cbr_reuse.m`, `cbr_revise.m`, com função de similaridade local em `local_similarity.m`.
- Teste externo (30 casos): 30/30 acertos — 100.0%.

### Análise de pesos no CBR (Tarefa 3.2b)

- Foram testadas 6 configurações de pesos (incluindo default balanceado, pesos iguais, foco em sensores principais, foco mecânico/elétrico e sem contexto), com e sem normalização.
- Resultado observado: todas as combinações testadas forneceram 100% de acerto nos 30 casos.

Reflexão: o CBR mostrou-se robusto para o subconjunto de teste. Isto pode dever-se à qualidade do dataset tratado (casos de teste representativos e possivelmente fáceis de distinguir pelas features), ou ao facto de as instâncias de treino conterem exemplos muito próximos às instâncias de teste.

## 5. Redes Neuronais — estudo de configurações (Tarefa 3.3)

- Configurações testadas: 120 configurações, 10 repetições por configuração (variando topologia, função de treino, funções de ativação, learning rate, epochs, e divisão dos dados).
- Topologias vencedoras e características comuns: topologia com 10 neurónios, treino com `trainbr`, ativação `logsig`, divisão `[80 10 10]` e ajustes finos de `lr`/`epochs`.

### Melhores configurações (acurácia no teste interno)

1. Config 120 — 99.66%
2. Config 115 — 99.64%
3. Config 116 — 99.64%

Teste externo (3 melhores): todas as três redes obtiveram 100.00% no conjunto de teste usado.

### Piores configurações (acurácia no teste interno)

1. Config 34 — 31.23%
2. Config 40 — 31.47%
3. Config 45 — 31.76%

Reflexão: a variação dramática entre melhores e piores reforça a importância de escolher hiperparâmetros e algoritmos de treino adequados; alguns métodos podem convergir mal ou ficar presos em soluções subóptimas.

## 6. Comparação final e efeito da normalização (Tarefa 3.4)

Resumo das comparações principais:

- CBR (melhor) sem normalização: 100.0% (acerto global)
- CBR (melhor) com normalização: 100.0%

- RN (3 melhores) — teste externo: todas 100% com e sem normalização.

- RN (3 piores) — comportamento misto: a normalização por vezes melhorou métricas globais mas piorou a acurácia de classes específicas, revelando interações complexas entre preprocessamento e arquitetura.

Tabela resumida (exemplos de entradas observadas):

- Melhor 1 (Sem/Com normalização): 30/30 acertos — 100% global
- Pior 1 (Sem normalização): 14/30 — Acc Global 46.7% — desempenho por classe desigual
- Pior 1 (Com normalização): mesma contagem de acertos, diferenças nas acurácias por classe (ex.: Electrical 0% em um caso)

Reflexão: a normalização é uma ferramenta poderosa, mas não é universalmente benéfica — depende da combinação de arquitetura, função de perda e distribuição das features.

## 7. Discussão crítica

- Resultados perfeitos (100%) em conjuntos de teste pequenos exigem cautela: podem indicar que os casos de teste eram muito semelhantes às instâncias de treino ou que o problema é intrinsecamente fácil com as features selecionadas.
- A robustez do CBR face a diferentes esquemas de pesos sugere que a informação discriminativa está fortemente presente nas features selecionadas.
- As RNs demonstraram alta sensibilidade a hiperparâmetros: enquanto as top configurações generalizaram perfeitamente aqui, muitas configurações falharam.


## 8. Limitações

- Conjunto de teste externo relativamente pequeno (30 casos) — limite a confiança estatística das conclusões.
- Possível falta de diversidade em casos de teste: se os testes não cobrem cenários raros, tanto CBR quanto RN podem não generalizar para esses casos.
- Análises de sensibilidade adicionais (p. ex. bootstrap, k-fold robusto, análise de incerteza) não foram extensivamente executadas.

## 9. Recomendações e trabalho futuro

- Avaliar com um conjunto de teste maior e mais diverso para aumentar confiança estatística.
- Realizar análise de importância de features e estudo de redundância para simplificar modelos e explicar decisões do CBR.
- Investigar regularização e estratégias de ensemble para as RNs, e automatizar busca de hiperparâmetros (ex.: Bayesian optimization).
- Validar resultados em dados reais de operação ou em simulações que reproduzam ruído e falhas raras.

## 10. Conclusão

Ambas as abordagens (CBR e RN) mostraram desempenho excelente nos cenários testados, com o CBR a revelar-se robusto face a variações de pesos e as melhores RNs a alcançar igual desempenho. Contudo, devido ao tamanho reduzido do teste externo e à alta variabilidade entre configurações de RN, recomenda-se ampliar validações e executar análises adicionais antes de adopção em produção.

## 11. Ficheiros de saída e reprodutibilidade

Principais ficheiros gerados durante o trabalho:

- [results/comparacao_cbr_vs_rn.csv](results/comparacao_cbr_vs_rn.csv)
- [results/comparacao_rn_3best_3worst_norm.csv](results/comparacao_rn_3best_3worst_norm.csv)
- [results/cbr_weights_analysis.csv](results/cbr_weights_analysis.csv)
- Várias figuras e matrizes de confusão em [results/](results/)

Scripts principais usados para reproduzir os passos:

- `CBR/` — `cbr_retrieve.m`, `cbr_reuse.m`, `cbr_revise.m`, `local_similarity.m`
- `RN/` — `train_network.m`, `test_best_nets.m`, `build_inputs.m`, `build_targets.m`
- `datasetfix/` e `data/` — scripts para limpeza e processamento do dataset

Para reproduzir: executar os scripts `main_task2.m`, `main_task3.m` e `main_task4.m` conforme comentários nos ficheiros.
 
## Anexos — Tabelas de resultados

### 1) Análise de pesos no CBR

| Configuração | Acertos (Sem Normalização) | Taxa % (Sem) | Acertos (Com Normalização) | Taxa % (Com) |
|---|---:|---:|---:|---:|
| Default (Balanceado) | 30 | 100 | 30 | 100 |
| Pesos Iguais | 30 | 100 | 30 | 100 |
| Sensores Principais | 30 | 100 | 30 | 100 |
| Foco Mecânico | 30 | 100 | 30 | 100 |
| Foco Elétrico | 30 | 100 | 30 | 100 |
| Sem Contexto | 30 | 100 | 30 | 100 |

### 2) Comparação CBR vs RN (resumo)

| Método | Família | Normalização | Acertos | Acc Global | Acc Normal | Acc Electrical | Acc Mechanical |
|---|---|---|---:|---:|---:|---:|---:|
| CBR melhor sem normalização | CBR | não | 30 | 100 | 100 | 100 | 100 |
| CBR melhor com normalização | CBR | sim | 30 | 100 | 100 | 100 | 100 |

### 3) RN — 3 melhores e 3 piores (detalhado)

| Metodo | Grupo | Normalização | Acertos | Acc_Global | Acc_Normal | Acc_Electrical | Acc_Mechanical |
|---|---|---|---:|---:|---:|---:|---:|
| Melhor 1 - nao_normalizado | Melhor 1 | não | 30 | 100.00 | 100.00 | 100 | 100 |
| Melhor 1 - normalizado | Melhor 1 | sim | 30 | 100.00 | 100.00 | 100 | 100 |
| Melhor 2 - nao_normalizado | Melhor 2 | não | 30 | 100.00 | 100.00 | 100 | 100 |
| Melhor 2 - normalizado | Melhor 2 | sim | 30 | 100.00 | 100.00 | 100 | 100 |
| Melhor 3 - nao_normalizado | Melhor 3 | não | 30 | 100.00 | 100.00 | 100 | 100 |
| Melhor 3 - normalizado | Melhor 3 | sim | 30 | 100.00 | 100.00 | 100 | 100 |
| Pior 1 - nao_normalizado | Pior 1 | não | 14 | 46.6667 | 38.4615 | 70 | 28.5714 |
| Pior 1 - normalizado | Pior 1 | sim | 14 | 46.6667 | 84.6154 | 0 | 42.8571 |
| Pior 2 - nao_normalizado | Pior 2 | não | 16 | 53.3333 | 53.8462 | 20 | 100 |
| Pior 2 - normalizado | Pior 2 | sim | 13 | 43.3333 | 30.7692 | 20 | 100 |
| Pior 3 - nao_normalizado | Pior 3 | não | 21 | 70.00 | 92.3077 | 90 | 0 |
| Pior 3 - normalizado | Pior 3 | sim | 21 | 70.00 | 92.3077 | 30 | 85.7143 |

## 12. Notas finais

Se desejar, posso:

- Expandir o relatório com figuras e interpretações das matrizes de confusão.
- Gerar um sumário executivo em formato curto (1 página).
- Executar validações adicionais (k-fold ou bootstrap) e actualizar o relatório com resultados estatísticos.

---

Relatório gerado a partir dos resultados e ficheiros presentes no repositório.

