import os
import ctypes
import subprocess
class MUAFUClib():
    '''
    Expose DMA/MMIO C-functions
    as a Python class.
    '''
    def __init__(
        self, 
        clib_dir,
        quiet_comp=False,
        debug_clib=False
    ):
        self.clib_dir=clib_dir
        self.quiet_comp=quiet_comp
        self.debug_clib=debug_clib
        # Compile the c-lib
        self.__compile_clib__()
        # Initialize all the functions
        self.__def_open_afu_handle__()
        self.__def_allocate_buffer__()
        self.__def_dma_host_to_fpga__()
        self.__def_dma_fpga_to_host__()
        self.__def_mmioW64__()
        self.__def_mmioR64__()
        self.__def_mmioW32__()
        self.__def_mmioR32__()
        self.__def_open_dma_handle__()
        self.__def_free_buffer__()
        self.__def_reset_afu__()
        self.__def_close_all__()
        
    def __compile_clib__(self):
        fpga_dma_path = f"{self.clib_dir}/fpga_dma.so"
        mu_c_lib_path = f"{self.clib_dir}/mu_c_lib.so"
        verb="" if self.quiet_comp else "VERBOSE=1"
        debug="FPGA_DMA_DEBUG=1" if self.debug_clib else ""
        p=subprocess.Popen([f'make -C {self.clib_dir} clean'], 
                             stdout=subprocess.PIPE, shell=True)
        result, err=p.communicate()
        p=subprocess.Popen([f'make -C {self.clib_dir} {verb} {debug}'], 
                             stdout=subprocess.PIPE, shell=True)
        result, err=p.communicate()
        assert(os.path.exists(fpga_dma_path))
        assert(os.path.exists(mu_c_lib_path))
        ctypes.CDLL(fpga_dma_path, mode=ctypes.RTLD_GLOBAL)
        self.mu_c_lib=ctypes.CDLL(mu_c_lib_path)
    
    def __def_open_afu_handle__(self):
        self.mu_c_lib.open_afu_handle.restype = ctypes.c_bool
        self.mu_c_lib.open_afu_handle.argtypes = [
            ctypes.c_char_p  # UUID
        ]
    
    def open_afu_handle(self, uuid=""):
        '''
        Generates handle to AFU for exclusive use
        '''
        if(self.mu_c_lib.open_afu_handle(uuid.upper())):
            raise RuntimeError(
                "Could not obtain AFU handle!"
            )
    
    def __def_allocate_buffer__(self):
        self.mu_c_lib.allocate_buffer.restype = ctypes.c_bool
        self.mu_c_lib.allocate_buffer.argtypes = [
            ctypes.c_uint64 # BUFFER SIZE BYTES
        ]
        
    def allocate_shared_buffer(self, n_bytes):
        '''
        Allocate an n_bytes size shared buffer between the FPGA and host
        '''
        self.buffer_size = n_bytes
        if(self.mu_c_lib.allocate_buffer(n_bytes)):
            self.mu_c_lib.close_all()
            raise RuntimeError(
                "Couldn't initialize a shared buffer."
            )
        
    def __def_dma_host_to_fpga__(self):
        self.mu_c_lib.dma_host_to_fpga.restype = ctypes.c_bool
        self.mu_c_lib.dma_host_to_fpga.argtypes = [
            ctypes.c_uint64, # FPGA ADDRESS to TRANSFER BUFFER TO
            ctypes.c_uint64, # N_BYTES
            ctypes.c_uint64  # CHUNK SIZE
        ]
        
    def dma_host_to_fpga(self, fpga_addr, span, payload_size):
        '''
        Transacts data from host buffer to FPGA.
        Data will be populated from fpga_addr to fpga_addr+span
        in payload_size chunks.
        '''
        if(self.mu_c_lib.dma_host_to_fpga(fpga_addr, span, payload_size)):
            self.mu_c_lib.close_all()
            raise RuntimeError(
                "DMA transfer to FPGA failed!"
            )
        
    def __def_dma_fpga_to_host__(self):
        self.mu_c_lib.dma_fpga_to_host.restype = ctypes.c_bool
        self.mu_c_lib.dma_fpga_to_host.argtypes = [
            ctypes.c_uint64, # FPGA ADDRESS to TRANSFER BUFFER FROM
            ctypes.c_uint64, # N_BYTES
            ctypes.c_uint64  # CHUNK SIZE
        ]
        
    def dma_fpga_to_host(self, fpga_addr, span, payload_size):
        '''
        Transacts data from the FPGA to the host buffer.
        Data will be populated from fpga_addr to fpga_addr+span
        in payload_size chunks.
        '''
        if(self.mu_c_lib.dma_fpga_to_host(fpga_addr, span, payload_size)):
            self.mu_c_lib.close_all()
            raise RuntimeError(
                "DMA transfer from FPGA failed!"
            )
            
    def __def_mmioW64__(self):
        self.mu_c_lib.mmioW64.restype = ctypes.c_bool
        self.mu_c_lib.mmioW64.argtypes = [
            ctypes.c_uint64, # MMIO Offset
            ctypes.c_uint32, # MMIO Num/IDX
            ctypes.c_uint64  # MMIO Data
        ]
        
    def mmioW64(self, mmio_offset, mmio_group, data):
        '''
        Write 64-bit data via MMIO mmio_offset into group mmio_group
        '''
        if(self.mu_c_lib.mmioW64(mmio_offset, mmio_group, data)):
            self.mu_c_lib.close_all()
            raise RuntimeError(
                "MMIO64 write failed!"
            )
            
    def __def_mmioR64__(self):
        self.mu_c_lib.mmioR64.restype = ctypes.c_uint64
        self.mu_c_lib.mmioR64.argtypes = [
            ctypes.c_uint64, # MMIO Offset
            ctypes.c_uint32, # MMIO Num/IDX
        ]
        
    def mmioR64(self, mmio_offset, mmio_group):
        '''
        Read 32-bit data via MMIO from mmio_offset into group mmio_group
        '''
        return self.mu_c_lib.mmioR64(mmio_offset, mmio_group)
    
    
    def __def_mmioW32__(self):
        self.mu_c_lib.mmioW32.restype = ctypes.c_bool
        self.mu_c_lib.mmioW32.argtypes = [
            ctypes.c_uint64, # MMIO Offset
            ctypes.c_uint32, # MMIO Num/IDX
            ctypes.c_uint32  # MMIO Data
        ]
        
    def mmioW32(self, mmio_offset, mmio_group, data):
        '''
        Write 32-bit data via MMIO mmio_offset into group mmio_group
        '''
        if(self.mu_c_lib.mmioW32(mmio_offset, mmio_group, data)):
            self.mu_c_lib.close_all()
            raise RuntimeError(
                "MMIO32 write failed!"
            )
            
    def __def_mmioR32__(self):
        self.mu_c_lib.mmioR32.restype = ctypes.c_uint32
        self.mu_c_lib.mmioR32.argtypes = [
            ctypes.c_uint64, # MMIO Offset
            ctypes.c_uint32, # MMIO Num/IDX
        ]
        
    def mmioR32(self, mmio_offset, mmio_group):
        '''
        Read 32-bit data via MMIO from mmio_offset into group mmio_group
        on error will only return 0x7FFFFFFF.
        '''
        return self.mu_c_lib.mmioR32(mmio_offset, mmio_group)
    
    def __def_open_dma_handle__(self):
        self.mu_c_lib.open_dma_handle.restype = ctypes.c_bool
        
    def open_dma_handle(self):
        '''
        Open exclusive handle to platform DMA
        '''
        if (self.mu_c_lib.open_dma_handle()):
            self.mu_c_lib.close_all()
            raise RuntimeError(
                "Failed to obtain DMA handle!"
            )
    
    def __def_free_buffer__(self):
        self.mu_c_lib.free_buffer.restype = ctypes.c_bool
        
    def free_buffer(self):
        '''
        Releases shared buffer between host and FPGA
        '''
        if(self.mu_c_lib.free_buffer()):
            self.mu_c_lib.close_all()
            raise RuntimeError(
                "Failed to free buffer!"
            )
    
    def __def_populate_buffer_bytes__(self):
        self.mu_c_lib.populate_buffer_bytes.restype = ctypes.c_bool
        self.mu_c_lib.populate_buffer_bytes.argtypes = [
            ctype.c_char_p,  # Pointer to py buffer
            ctypes.c_uint64, # MMIO Offset
        ]
    
    def populate_buffer_bytes(self, src_buff_ptr, n_bytes):
        self.mu_c_lib.populate_buffer_bytes(src_buff_ptr, n_bytes)
        
    def __def_get_buffer_bytes__(self):
        self.mu_c_lib.get_buffer_bytes.argtypes = [
            ctype.c_char_p,  # Pointer to py buffer
            ctypes.c_uint64, # MMIO Offset
        ]
    
    def get_buffer_bytes(self, dst_buff_ptr, n_bytes):
        self.mu_c_lib.get_buffer_bytes(dst_buff_ptr, n_bytes)
    
    def __def_reset_afu__(self):
        self.mu_c_lib.reset_afu.restype = ctypes.c_bool
        
    def reset_afu(self):
        if(self.mu_c_lib.reset_afu()):
            self.mu_c_lib.close_all()
            raise RuntimeError(
                "Failed to reset AFU!"
            )
            
    def __def_close_all__(self):
        self.mu_c_lib.close_all.restype = ctypes.c_bool
        
    def close_all(self):
        if(self.mu_c_lib.close_all()):
            self.mu_c_lib.close_all()
            raise RuntimeError(
                "Failed to close all FPGA resources!"
            )