#!/bin/bash
OUT=/opt/resultados5_$1.csv
echo "consulta,exec1_ms,exec2_ms,exec3_ms,exec4_ms,exec5_ms,mediana_ms" > $OUT
export PGOPTIONS='-c statement_timeout=120000'
rodar() {
  local s=$(date +%s%N)
  psql -U postgres -d tpch -q -v ON_ERROR_STOP=1 -f /opt/queries/q$1.sql > /dev/null 2>&1
  RC=$?
  MS=$(( ($(date +%s%N) - s) / 1000000 ))
}
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 16 17 18 19 20 21 22; do
  rodar $i   # aquecimento, descartado
  if [ $RC -ne 0 ]; then
    if [ $MS -ge 119000 ]; then m=TIMEOUT; else m=ERRO; fi
    echo "Q$i,$m,$m,$m,$m,$m,$m" | tee -a $OUT
    continue
  fi
  v=()
  for r in 1 2 3 4 5; do rodar $i; v+=($MS); done
  med=$(printf '%s\n' "${v[@]}" | sort -n | sed -n 3p)
  echo "Q$i,${v[0]},${v[1]},${v[2]},${v[3]},${v[4]},$med" | tee -a $OUT
done
echo "Pronto! Arquivo: $OUT"
