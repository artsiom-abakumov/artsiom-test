FROM docker.io/google/cloud-sdk:535.0.0-slim

WORKDIR /root
ENTRYPOINT [ "/bin/bash" ]
ENV KIND_EXPERIMENTAL_PROVIDER=podman

#Install kubectl. Set up autocompletion and alias for kubectl
RUN /bin/bash -c 'apt-get update && apt-get install -y apt-transport-https; \
                curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -; \
                echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list; \
                apt-get update; \
                apt-get install -y kubectl; \
                apt-get install bash-completion; \
                kubectl completion bash >/etc/bash_completion.d/kubectl; \
                echo "source /usr/share/bash-completion/bash_completion" >>/root/.bashrc; \
                echo "alias k=kubectl" >>~/.bashrc; \
                echo "complete -F __start_kubectl k" >>~/.bashrc'

#Add wget
RUN /bin/bash -c 'apt-get install wget'

#Install kubectx with aliases and fzf for interactive context and namespace selection
RUN /bin/bash -c 'apt-get install fzf'
RUN /bin/bash -c 'wget https://github.com/ahmetb/kubectx/releases/download/v0.9.5/kubectx_v0.9.5_linux_x86_64.tar.gz; \
                wget https://github.com/ahmetb/kubectx/releases/download/v0.9.5/kubens_v0.9.5_linux_x86_64.tar.gz; \
                tar -xvf kubectx_v0.9.5_linux_x86_64.tar.gz; \
                rm kubectx_v0.9.5_linux_x86_64.tar.gz; \
                tar -xvf kubens_v0.9.5_linux_x86_64.tar.gz; \
                rm kubens_v0.9.5_linux_x86_64.tar.gz; \
                chmod +x kubens; mv kubens /usr/local/bin/kubens; \
                chmod +x kubectx; mv kubectx /usr/local/bin/kubectx; \
                echo "alias ctx=kubectx" >>~/.bashrc; \
                echo "alias ns=kubens" >>~/.bashrc'

#Configure kube-ps1 for current context+namespace information in shell promt
ARG kubeon="PS1='[\u@\h \W $(kube_ps1)]\$ '"
RUN /bin/bash -c 'git clone https://github.com/jonmosco/kube-ps1.git; \
                mv ~/kube-ps1/kube-ps1.sh ~/kube-ps1.sh; \
                echo "source /root/kube-ps1.sh" >>/root/.bashrc; \
                echo $kubeon >>/root/.bashrc; \
                rm -rf ~/kube-ps1 '

#Add ack as better grep. Search in given directory without specific arguments.
# RUN /bin/bash -c 'apt-get install ack gnupg2 pass -y'
#Add tmux
# RUN /bin/bash -c 'apt-get install tmux -y'

# add podman
RUN /bin/bash -c 'apt-get -y install podman'

#Add unzip
RUN /bin/bash -c 'apt-get install unzip'

#Add vim
RUN /bin/bash -c 'apt-get install vim -y'

#Add cfssl and cfssljson
# ARG cfsslVer=1.4.1
# RUN /bin/bash -c "wget -nv https://github.com/cloudflare/cfssl/releases/download/v${cfsslVer}/cfssl_${cfsslVer}_linux_amd64; \
#                 wget -nv https://github.com/cloudflare/cfssl/releases/download/v${cfsslVer}/cfssljson_${cfsslVer}_linux_amd64; \
#                 chmod +x cfssl_${cfsslVer}_linux_amd64; \
#                 chmod +x cfssljson_${cfsslVer}_linux_amd64; \
#                 mv cfssl_${cfsslVer}_linux_amd64 /usr/local/bin/cfssl; \
#                 mv cfssljson_${cfsslVer}_linux_amd64 /usr/local/bin/cfssljson"

#Add docker-compose
# RUN /bin/bash -c 'apt-get install docker-compose -y'

#Add jq
RUN /bin/bash -c 'apt-get install jq -y'
# Add yq
RUN /bin/bash -c 'wget https://github.com/mikefarah/yq/releases/download/v4.47.1/yq_linux_amd64 -O /usr/local/bin/yq && chmod +x /usr/local/bin/yq'

#Add Vault
# ARG VaultVersion=1.9.3
# ARG VaultPackage="vault_${VaultVersion}_linux_amd64.zip"
# RUN /bin/bash -c 'curl -O https://releases.hashicorp.com/vault/${VaultVersion}/${VaultPackage}; \
#                  unzip ${VaultPackage}; \
#                  mv vault /usr/local/bin/vault; \
#                  rm ${VaultPackage}'

#Add TF Tools
RUN /bin/bash -c 'curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash'
RUN /bin/bash -c  "curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash"
RUN /bin/bash -c "curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh"

#Add Helm 3
RUN /bin/bash -c 'curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash; \
                    helm completion bash > /etc/bash_completion.d/helm'

#Add Azure CLI
RUN /bin/bash -c 'echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list \
    && curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && apt-get update \
    && curl -sL https://aka.ms/InstallAzureCLIDeb | bash'
#Add kubelogin
RUN /bin/bash -c "wget https://github.com/Azure/kubelogin/releases/download/v0.2.10/kubelogin-linux-amd64.zip; \
                    unzip kubelogin-linux-amd64.zip; \
                    mv bin/linux_amd64/kubelogin /usr/local/bin/kubelogin; \
                    rm kubelogin-linux-amd64.zip; rm -r bin; \
                    kubelogin completion bash > /etc/bash_completion.d/kubelogin"

# #Add glooctl
# ARG glooVer=v1.2.15
# RUN /bin/bash -c "wget -nv https://github.com/solo-io/gloo/releases/download/${glooVer}/glooctl-linux-amd64; \
#                 chmod +x glooctl-linux-amd64; \
#                 mv glooctl-linux-amd64 /usr/local/bin/glooctl; \
#                 glooctl completion bash >/etc/bash_completion.d/glooctl"

# Add k3d
# RUN /bin/bash -c 'curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash'

RUN /bin/bash -c 'curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64; \
                    chmod +x ./kind; \
                    mv ./kind /usr/local/bin/kind; \
                    kind completion bash > /etc/bash_completion.d/kind'

#Add latest istioctl
# RUN /bin/bash -c "curl -sL https://istio.io/downloadIstioctl | sh -; \
#                 mv ~/.istioctl/bin/istioctl /usr/local/bin/istioctl"
