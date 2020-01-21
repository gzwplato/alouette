# Alouette

## Overview.

UCI chess engine able to play Fischer Random Chess.

The program was started as a programming exercise around *bitboards*.

It plays chess at beginner level.

## Opening book.

Since the version 0.1.0, the engine uses an opening book. The book is in the [format described by Kathe Spracklen](https://content.iospress.com/articles/icga-journal/icg6-1-04).

    (e4(e5(d4))(c5))(d4(d5))

This format has been previously used by Marc-Philippe Huget in his engine [La Dame Blanche](http://www.quarkchess.de/ladameblanche/).

## Random mover.

The executable named *random32* (or *random64*) is a random mover. It's *Alouette* compiled with -dRANDOM_MOVER option.

## Author.

Alouette is an open source program written for the Free Pascal Compiler by Roland Chastain.

![alt text](https://raw.githubusercontent.com/rchastain/alouette/master/logo.bmp)
