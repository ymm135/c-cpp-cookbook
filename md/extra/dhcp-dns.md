- # DHCP-DNS  

主机使用动态主机配置协议（`Dynamic Host Configuration Protocol, DHCP`），紧接着加电启动后，收集到包括了 IP 地址、子网掩码及默认网关等初始配置信息。因为所有主机都需要一个 IP 地址，以在 IP 网络中进行通信，而 DHCP 就减轻了手动为每台主机配置一个 IP 地址的管理性负担。

域名系统（`Domain Name System, DNS`）将主机名称映射到 IP 地址，使得你可`www.in60days.com`输入到 `web` 浏览器中，而无需输入寄存该站点的服务器 IP 地址。


## DHCP
### DHCP功能
DHCP通过在网络上给主机自动分配 IP 信息，简化了网络管理任务。分配的信息可以包括 IP 地址、子网掩码及默认网关，且通常实在主机启动时。  

在主机第一次启动时，如其已被配置为采用 `DHCP` （大多数主机都是这样的），它就会发出一个询问分配 `IP` 信息的广播报文。该广播将为 `DHCP` 服务器收听到，同时该信息会被中继。  

> Farai指出 -- "这是假定主机和 DHCP 服务器实在同一子网的情形，而如它们不在同一子网，就看下面的ip helper-address命令。"  


<br>
<div align=center>
    <img src="../../res/image/extra/dhcp-dns-1.png" width="80%"></img>  
</div>
<br>

DHCP具体使用 UDP 端口67和68，来在网络上通信，同时，尽管在需要时路由器也可实现 `DHCP` 功能，但通常都会使用具体服务器作为 `DHCP` 服务器。在需要时，路由器同样可以配置为从 `DHCP` 服务器取得其接口 IP 地址，但很少这样做。配置这个特性的命令如下。

> Router(config-if)#ip address dhcp  

客户端的 DHCP 状态如下：

- 初始化，initialising
- 选择，selecting
- 请求，requesting
- 绑定，bound
- 更新，renewing
- 重绑定，rebinding


<br>
<div align=center>
    <img src="../../res/image/extra/dhcp-dns-2.png" width="80%"></img>  
</div>
<br>

DHCP服务器可被配置为在一个名为`租期`的特定时期，赋予某台主机一个 IP 地址。租期可以是几个小时或几天。对于那些不能在网络上分配给主机的 IP 地址，可以也应该予以保留。这些保留的 IP 地址，将是已被路由器接口或服务器所使用的地址。如未能保留这些地址，就会看到网络上的重复 IP 地址告警，因为 DHCP 服务器已将配置给路由器或服务器的地址，分配给了主机。

下面的图14.2中，可以看到完整的 DHCP 请求和分配过程。  

1. DHCP发现数据包（DHCP Discover packet）当某台设备启动后，同时其被配置为通过 DHCP 取得一个地址时，就会发出一个自 UDP 端口68(UDP port 68, bootpc）到 UDP 端口67(UDP port 67, bootps）的广播数据包。该数据包将到达网络上的所有设备，包括任何位处网络上的可能的 DHCP 服务器。

> **DHCP提议数据包**（DHCP Offer packet），本地网络上的 DHCP 服务器看到由客户端发出的广播发现报文（the broadcasted Discover message），就用 UDP 源端口`bootps 67`及目的端口`bootpc 68`, 同样以广播地址的形式，发回一个响应（就是 DHCP 提议数据包）。之所以同样以广播地址形式，是因为客户端此时仍然没有 IP 地址，而无法接收单播数据包。  


2. DHCP请求数据包（DHCP Request packet）, 一旦客户端工作站收到由 DHCP 服务器做出的提议（an offer made by the DHCP server），它就会发出一个广播（用于告知所有 DHCP 服务器，它已接受了来自某台服务器的提议） DHCP 请求报文到某台特定的 DHCP 服务器，并再度使用 UDP 源端口bootpc 68及目的端口bootps 67。客户端可能会收到来自多台 DHCP 服务器的提议，但它只需单独一个 IP 地址，所以它必需选择一台 DHCP 服务器（基于服务器标识），而选择通常都是按照"先到，先服务"原则完成的（on a "first-come, first-served" basis）。

3. DHCP确认数据包（DHCP ACK packet）, 选中的那台 DHCP 服务器发出另一个广播报文，来确认给那台特定客户端的地址分配，再度用到 UDP 源端口bootps 67及目的端口bootpc 68。  



### 搭建环境验证

## DNS
### DNS 功能
DNS将主机名映射到 IP 地址（而不是反过来）。这就允许你在 web 浏览器中浏览一个网址，而无需输入服务器 IP 地址。  

在主机或路由器想要将一个域名解析到 IP 地址（或反过来将 IP 地址解析到域名时）， `DNS` 用到`UDP 53`号端口。而在两台 `DNS` 服务器之间打算同步或分享它们的数据库时，就使用`TCP 53`号端口。  

如想要容许路由器找到 web 上的某台 DNS 服务器，就使用命令ip name-server 1.1.1.1，或是服务器相应的地址。  

也可以将某个主机名设置到路由器上的一个 IP 地址表中来节省时间，或是令到更易于记住要ping的或是连接到的哪台设备，如下面的输出所示。  

```sh
Router(config)#ip host R2 192.168.1.2
Router(config)#ip host R3 192.168.1.3
Router(config)#exit
Router#ping R2
Router#pinging 192.168.1.2
!!!!!
```



