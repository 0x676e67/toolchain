# profiles

- 卸载docker (只适合Debian系)
```shell
wget -qO- https://raw.githubusercontent.com/gngpp/profiles/master/uninstall_docker.sh | bash
```

### Proxmox

- proxmox ve开启网卡sriov

```shell
wget https://raw.githubusercontent.com/gngpp/profiles/master/proxmox/init_sriov.sh | bash +x init_sriov.sh 
```  