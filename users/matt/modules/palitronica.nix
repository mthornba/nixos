{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ansible
    codex
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
    opencode
    openvpn
    packer
    pgcli
    podman
    podman-compose
    posting
    powershell
    pre-commit
    restic
    skopeo
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
    vagrant
    vault
    vault-medusa
    zarf
  ];

  programs = {
    k9s = {
      enable =true;
    };
  };
}
