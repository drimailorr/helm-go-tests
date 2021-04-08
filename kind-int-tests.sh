
#%%

kind delete clusters primary

#%%
cat <<EOF | kind create cluster --wait 180s --name "primary" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
#  disableDefaultCNI: true
  apiServerAddress: "127.0.0.1"
  apiServerPort: 6443
nodes:
- role: control-plane
  image: kindest/node:v1.18.8
  extraMounts:
    - hostPath: ./test
      containerPath: /tests
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

#%%
kubectl config set current-context kind-primary

#%%
# Install ingress
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
#kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=300s

# Install Calico (disableDefaultCNI: true)
# curl https://docs.projectcalico.org/manifests/calico.yaml | kubectl apply -f -

#%%
docker build --tag go-tests -f test/Dockerfile.test .

#%%
# kind load dosen't recognize existing docker layers therefore very slow
# This looks clunky atm until better UI implemented: https://kind.sigs.k8s.io/docs/user/local-registry/
# hostPath volumes seem like a better way to decouple actual tests from docker image

#%%
kind load docker-image go-tests --name primary

#%%
kubectl delete job go-tests --namespace go-tests

#%%
kubectl apply -f test/go-tests.yaml --namespace go-tests

#%%
kubectl wait --namespace go-tests --for=condition=complete job/go-tests --timeout=300s

#%%
kubectl --namespace go-tests logs -l type=go-tests --tail=1500 -f
