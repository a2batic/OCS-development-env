#!/bin/bash
# Deploying Snapshot and scheduler CRs/operator - Kanika (@a2batic).

if [ ! -d "csi-driver-host-path" ]
then
    echo "Cloning Snapshot CR"
    git clone https://github.com/kubernetes-csi/csi-driver-host-path.git
fi
cd csi-driver-host-path
git fetch origin
git rebase origin/master
echo "Deploying Snapshot CR"
deploy/kubernetes-1.17/deploy-hostpath.sh
echo "Creating dummy resourced"
for i in ./examples/csi-storageclass.yaml ./examples/csi-pvc.yaml ./examples/csi-app.yaml; do kubectl apply -f $i; done
echo "Making Snapshot Class default"
kubectl patch volumesnapshotclass csi-hostpath-snapclass --patch "$(cat snapshot-patch.yaml)" --type=merge
if [ ! -d "snapscheduler" ]
then
    echo "Cloning Schedule CR"
    git clone https://github.com/a2batic/snapscheduler.git
fi
cd snapscheduler
git fetch origin
git rebase origin/master
echo "Deploying Scheduling CR"
kubectl apply -f deploy/crds/snapscheduler.backube_snapshotschedules_crd.yaml
echo "RBAC for scheduling"
kubectl apply -f deploy/service_account.yaml
kubectl apply -f deploy/role.yaml
kubectl apply -f deploy/role_binding.yaml
echo "Deploying operator CR"
kubectl apply -f deploy/operator.yaml
echo "Verifying successful scheduler deployed"
kubectl -n default get deployment/snapscheduler
kubectl -n default get deployment/snapscheduler
kubectl -n default get deployment/snapscheduler
echo "done"
