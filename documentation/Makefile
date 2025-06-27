NAME = parcl

SOURCES = $(wildcard *.texi)

INPUTS = $(SOURCES)

.PHONY: all clean

all : $(NAME).info $(NAME).pdf $(NAME).html

$(NAME).info: $(INPUTS) $(FIGURES)
	makeinfo --output $@ $(NAME).texi

$(NAME).pdf: $(INPUTS) $(FIGURES)
	texi2pdf $(NAME).texi

$(NAME).html: $(INPUTS) $(FIGURES) $(wildcard *.css)
	makeinfo --html --no-split --no-headers                                \
                 --css-include=style-common.css --css-include=style-single.css \
                 $(NAME).texi

clean:
	rm -f *.cp *.cps *.fn *.fns                 \
	      *.aux *.log *.toc                     \
	      $(NAME).info $(NAME).pdf $(NAME).html
