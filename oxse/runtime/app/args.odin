package oxse_app

import "core:unicode"
import "core:unicode/utf8"
import "core:strings"
import "core:runtime"

Flag_Arg :: struct { // -flag:key=val
	flag: string,
	key: string,
	val: string,
}

Arg :: union {
	Flag_Arg,
	string,
}

Args_Error :: enum {
	None,
	Invalid_Format,
}

parse_args :: proc(os_args: []string, allocator := context.allocator) -> (args: []Arg, err: Args_Error) {
	runtime.DEFAULT_TEMP_ALLOCATOR_TEMP_GUARD(ignore = allocator == context.temp_allocator)
	context.allocator = allocator
	args = make([]Arg, len(os_args))
	for os_arg, i in os_args {
		
		if utf8.rune_at_pos(os_arg, 0) == '-' {
			flag_arg: Flag_Arg
			colon_slice := strings.split(os_arg, ":", context.temp_allocator)
			switch len(colon_slice) {
			case 1: // only the flag found, no key-val
				flag_arg.flag = colon_slice[0]
				
			case 2: // key and/or value found
				flag_arg.flag = colon_slice[0]
				equal_slice := strings.split(colon_slice[1], "=", context.temp_allocator)
				switch len(equal_slice) {
				case 1: // only key, no value
					flag_arg.key = equal_slice[0]
				case 2: /// key and value
					flag_arg.key = equal_slice[0]
					flag_arg.val = equal_slice[1]
				}
			
			case: // more than 1 colon found. Invalid syntax
				err = .Invalid_Format
				return
			}
			args[i] = flag_arg
		} else {
			args[i] = os_arg
		}
	}
	return
}