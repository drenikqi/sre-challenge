resource "helm_release" "argo_cd" {
  depends_on = [module.eks]
  provider   = helm.my_clsuter
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "4.5.7" # Use the version of the chart you prefer

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}