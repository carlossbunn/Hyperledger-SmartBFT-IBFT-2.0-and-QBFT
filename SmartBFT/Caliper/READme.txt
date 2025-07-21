caliper-benchmark.yaml – Define os testes (carga, TPS, latência e payload)
caliper-network.yaml – Descreve a rede, peers, orderers e certificados

execução para rodar:
npx caliper launch manager \
  --caliper-workspace . \
  --caliper-benchmark caliper-benchmark.yaml \
  --caliper-network caliper-network.yaml
