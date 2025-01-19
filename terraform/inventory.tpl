[definition]
k8s-master ansible_host=${master_ip} ansible_public_ip=${master_ip} ansible_private_ip=${master_private_ip} server_id=${master_id}

%{ for worker in worker_ips ~}
${worker.name} ansible_host=${worker.ip} ansible_public_ip=${worker.ip} ansible_private_ip=${worker.private_ip} server_id=${worker.id}
%{ endfor ~}

k8s-vpn ansible_host=${vpn_ip} ansible_public_ip=${vpn_ip} ansible_private_ip=${vpn_ip} server_id=${vpn_id}

[vpn]
k8s-vpn

[webservers]
k8s-master
%{ for worker in worker_ips ~}
${worker.name}
%{ endfor ~}

[master]
k8s-master

[workers]
%{ for worker in worker_ips ~}
${worker.name}
%{ endfor ~}

[all]
k8s-master
%{ for worker in worker_ips ~}
${worker.name}
%{ endfor ~}
k8s-vpn
