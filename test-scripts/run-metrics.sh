#!/bin/bash
NAMESPACE=$1
PROCESS_STATE=$(check-process.sh $PERF_ID )
echo 'POD,CPU(Mi),MEMORY(Mi),TIMESTAMP' > ./$TEST_ID/output.csv
echo 'POD,CPU(Mi),MEMORY(Mi),TIMESTAMP' > ./$TEST_ID/kafka-0-output.csv
echo 'POD,CPU(Mi),MEMORY(Mi),TIMESTAMP' > ./$TEST_ID/kafka-1-output.csv
echo 'POD,CPU(Mi),MEMORY(Mi),TIMESTAMP' > ./$TEST_ID/kafka-2-output.csv
counter=0
echo in metrics: $PROCESS_STATE
while
  [[ "${PROCESS_STATE}" !=  "STOPPED" ]]
do
  echo Taking snapshot of resource utilization - $counter to $TEST_ID/output.csv
  oc adm top pods -n $NAMESPACE -l 'statefulset.kubernetes.io/pod-name in (my-cluster-kafka-0, my-cluster-kafka-1, my-cluster-kafka-2)' | sed 1d | awk -v timestamp=$(date +%F:%T)  'BEGIN{FS=OFS=timestamp} {print $0 OFS value}' | awk -F' ' 'BEGIN{OFS=",";} {gsub(/[Mi]/,""); print $1,$2,$3,$4;}' | awk '{gsub(/m,/,","); print }' >> ./$TEST_ID/output.csv 
  sleep 10
  PROCESS_STATE=$(check-process.sh $PERF_ID )
  echo METRICS:  -$PROCESS_STATE-
  (( counter++))
done
sed -n '/kafka-0/p' ./$TEST_ID/output.csv >> ./$TEST_ID/kafka-0-output.csv
sed -n '/kafka-1/p' ./$TEST_ID/output.csv >> ./$TEST_ID/kafka-1-output.csv
sed -n '/kafka-2/p' ./$TEST_ID/output.csv >> ./$TEST_ID/kafka-2-output.csv
echo done metrics
exit 0
