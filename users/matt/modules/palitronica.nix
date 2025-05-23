{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ansible
    atac
    commitizen
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
    sshs
    terraform
    terraform-docs
    terraform-ls
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
