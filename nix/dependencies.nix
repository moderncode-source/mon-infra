pkgs:
with pkgs; [
  kubectl # Communicate with Kubernetes control plane.
  minikube # Create local Kubernetes clusters.

  # Manage helm charts.
  kubernetes-helm
  helmfile

  # Manage Jsonnet.
  jsonnet
  jsonnet-bundler # Package manager.
  gojsontoyaml # Create manifests.
]
