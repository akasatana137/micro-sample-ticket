apiVersion: v1
clusters:
- cluster:
    server: ${cluster_endpoint}
    certificate-authority-data: ${cluster_cert}
  name: ${cluster_name}
contexts:
- context:
    cluster: ${cluster_name}
    user: ${cluster_name}
  name: ${cluster_name}
current-context: ${cluster_name}
kind: Config
preferences: {}
users:
- name: ${cluster_name}
  user:
    token: ${token}
