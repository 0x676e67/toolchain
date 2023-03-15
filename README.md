# Script profiles

- 卸载docker (只适合Debian系)
```shell
wget -qO- https://raw.githubusercontent.com/gngpp/profiles/master/uninstall_docker.sh | bash
```

### Proxmox

- proxmox ve开启网卡sriov

```shell
wget https://raw.githubusercontent.com/gngpp/profiles/master/proxmox/ethernet_sriov.sh | bash +x ethernet_sriov.sh 
```  

### Synology
- 群晖（7.1）交叉工具链编译ixgbevf
```shell

#下载工具链
wget https://cndl.synology.cn/download/ToolChain/toolkit/7.1/base/base_env-7.1.txz
wget https://cndl.synology.cn/download/ToolChain/toolkit/7.1/apollolake/ds.apollolake-7.1.env.txz
wget https://cndl.synology.cn/download/ToolChain/toolkit/7.1/apollolake/ds.apollolake-7.1.dev.txz
wget https://cndl.synology.cn/download/ToolChain/toolchain/7.0-41890/Intel%20x86%20Linux%204.4.180%20%28Apollolake%29/apollolake-gcc750_glibc226_x86_64-GPL.txz
```
