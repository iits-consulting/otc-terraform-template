// GPU node pool for the AI bonus exercise, see README-GPU.md.
// Stays commented out for the normal workshop. For the bonus, uncomment everything
// below and run tofu init && tofu apply. Comment it out again to give the GPU back.

// module "cce_gpu_node_pool" {
//   source  = "iits-consulting/cce-gpu-node-pool/opentelekomcloud"
//   version = "7.5.1"

//   name_prefix    = module.cce_cluster.cluster_name
//   cce_cluster_id = module.cce_cluster.cluster_id

//   // pi2 flavors are not offered in every AZ. eu-de-01 and eu-de-03 are the usual ones.
//   node_availability_zones = ["eu-de-03"]
//   node_os                 = "HCE OS 2.0"

//   // pi2.2xlarge.4 = 8 vCPU, 32 GB RAM, 1x NVIDIA Tesla T4 (16 GB).
//   // Bigger options: pi2.4xlarge.4 (2x T4), pi2.8xlarge.4 (4x T4).
//   node_flavor = "pi2.2xlarge.4"

//   node_scaling_enabled = false
//   node_count           = 1
//   autoscaler_node_max  = 1

//   node_storage_type = "SSD"
//   node_storage_size = 200

//   // The module default is PreferNoSchedule, which only discourages other pods from
//   // using the expensive node. NoSchedule keeps everything without this toleration off
//   // it. DaemonSets that have to run here (CNI, CSI, the NVIDIA driver installer)
//   // tolerate all taints anyway.
//   node_taints = [{
//     effect = "NoSchedule"
//     key    = "gpu-node"
//     value  = "true"
//   }]

//   // The module installs the CCE AI Suite (gpu-beta) addon and pulls this NVIDIA driver
//   // onto every GPU node. R580 is the last branch that supports the Turing based T4.
//   gpu_driver_url = "https://us.download.nvidia.com/tesla/580.65.06/NVIDIA-Linux-x86_64-580.65.06.run"

//   tags = local.tags
// }
