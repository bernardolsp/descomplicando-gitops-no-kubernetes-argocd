resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd-prd"
  }
}

resource "helm_release" "argocd-prd" {
  name       = "argocd-prd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "6.0.3"
  namespace  = "argocd-prd"
  timeout    = "1200"
  values     = [templatefile("./argocd/install.yaml", {})]
}

resource "kubectl_manifest" "applicationset" {
  yaml_body = file("./argocd/Applicationset.yaml")
  depends_on = [ helm_release.argocd-prd ]
}

resource "kubectl_manifest" "ingress_application" {
  yaml_body = file("./argocd/Application.yaml")
  depends_on = [ helm_release.argocd-prd ]
}

resource "kubectl_manifest" "app_of_apps_monitoring" {
  yaml_body = file("./argocd/GiropopsSenhas.yaml")
  depends_on = [ helm_release.argocd-prd ]
}