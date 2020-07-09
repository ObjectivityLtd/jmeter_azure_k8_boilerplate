
## Setup
You can either create your own cluster during set up or attach to an exisiting one.
Note: Cluster for jmeter should be fully dedicated to Jmeter tests and run no other services.
The commands in here should be executed from Azure CLI

### a) Creating brand new cluster during set-up via script (also creates k8 connection in DevOps):

1. Edit setup_cluster.sh/setVARS and set all required cluster parameters such as:
  * cluster_name=k8
  * cluster_namespace=jmeter
  * kubernetes_version=1.15.10
  * node_count=3 #minimum 3 nodes are required for jmeter
  * git_path=jmeter_azure_k8_boilerplate
  .....
2. In Azure CLI set secrets that are required to automatically create k8 connection in DevOps  portal e.g. (if you skip this step, you will have to create the connection manually)

`vi .bash_profile`

        #!/bin/bash
        export pat=YOUR_PATH

3.Load secrets with:

  `source bash_profile`

4.Change 'jmeter_azure_k8_boilerplate' to your repo name and 'jmeter-group' to group you want to use to create the cluster in. Run

`repo=jmeter_azure_k8_boilerplate && cd ~ && rm -Rf $repo && git clone  https://github.com/ObjectivityLtd/$repo  && cd $repo/pipelines/azure && bash setup_cluster.sh jmeter-group`

### b) Creating brand new cluster via Azure CLI

Execute that in Azure CLI, changing parameters to your needs:

` az group create -l westeurope -n jmeter-group 

  az aks create --resource-group jmeter-group --name k8 --kubernetes-version 1.16.12 --node-vm-size Standard_D3_v2 --node-count 4 --enable-addons monitoring --generate-ssh-keys
  
  az aks get-credentials --resource-group jmeter-group --name k8 --overwrite-existing
   
  kubectl get no
  
  kubectl get po`

Go to DevOps and set up a k8 connection to your cluster.

## Attaching to an existing cluster

To attach to an existing cluster you need a valid Service Connection in DevOps.
Edit the pipeline pipline/azure/attach.to.existing.kubernetes.yaml and set k8 connection name and cluster namespace (if different than default). Run the pipeline to create Jmeter deployment.

## Usage

There are 3 pipelines supplied that you can use regardless of whether you created your own cluster or used an existing one:

* run.jmeter.kubernetes.yaml - runs tests
* stop.jmeter.kubernetes.yaml - stops tests gracefully
* attach.to.existing.kubernetes.yaml - redeploys the solution on kubernetes


Happy testing! :) 