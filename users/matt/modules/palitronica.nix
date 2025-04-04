{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ansible
    argocd
    drone-cli
    go-task
    graphviz
    helm-docs
    krew
    ktop
    kubecolor
    kubectl
    kubectx
    kubespy
    kubernetes-helm
    minio-client
    openvpn
    packer
    podman
    podman-compose
    pre-commit
    restic
    sops
    terraform
    terraform-docs
    terragrunt
    tfk8s
    tflint
    tfsec
    tshark
    vault
  ];

  programs = {
    k9s = {
      enable =true;
    };
  };
}
