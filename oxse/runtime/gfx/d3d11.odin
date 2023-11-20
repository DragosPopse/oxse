package oxse_app

import "vendor:directx/d3d11"
import d3dc "vendor:directx/d3d_compiler"
import "vendor:directx/dxc"
import "vendor:directx/dxgi"

import "../app"

D3D11_Renderer :: struct {
	device: ^dxgi.IDevice,
	swapchain: ^dxgi.ISwapChain,
	device_context: ^dxgi.IDeviceContext,
}

d3d11_init_renderer :: proc(renderer: ^Renderer) {
	swapchain_info: dxgi.SWAP_CHAIN_DESC
	{
		using swapchain_info
		BufferDesc.RefreshRate.Numerator = 0
		BufferDesc.RefreshRate.Denominator = 1
		BufferDescFormat = .B8G8R8A8_UNORM
		SampleDesc.Count = 1
		SampleDesc.Quality = 0
		BufferUsage = .RENDER_TARGET_OUTPUT
		BufferCount = 1
		OutputWindow = app.app_context.os.hwnd
		Windowed = true
	}
	
	swapchain: ^dxgi.ISwapChain
	device: ^dxgi.IDevice
	device_context: ^d3d11.IDeviceContext

	feature_level: d3d11.FEATURE_LEVEL
	flags: d3d11.CREATE_DEVICE_FLAGS
	flags += {.SINGLETHREADED}
	if ODIN_DEBUG do flags += {.DEBUG, .DEBUGGABLE}
	hr := d3d11.CreateDeviceAndSwapChain(nil, .HARDWARE, nil, flags, nil, 0, d3d11.SDK_VERSION, &swapchain_info, &swapchain, &device, &feature_level, device_context)
	assert(swapchain != nil, "swapchain creation failed")
	assert(device != nil, "device creation failed")
	assert(device_context != nil, "device context creation failed")
	assert(hr == 0, "d3d11.CreateDeviceAndSwapChain failed")

	{
		using renderer
		api_data = new(D3D11_Renderer, context.allocator)
		api_data.device = device
		api_data.swapchain = swapchain
		api_data.device_context = device_context
	}
}