# libint10h_fonts

This repo contains a bash script which converts the awesome [int10h.org bitmap
font collection](https://int10h.org/oldschool-pc-fonts/) into a library of C
structs which can be directly used in embedded projects.

## Usage:

Either pull individual `.c` and `.h` files into your project as needed,
or run `make` to build all of the fonts as `libint10h_fonts.a`.

## License

The bash script is licensed under [MIT](https://opensource.org/license/mit).

The font files from int10h.org are [licensed](https://int10h.org/oldschool-pc-fonts/readme/#legal_stuff)
under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/),
so all of the generated `.c` and `.h` files are as well.
