# Bonus: run your own LLM on a GPU node pool

Your cluster is up and the workshop is done. Now add a GPU node pool to it and serve your
own model, first the quick way with `kubectl`, then properly over ArgoCD.

Every step is a task. Try it yourself, then open the solution.

> [!CAUTION]
> A GPU node bills by the hour and costs many times a normal worker node. Do task 5.

---

## Task 1: switch on the GPU node pool

`stages/dev/00_infra/gpu_node_pool.tf` already exists, but the whole module is commented
out, so it created nothing during the workshop. Turn it on, and while you are in there
point a second DNS record at the load balancer, you will need it in task 4.

<details>
<summary>Solution</summary>

Uncomment the module in `stages/dev/00_infra/gpu_node_pool.tf`. Read it while you do, it
picks `pi2.2xlarge.4` (8 vCPU, 32 GB RAM, one NVIDIA T4 with 16 GB) and the NVIDIA driver
that gets installed on the node.

Add `ai` to the `a_records` in `stages/dev/00_infra/dns.tf`:

```hcl
a_records = {
  (var.domain_name) = [module.public_loadbalancer.elb_public_ip]
  admin             = [module.public_loadbalancer.elb_public_ip]
  ai                = [module.public_loadbalancer.elb_public_ip]
}
```

Then in `stages/dev/00_infra`:

```shell
tofu init   # the module is new
tofu apply
```

The node needs around 10 minutes. It boots, then the CCE AI Suite addon installs the
NVIDIA driver, which is the slow part.

</details>

---

## Task 2: prove that Kubernetes sees the card

A node is not a GPU node until it reports the resource. Find out whether it does.

<details>
<summary>Solution</summary>

```shell
kubectl get nodes -o json | jq '.items[] | {name: .metadata.name, gpu: .status.allocatable["nvidia.com/gpu"]}'
```

One node reports `"1"`. The addon advertises the card as the extended resource
`nvidia.com/gpu`, so any pod that requests one can only be scheduled there. No node
selector needed.

The GPU nodes also carry the taint `gpu-node=true:NoSchedule`, so nothing but the GPU
workload gets onto the expensive node. Confirm the system DaemonSets still made it, they
tolerate every taint:

```shell
kubectl get ds -A
```

`DESIRED` and `READY` have to match for the CNI, the CSI driver and
`nvidia-driver-installer`.

</details>

---

## Task 3: serve a model, the quick way

`documentation/gpu-llm-stack.yaml` holds Ollama plus Open WebUI, published under
`ai.YOUR-DOMAIN` through the IngressRoute at the bottom. The manifest contains a
`REPLACE_ME_DOMAIN` placeholder, so it does not apply as is.

<details>
<summary>Solution</summary>

```shell
sed "s/REPLACE_ME_DOMAIN/$TF_VAR_domain_name/" documentation/gpu-llm-stack.yaml | kubectl apply -f -
kubectl -n ai get pods -w
```

Give it a few minutes. The Ollama image is 3.7 GB, then a `postStart` hook pulls
`qwen2.5:3b` (about 1.9 GB) into the PVC, so a restart is fast.

Then open `https://ai.YOUR-DOMAIN-NAME` and create an account. The first one becomes the
admin. The wildcard certificate from the workshop already covers the host, which is why
the IngressRoute only needs `tls: {}`.

What makes it a GPU workload is one line:

```yaml
limits:
  nvidia.com/gpu: 1
```

Only the GPU nodes advertise that resource, so the scheduler cannot put the pod anywhere
else. The toleration next to it is for the `gpu-node` taint, it is not what pins the pod.

Prove the card is doing the work:

```shell
kubectl -n ai exec deploy/ollama -- ollama ps
kubectl -n ai exec deploy/ollama -- nvidia-smi
```

`ollama ps` has to say `100% GPU`. `OLLAMA_KEEP_ALIVE=1h` keeps the model resident, so
`nvidia-smi` still shows it between two messages.

</details>

---

## Task 4: do it again, with GitOps

`kubectl apply` is not how the rest of this workshop works. Nothing tracks that manifest,
nothing heals it, and it is not in git. Move the same workload into ArgoCD.

<details>
<summary>Solution</summary>

Remove the hand-applied stack first, otherwise ArgoCD fights it for the same resources:

```shell
kubectl delete -f documentation/gpu-llm-stack.yaml
```

Then continue in your charts repository, which has its own bonus guide:
https://github.com/iits-consulting/otc-infrastructure-charts-template/blob/main/README-GPU.md

</details>

---

## Task 5: give the GPU back

Remove the workload and the node pool.

<details>
<summary>Solution</summary>

```shell
kubectl delete -f documentation/gpu-llm-stack.yaml --ignore-not-found
```

If you took the ArgoCD route, delete the `gpu-llm` entry from your charts repository
instead and push. Then comment the module in `gpu_node_pool.tf` out again and run
`tofu apply` in `stages/dev/00_infra`. The node pool goes away, check with
`kubectl get nodes`.

</details>

---

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| Node never reports `nvidia.com/gpu` | `kubectl -n kube-system logs -l app=nvidia-driver-installer --tail=50`. Usually the driver does not match the kernel. Try driver `535.129.03` together with `node_os = "EulerOS 2.9"` |
| Apply fails on the flavor | `pi2` is not in every AZ and sometimes sold out. Change `node_availability_zones` to `["eu-de-01"]` |
| Pod stays `Pending` with `Insufficient nvidia.com/gpu` | The driver is not ready yet, see the first row |
| `ollama ps` says `100% CPU` | The driver is up but Ollama did not find it. Check `kubectl -n ai logs deploy/ollama` for `no compatible GPUs were discovered` |
| Out of memory on a bigger model | The T4 has 16 GB. Stay at or below a 7B model in Q4, for example `qwen2.5:7b`. `qwen2.5:1.5b` is the safe fallback |
| Pod sits in `ContainerCreating` for minutes | Normal, it is pulling 3.7 GB. `kubectl -n ai get events --field-selector involvedObject.name=<pod>` shows the progress |
| `PolicyViolation` warnings on the pod | Kyverno runs those policies in audit mode. They are noise, the pod still starts |

The module README asks for `container_network_type = "vpc-router"` while this cluster runs
`overlay_l2`. In practice GPU nodes work on `overlay_l2`. Changing it would replace the
whole cluster, so only do that if you can trace a problem back to it.

> [!IMPORTANT]
> Workshop setup, not a production AI platform. For a proper one contact us at
> kontakt@iits-consulting.de
