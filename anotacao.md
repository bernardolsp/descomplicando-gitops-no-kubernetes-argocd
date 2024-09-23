https://github.com/bernardolsp/descomplicando-gitops-no-kubernetes-argocd

# Senha inicial "secret"
argocd-initial-admin-secret
kubectl get secret -n argocd argocd-initial-admin-secret -o yaml
DcEgL5AY55Dt9feK

# Verificando as aplicações
k get applications -A