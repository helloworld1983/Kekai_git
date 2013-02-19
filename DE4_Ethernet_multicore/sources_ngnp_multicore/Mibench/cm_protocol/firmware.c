#include "ngnp.h"

void YF32_ISR(void){}

int catvars(int buf1[], unsigned short len1, unsigned short len2);

int main(int argc, char **argv)
{

        
	unsigned int d;
	
	while(1){
             
		// determine output port
		get_pkt(0,d);
		d = d | 0x00040000;
		put_pkt(0,d);
                unsigned int d1;
         
	        _u32 ip_dst_hi;
                _u32 ip_dst_low;
                _u32 ip_dst;

                pkt_get16(IP_DEST_ADDR_HI, d1);
                    			pkt_get16(IP_DEST_ADDR_LOW, ip_dst_low);
        				ip_dst_hi=((d1 << 16) & 0xffff0000);
        				ip_dst= ip_dst_hi + ip_dst_low;

                pkt_dbg(0x531, ip_dst);

                int i=0;
                _u32 bufsize;
                _u32 packet_length;
                _u32 ip_ttl = 0;
                pkt_get8(IP_TTL, ip_ttl);
                pkt_dbg(0x552, ip_ttl);

                pkt_get16(NF2_PACKET_LENGTH8, packet_length);
                bufsize = packet_length - ETHER_SIZE -IP_SIZE; /* size of TCP packet = link layer- ethernet hdr - ip hdr */
                packet_length = bufsize ;
                pkt_dbg(0x543, bufsize);
                int buf[bufsize];
                int *packet = &buf[0];
                for(i=0;i<((bufsize/4)-1);i++){
  	        pkt_get32((TCP_DST_PORT+4*i), buf[i]);
                pkt_dbg((0x588+4*i), buf[i]);
                }
		//char buffer1[]="triapoulakiakathontan";
		/*int buffer1[]={0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0xeeeeeeee,0x00003dbc,0x00003dbc,0x00003dbc,0x00003dbc,0x00003dbc,0x00003dbc,0x00003dbc,0x00003dbc,0x00003dbc,0x00003dbc,0x00003e62,0x00003e62,0x00003e62,0x00003e62,0x00003e62,0x00003e62,0x00003e62,0x00003e62,0x00003e62,0x00003e62,0x080000c5,0x080000c5,0x080000c5,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5,0x080000c5};*/
                unsigned short one = 0x0012;
                unsigned short two;
                
              
                //pkt_get16(TCP_WINDOW_SIZE, two);
                pkt_get16(TCP_LENGTH, two);
                pkt_dbg(0x432, two); 
                
                unsigned short sum;
                sum=one+two;
                
                
                pkt_dbg(0x567, sum);

                catvars(buf, one, two);
		pkt_finish(1);
                
	}
      
}
