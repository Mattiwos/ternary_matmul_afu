#include <iostream>
#include <cmath>
#include <string.h>
#include <uuid/uuid.h>
#include <opae/fpga.h>
#include <time.h>
#include <stdlib.h>
#include <assert.h>
#ifndef USE_ASE
#include <hwloc.h>
#include <getopt.h>
#include <unistd.h>
#include <cstring>
#include "fpga_dma_internal.h"
#endif
#include "fpga_dma.h"
#include "fpga_dma_common.h"
#include "fpga_dma_test_utils.h"

using namespace std;

static int err_cnt = 0;
#define ON_ERR_GOTO(res, label, desc)\
	do {\
		if ((res) != FPGA_OK) {\
			err_cnt++;\
			fprintf(stderr, "Error %s: %s\n", (desc), fpgaErrStr(res));\
			goto label;\
		}\
	} while (0)

struct buf_attrs {
	unsigned char * va;
	uint64_t iova;
	uint64_t wsid;
	uint64_t size;
};

static struct buf_attrs battrs = {
	.va = NULL,
	.iova = 0,
	.wsid = 0,
	.size = 0
};

static fpga_token afc_tok;
static fpga_handle afc_h;
static fpga_dma_handle_t dma_h;
static fpga_handle afc_h_mmio;
static uint64_t *mmio_ptr;

fpga_result configure_numa(fpga_token afc_token, bool cpu_affinity, bool memory_affinity)
{
	fpga_result res = FPGA_OK;
	fpga_properties props;
	#ifndef USE_ASE
	// Set up proper affinity if requested
	if (cpu_affinity || memory_affinity) {
		unsigned dom = 0, bus = 0, dev = 0, func = 0;
		uint32_t num_mmio;
		int retval;
		#if(FPGA_DMA_DEBUG)
				char str[4096];
		#endif
		res = fpgaGetProperties(afc_token, &props);
		ON_ERR_GOTO(res, out, "fpgaGetProperties");
		res = fpgaPropertiesGetBus(props, (uint8_t *) & bus);
		ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesGetBus");
		res = fpgaPropertiesGetDevice(props, (uint8_t *) & dev);
		ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesGetDevice");
		res = fpgaPropertiesGetFunction(props, (uint8_t *) & func);
		ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesGetFunction");

		res = fpgaPropertiesGetNumMMIO(props, &num_mmio);
		ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesGetFunction");
		debug_print("Found %d MMIOs", num_mmio);

		// Find the device from the topology
		hwloc_topology_t topology;
		hwloc_topology_init(&topology);
		hwloc_topology_set_flags(topology,
					HWLOC_TOPOLOGY_FLAG_IO_DEVICES);
		hwloc_topology_load(topology);
		hwloc_obj_t obj = hwloc_get_pcidev_by_busid(topology, dom, bus, dev, func);
		hwloc_obj_t obj2 = hwloc_get_non_io_ancestor_obj(topology, obj);
		#if (FPGA_DMA_DEBUG)
			hwloc_obj_type_snprintf(str, 4096, obj2, 1);
			printf("%s\n", str);
			hwloc_obj_attr_snprintf(str, 4096, obj2, " :: ", 1);
			printf("%s\n", str);
			hwloc_bitmap_taskset_snprintf(str, 4096, obj2->cpuset);
			printf("CPUSET is %s\n", str);
			hwloc_bitmap_taskset_snprintf(str, 4096, obj2->nodeset);
			printf("NODESET is %s\n", str);
		#endif
		if (memory_affinity) {
			#if HWLOC_API_VERSION > 0x00020000
				retval = hwloc_set_membind(topology, obj2->nodeset,
								HWLOC_MEMBIND_THREAD,
								HWLOC_MEMBIND_MIGRATE | HWLOC_MEMBIND_BYNODESET);
			#else
				retval =
				hwloc_set_membind_nodeset(topology, obj2->nodeset,
								HWLOC_MEMBIND_BIND,
								HWLOC_MEMBIND_THREAD | HWLOC_MEMBIND_MIGRATE);
			#endif
			ON_ERR_GOTO((fpga_result)retval, out_destroy_prop, "hwloc_set_membind");
		}
		if (cpu_affinity) {
			retval = hwloc_set_cpubind(topology, obj2->cpuset, HWLOC_CPUBIND_STRICT);
			ON_ERR_GOTO((fpga_result)retval, out_destroy_prop, "hwloc_set_cpubind");
		}

	}

out_destroy_prop:
	res = fpgaDestroyProperties(&props);
	#endif
out:
	return res;
}

extern "C"
bool allocate_buffer(uint64_t buff_size)
{
	battrs.size = buff_size;
	fpga_result res;
	res = fpgaPrepareBuffer(afc_h, battrs.size, (void **)&(battrs.va), (uint64_t *)&battrs.wsid, 0);
	if(res != FPGA_OK)
		return true;
	res = fpgaGetIOAddress(afc_h, battrs.wsid, &battrs.iova);
	if(res != FPGA_OK) {
		res = fpgaReleaseBuffer(afc_h, battrs.wsid);
		return true;
	}
	debug_print("Allocated test buffer of size = %ld bytes\n", battrs.size);
	return res != FPGA_OK;
}

extern "C"
void populate_buffer_bytes(unsigned char * byte_pointer, uint64_t n_bytes)
{
	memset(battrs.va, 0, battrs.size);
	debug_print("ptr is 0x%08x\n", battrs.va);
	unsigned char * battrs_va_init = battrs.va;
	unsigned char * byte_pointer_init = byte_pointer;
	while(n_bytes) {
		*battrs.va = *byte_pointer;
		// debug_print("0x%02x\n", *battrs.va);
		n_bytes--;
		byte_pointer++;
		battrs.va++;
	}
	battrs.va = battrs_va_init;
	byte_pointer = byte_pointer_init;
	debug_print("ptr is 0x%08x\n", battrs.va);
}

extern "C"
void get_buffer_bytes(unsigned char * byte_pointer, uint64_t n_bytes)
{
	debug_print("ptr is 0x%02x\n", battrs.va);
	unsigned char * battrs_va_init = battrs.va;
	unsigned char * byte_pointer_init = byte_pointer;
	while(n_bytes) {
		*byte_pointer = *battrs.va;
		n_bytes--;
		byte_pointer++;
		battrs.va++;
	}
	battrs.va = battrs_va_init;
	byte_pointer = byte_pointer_init;
	debug_print("ptr is 0x%02x\n", battrs.va);
	memset(battrs.va, 0, battrs.size);
}

extern "C"
bool free_buffer()
{
	fpga_result res;
	res = fpgaReleaseBuffer(afc_h, battrs.wsid);
	battrs.va = NULL;
	battrs.iova = 0;
	battrs.wsid = 0;
	battrs.size = 0;
	return res != FPGA_OK;
}

fpga_result free_buffer_local()
{
	fpga_result res;
	res = fpgaReleaseBuffer(afc_h, battrs.wsid);
	return res;
}

int find_accelerator_matmul(
	const char *afu_id, 
	fpga_token *afu_tok
) {

	fpga_result res;
	fpga_guid guid;
	uint32_t num_matches = 0;
	fpga_properties filter = NULL;

	uuid_parse(afu_id, guid);

	res = fpgaGetProperties(NULL, &filter);
	ON_ERR_GOTO(res, out, "fpgaGetProperties");

	res = fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);
	ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesSetObjectType");

	res = fpgaPropertiesSetGUID(filter, guid);
	ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesSetGUID");

	res = fpgaEnumerate(&filter, 1, afu_tok, 1, &num_matches);
	ON_ERR_GOTO(res, out_destroy_prop, "fpgaEnumerate");

out_destroy_prop:
	res = fpgaDestroyProperties(&filter);
	ON_ERR_GOTO(res, out, "fpgaDestroyProperties");

out:
	if (num_matches > 0)
		return (int)num_matches;
	else
		return 0;
}

extern "C"
bool reset_afu (
) {
	fpga_result res = FPGA_OK;
	res = fpgaReset(afc_h);
	ON_ERR_GOTO(res, out_unmap, "fpgaReset");
	debug_print("applied afu reset\n");
	return res != FPGA_OK;

out_unmap:
	#ifndef USE_ASE
	if(afc_h) {
		res = fpgaUnmapMMIO(afc_h, 0);
		ON_ERR_GOTO(res, out_afc_close, "fpgaUnmapMMIO");
		debug_print("unmapped mmio\n");
	}
	#endif
out_afc_close:
	if (afc_h) {
		res = fpgaClose(afc_h);
		debug_print("closed afc\n");
	}
	return res != FPGA_OK;
}

extern "C"
bool open_afu_handle (
	const char * afu_id_to_look
) {
	fpga_result res = FPGA_OK;
	afc_h = NULL;
	debug_print("Looking for UUID: %s\n", afu_id_to_look);
	int ret = find_accelerator_matmul(afu_id_to_look, &afc_tok);
	if (ret == 1) {
		bool cpu_affinity = true;
		bool memory_affinity = true;
		debug_print("found %d accelerator(s)\n", ret);
		res = configure_numa(afc_tok, cpu_affinity, memory_affinity);
		ON_ERR_GOTO(res, out_afc_close, "configuring NUMA affinity");
	} else {
		debug_print("Error: found %d accelerator(s)\n", ret);
		return true;
	}
	res = fpgaOpen(afc_tok, &afc_h, 0);
	reset_afu();
	ON_ERR_GOTO(res, out_afc_close, "fpgaOpen");
	debug_print("Successfully opened afc handle!\n");
	return res != FPGA_OK;
out_afc_close:
	if (afc_h) {
		res = fpgaClose(afc_h);
		debug_print("closed afc\n");
	}
	return res != FPGA_OK;
}

static void transferComplete(void *ctx, fpga_dma_transfer_status_t status) {
	return;
}

extern "C"
bool open_dma_handle (
) {
	fpga_result res = FPGA_OK;
	mmio_ptr = NULL;
	res = fpgaMapMMIO(afc_h, 0, (uint64_t**)&mmio_ptr);
	ON_ERR_GOTO(res, out_afc_close, "fpgaMapMMIO");
	debug_print("mapped mmio\n");

	uint64_t ch_count;
	ch_count = 0;
	res = fpgaCountDMAChannels(afc_h, &ch_count);
	ON_ERR_GOTO(res, out_unmap, "fpgaGetDMAChannels");
	if(ch_count < 1) {
		fprintf(stderr, "DMA channels not found (found %ld, expected %d\n",
			ch_count, 2);
		ON_ERR_GOTO(FPGA_INVALID_PARAM, out_unmap, "count<1");
	}
	debug_print("Found %1d DMA channels!\n", ch_count);
	res = fpgaDMAOpen(afc_h, 0, &dma_h);
	ON_ERR_GOTO(res, out_unmap, "fpgaDMAOpen");
	debug_print("opened memory to memory channel\n");
	return res != FPGA_OK;

	if(dma_h) {
		res = fpgaDMAClose(dma_h);
		ON_ERR_GOTO(res, out_unmap, "fpgaDMAOpen");
		debug_print("closed dma channel\n");
	}
out_unmap:
	#ifndef USE_ASE
	if(afc_h) {
		res = fpgaUnmapMMIO(afc_h, 0);
		ON_ERR_GOTO(res, out_afc_close, "fpgaUnmapMMIO");
		debug_print("unmapped mmio\n");
	}
	#endif
out_afc_close:
	if (afc_h) {
		res = fpgaClose(afc_h);
	}
	return res != FPGA_OK;
}

extern "C"
bool dma_host_to_fpga (
	uint64_t fpga_addr,
	uint64_t addr_span,
	uint64_t payload_size
) {
	fpga_result res = FPGA_OK;
	// clear recieve buffer
	// memset(battrs.va, 0, battrs.size);
	fpga_dma_transfer_t transfer;
	int64_t tid, total_size;
	if(addr_span > battrs.size) {
		total_size = battrs.size;
		tid = ceil((double) battrs.size /(double)payload_size);
		fprintf(stderr, "Warning requested transfer larger than buffer size!");
	} else {
		total_size = addr_span;
		tid = ceil((double) addr_span /(double)payload_size);
	}
	uint64_t src = (uint64_t) battrs.iova; // host memory addr
	uint64_t dst = (uint64_t) fpga_addr; // fpga memory addr
	debug_print("TRNSFR from 0x%08x to 0x%08x\n", src, dst);
	res = fpgaDMATransferInit(&transfer);
	debug_print("init transfer\n");
	while(total_size > 0) {
		uint64_t transfer_bytes = MIN(total_size, payload_size);
		debug_print("Transfer src=%lx, dst=%lx, bytes=%ld\n", (uint64_t)src, (uint64_t)dst, transfer_bytes);
		fpgaDMATransferSetSrc(transfer, src);
		fpgaDMATransferSetDst(transfer, dst);
		fpgaDMATransferSetLen(transfer, transfer_bytes);
		fpgaDMATransferSetTransferType(transfer, HOST_MM_TO_FPGA_MM);
		// perform non-blocking transfers, except for the very last
		if(tid == 1) {
			fpgaDMATransferSetLast(transfer, true);
			fpgaDMATransferSetTransferCallback(transfer, NULL, NULL);
		} else {
			fpgaDMATransferSetTransferCallback(transfer, transferComplete, NULL);
		}
		res = fpgaDMATransfer(dma_h, transfer);
		ON_ERR_GOTO(res, free_transfer, "transfer error");
		total_size -= transfer_bytes;
		src += transfer_bytes;
		dst += transfer_bytes;
		tid--;
	}
free_transfer:
	if(transfer) {
		debug_print("destroying transfer\n");
		res = fpgaDMATransferDestroy(&transfer);
		debug_print("destroyed transfer\n");
	}
	return res != FPGA_OK;
}

extern "C"
bool dma_fpga_to_host (
	uint64_t fpga_addr,
	uint64_t addr_span,
	uint64_t payload_size
) {
	fpga_result res = FPGA_OK;
	// clear recieve buffer
	memset(battrs.va, 0, battrs.size);
	fpga_dma_transfer_t transfer;
	int64_t tid, total_size;
	if(addr_span > battrs.size) {
		total_size = battrs.size;
		tid = ceil((double) battrs.size /(double)payload_size);
		fprintf(stderr, "Critical Warning! requested transfer larger than buffer size!");
	} else {
		total_size = addr_span;
		tid = ceil((double) addr_span /(double)payload_size);
	}
	uint64_t src = (uint64_t) fpga_addr; // fpga memory addr
	uint64_t dst = (uint64_t) battrs.iova; // host memory addr
	debug_print("TRNSFR from 0x%08x to 0x%08x\n", src, dst);
	res = fpgaDMATransferInit(&transfer);
	debug_print("init transfer %d\n", res);
	while(total_size > 0) {
		uint64_t transfer_bytes = MIN(total_size, payload_size);
		debug_print("Transfer src=%lx, dst=%lx, bytes=%ld\n", (uint64_t)src, (uint64_t)dst, transfer_bytes);

		fpgaDMATransferSetSrc(transfer, src);
		fpgaDMATransferSetDst(transfer, dst);
		fpgaDMATransferSetLen(transfer, transfer_bytes);
		fpgaDMATransferSetTransferType(transfer, FPGA_MM_TO_HOST_MM);
		
		// perform non-blocking transfers, except for the very last
		if(tid == 1) {
			fpgaDMATransferSetLast(transfer, true);
			fpgaDMATransferSetTransferCallback(transfer, NULL, NULL);
		} else {
			fpgaDMATransferSetTransferCallback(transfer, transferComplete, NULL);
		}

		res = fpgaDMATransfer(dma_h, transfer);
		ON_ERR_GOTO(res, free_transfer, "transfer error");
		total_size -= transfer_bytes;
		src += transfer_bytes;
		dst += transfer_bytes;
		tid--;
	}
free_transfer:
	if(transfer) {
		debug_print("destroying transfer\n");
		res = fpgaDMATransferDestroy(&transfer);
		debug_print("destroyed transfer\n");
	}
	// memset(battrs.va, 0, battrs.size);
	return res != FPGA_OK;
}

extern "C"
bool close_all (
) {
	fpga_result res = FPGA_OK;
	res = free_buffer_local();
	ON_ERR_GOTO(res, out_dma, "fpgaBufferFree");
	debug_print("Closed buffer\n");
out_dma:
	if(dma_h) {
		res = fpgaDMAClose(dma_h);
		ON_ERR_GOTO(res, out_unmap, "fpgaDMAOpen");
		debug_print("closed dma channel\n");
	}
out_unmap:
	#ifndef USE_ASE
	if(afc_h) {
		res = fpgaUnmapMMIO(afc_h, 0);
		ON_ERR_GOTO(res, out_afc_close, "fpgaUnmapMMIO");
		debug_print("unmapped mmio\n");
	}
	#endif
out_afc_close:
	if (afc_h) {
		res = fpgaClose(afc_h);
		debug_print("closed afc\n");
	}
	return res;
}

extern "C"
bool mmioW64 (
	uint64_t mmio_offset, 
	uint32_t mmio_num, 
	uint64_t mmio_value
) {
	fpga_result res = FPGA_OK;
 	res = fpgaWriteMMIO64(afc_h, mmio_num, mmio_offset, mmio_value);
	return res != FPGA_OK;
}

extern "C"
uint64_t mmioR64 (
	uint64_t mmio_offset, 
	uint32_t mmio_num
) {
	uint64_t val_tmp;
	uint64_t * val_ptr = &val_tmp;
	fpga_result res = FPGA_OK;
 	res = fpgaReadMMIO64(afc_h, mmio_num, mmio_offset, val_ptr);
	if(res != FPGA_OK)
		return 0x7FFFFFFFFFFFFFFF;
	else
		return *val_ptr;
}

extern "C"
bool mmioW32 (
	uint64_t mmio_offset, 
	uint32_t mmio_num, 
	uint32_t mmio_value
) {
	fpga_result res = FPGA_OK;
 	res = fpgaWriteMMIO32(afc_h, mmio_num, mmio_offset, mmio_value);
	return res != FPGA_OK;
}

extern "C"
uint32_t mmioR32 (
	uint64_t mmio_offset, 
	uint32_t mmio_num
) {
	uint32_t val_tmp;
	uint32_t * val_ptr = &val_tmp;
	fpga_result res = FPGA_OK;
 	res = fpgaReadMMIO32(afc_h, mmio_num, mmio_offset, val_ptr);
	if(res != FPGA_OK)
		return 0x7FFFFFFF;
	else
		return *val_ptr;
}