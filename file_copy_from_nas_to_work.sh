files="filename1 filename2 ..." # separated by space
for pod in $(kubectl get po -n jupyter | grep user | cut -d ' ' -f 1) 
do
    for file in ${files}
    do
        kubectl exec -n jupyter ${pod} cp /home/jovyan/shared-data/${file} /home/jovyan/work
	done
done