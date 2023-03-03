- # nftables的nfqueue数据包读取  

- [环境搭建](#环境搭建)
- [数据包读取](#数据包读取)
- [创建网桥触发规则](#创建网桥触发规则)
- [网桥原理](#网桥原理)


## 环境搭建

```sh
apt install libnetfilter-queue-dev
apt install nftables
```

设置规则`nft -f test.rule`  
`ip`
```sh
table ip netvine-table {
	chain base-rule-chain {
		type filter hook prerouting priority filter; policy accept;
		iifname "enp0s6-enp0s7" log prefix "nftables-test" queue num 0
	}
}
```

`netdev`
```sh
table netdev netvine-table {
	chain base-rule-chain {
		type filter hook ingress device enp0s5 priority filter; policy accept;
		log prefix "nftables-test" queue num 0-3
	}
}
```
> enp0s5 具体的网卡  , queue num 0-3 , Queueing to userspace    

- ip: Used for IPv4 related chains.
- ip6: Used for IPv6 related chains.
- arp: Used for ARP related chains.
- bridge: Used for bridging related chains.
- inet: Mixed ipv4/ipv6 chains (kernel 3.14 and up).
- netdev: Used for chains that filter early in the stack (kernel 4.2 and up).  

tcpreplay的依赖
```sh
sudo apt-get install build-essential autogen libpcap-dev cmake openssl libssl-dev python3 autoconf automake libtool pkg-config m4 zlib1g-dev 
```


## 数据包读取  
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <netinet/in.h>
#include <linux/netfilter.h>
#include <libnetfilter_queue/libnetfilter_queue.h>

#define BUFSIZE 65536

void print_hex(char *buffer, int len){
	int i;
	for(i = 1; i <= strlen(buffer); i++){
		printf("0x%02X ",buffer[i-1]);					
		if(i % 16 == 0){
			printf("\n");
		}
	}
	printf("\n");
}

static int cb(struct nfq_q_handle *qh, struct nfgenmsg *nfmsg,
              struct nfq_data *nfa, void *data)
{
    u_int32_t id = 0;
    struct nfqnl_msg_packet_hdr *ph;
    ph = nfq_get_msg_packet_hdr(nfa);
    if (ph) {
        id = ntohl(ph->packet_id);
    }

    int len = nfq_get_payload(nfa, (unsigned char **)(&data));
    if (len > 0) {
        // 对数据包进行处理
		// printf("接收的数据包:%d->%s\n", len,data);
		print_hex(data, len);
    }

    return nfq_set_verdict(qh, id, NF_ACCEPT, 0, NULL);
}


int main(int argc, char **argv)
{
    struct nfq_handle *h;
    struct nfq_q_handle *qh;
    struct nfnl_handle *nh;
    int fd, rv;
    char buf[BUFSIZE] __attribute__ ((aligned));
    unsigned char *data;
    struct nfq_data *nfad;
    int len;

    // 初始化netfilter_queue
    h = nfq_open();
    if (!h) {
        fprintf(stderr, "nfq_open() error\n");
        exit(1);
    }

    // 绑定到nfqueue队列号为0的队列
    if (nfq_unbind_pf(h, AF_INET) < 0) {
        fprintf(stderr, "nfq_unbind_pf() error\n");
        exit(1);
    }
    if (nfq_bind_pf(h, AF_INET) < 0) {
        fprintf(stderr, "nfq_bind_pf() error\n");
        exit(1);
    }
    qh = nfq_create_queue(h, 0, &cb, NULL);
    if (!qh) {
        fprintf(stderr, "nfq_create_queue() error\n");
        exit(1);
    }
    if (nfq_set_mode(qh, NFQNL_COPY_PACKET, BUFSIZE) < 0) {
        fprintf(stderr, "nfq_set_mode() error\n");
        exit(1);
    }

    // 打开netlink socket
    nh = nfq_nfnlh(h);
    fd = nfnl_fd(nh);

    while (1) {
        rv = recv(fd, buf, sizeof(buf), 0);
        if (rv >= 0) {
            nfq_handle_packet(h, buf, rv);
            continue;
        }
        // 错误处理
        if (rv < 0) {
            fprintf(stderr, "recv() error\n");
            continue;
        }
    }

    nfq_destroy_queue(qh);
    nfq_close(h);

    return 0;
}
```

编译:  
```sh
 gcc -o main main.c -lnetfilter_queue -lnfnetlink
```

也可以使用`tcpdump -i nfqueue:0 -nnvvS`监听, 使用`nnvvXS`参数，可以显示16进制与ascii码
```sh
15:09:44.964616 IP6 (hlim 255, next-header ICMPv6 (58) payload length: 32) fe80::21c:42ff:fe00:18 > ff02::1:ff8a:5718: [icmp6 sum ok] ICMP6, neighbor solicitation, length 32, who has fe80::21c:42ff:fe8a:5718
	  source link-address option (1), length 8 (1): 00:1c:42:00:00:18
	    0x0000:  001c 4200 0018
15:09:44.964617 IP6 (hlim 255, next-header ICMPv6 (58) payload length: 32) fe80::21c:42ff:fe00:18 > ff02::1:ff8a:5718: [icmp6 sum ok] ICMP6, neighbor solicitation, length 32, who has fe80::21c:42ff:fe8a:5718
^Ctcpdump: Unable to write output: Interrupted system call
```

## 创建网桥触发规则  

创建网桥的普通模式：  
```sh
brctl addbr enp0s6-enp0s7
brctl addif enp0s6-enp0s7 enp0s6
brctl addif enp0s6-enp0s7 enp0s7
ip link set dev enp0s6 up
ip link set dev enp0s7 up
ip link set enp0s6-enp0s7 up
```

nftable输出日志(`tail -f /var/log/kern.log`)：
```sh
Mar  3 15:00:23 matrix kernel: [ 5879.059317] nftables-testIN=enp0s6-enp0s7 OUT= PHYSIN=enp0s6 MAC=00:1c:42:00:00:08:00:1c:42:5a:b0:7d:08:00 SRC=10.211.55.16 DST=10.211.55.2 LEN=1776 TOS=0x10 PREC=0x00 TTL=64 ID=48804 DF PROTO=TCP SPT=22 DPT=57913 WINDOW=501 RES=0x00 ACK PSH URGP=0 
```

> 从结果可以看出，网桥模式也算是路由(route)  

## 网桥原理  

