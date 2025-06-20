{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ansible
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
    pgcli
    podman
    podman-compose
    posting
    pre-commit
    restic
    sops
    sshs
    sslscan
    terraform
    terraform-docs
    terraform-ls
    terragrunt
    tfk8s
    tflint
    tfsec
    tshark
    vault
    vault-medusa
  ];

  programs = {
    k9s = {
      enable =true;
    };
  };
}
