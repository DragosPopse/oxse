# OXSE - Odin Extra Small Engine

The beginning of something cool. Fork of [xxs](https://github.com/enci/xxs), and an evolution of [marshmallow](https:github.com/dragospopse/marshmallow).

## Philosophies
- No dependencies: `oxse:runtime` should contain 0 external C/C++ dependencies, even with `-no-crt`. `oxse:shell` `oxse:build` will only be available on desktops, so dependnecies there are not a big issue
- Handmade: everything that is not available in the `core` odin collection will be written from scratch.
- Small API
- Education: following `xss` path, this engine should be easy to use by designers via a scripting language
- Command Line Engine: `oxse:shell` implements the `oxse` command line utlity to manage your projects easily. 