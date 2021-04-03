kind delete clusters primary

cat <<EOF | kind create cluster --wait 180s --name "primary" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "127.0.0.1"
  apiServerPort: 6443
nodes:
- role: control-plane
  image: kindest/node:v1.18.8
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        authorization-mode: "AlwaysAllow"
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
#- role: worker
#  image: kindest/node:v1.18.8
EOF


kubectl config set current-context kind-primary

#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
#kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=300s

docker build --tag go-tests -f test/Dockerfile .

kind load docker-image go-tests --name primary

kubectl apply -f test/go-tests.yaml --namespace go-tests

kubectl wait --namespace go-tests --for=condition=complete job/go-tests --timeout=120s

pods=$(kubectl --namespace go-tests get pods --selector=job-name=go-tests --output=jsonpath='{.items[*].metadata.name}')
kubectl logs $pods -f
