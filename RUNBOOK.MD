## Maria-db verification
apt update
apt install -y netcat-openbsd
kubectl -n demo exec -it web-server-6d94dbb86b-57q8n -- sh -c "nc -vz mariadb-primary 3306"
kubectl -n demo exec -it web-server-6d94dbb86b-57q8n -- sh -c "nc -vz mariadb-secondary 3306"
kubectl -n demo exec -it web-server-6d94dbb86b-57q8n -- sh -c "nc -vz mariadb-secondary 3306"

# From a non-web pod (e.g., busybox), verify DB access is blocked:
kubectl -n demo run test --image=busybox --restart=Never -- sleep 3600
kubectl -n demo exec -it test -- sh -c "nc -vz mariadb-primary 3306"

## network policies
kubectl get networkpolicies -n demo


## List Node Labels
kubectl get node ip-10-0-1-174.ec2.internal -o json | jq '.metadata.labels'

# I have to install calico plugin for additionally 
helm repo add projectcalico https://projectcalico.docs.tigera.io/charts
helm repo update

helm install calico projectcalico/tigera-operator \
  --namespace tigera-operator \
  --create-namespace