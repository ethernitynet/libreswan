
#include "enet_tunnel_config_parse.h"

int main() {
	
	struct kernel_sa sa;
	struct connection c;
	unsigned char enckey[] = {
		0xae, 0xad, 0x4f, 0x9a, 0x82, 0xcf, 0xdc, 0xee, 
		0x1b, 0xad, 0x6b, 0xbe, 0xbb, 0x03, 0x04, 0x17, 
		0x4f, 0x85, 0xbc, 0xa6
	};
    typedef union {
        struct sockaddr_in v4;
        struct sockaddr_in6 v6;
    } u;
	u dst_u;
    u src_u;
    ip_address src;
    ip_address dst;
	dst_u.v4.sin_addr.s_addr = 18262026;
	src_u.v4.sin_addr.s_addr = 17500938;
	struct ike_alg integ_common;
	struct integ_desc integ;
	struct ike_alg encrypt_common;
	struct encrypt_desc encrypt;
	
	c.spd.this.client.addr.u.v4.sin_addr.s_addr = 65676;
	c.spd.this.client.maskbits = 24;
	c.spd.that.client.addr.u.v4.sin_addr.s_addr = 131212;
	c.spd.that.client.maskbits = 24;
	
	*(u *)&(dst.u) = dst_u;
	*(u *)&(src.u) = src_u;
	sa.dst = &dst;
	sa.src = &src;
	sa.inbound = false;
	sa.spi = 1309108608;
	
	integ_common.fqn = "NONE";
	memcpy(&(integ.common), &integ_common, sizeof(struct ike_alg));
	sa.integ = &integ;
	sa.authkeylen = 0;
	sa.authkey = "";
	
	encrypt_common.fqn = "AES_GCM_16";
	memcpy(&(encrypt.common), &encrypt_common, sizeof(struct ike_alg));
	sa.encrypt = &encrypt;
	sa.enckeylen = 20;
	sa.enckey = enckey;
	
	enet_tunnel_config config;
	
	enet_tunnel_config_parse(&config, &sa, &c);
	enet_tunnel_config_apply("http://172.17.0.1:44000", &config);
	return 0;
};
