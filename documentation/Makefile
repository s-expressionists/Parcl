SBCL ?= sbcl

NAME = parcl

SOURCES = $(wildcard *.texi)

GENERATED = generated-version.texi

INPUTS = $(SOURCES) $(GENERATED)

FIGURES = $(wildcard *.svg)
PDFS    = $(subst .svg,.pdf,$(FIGURES))
IMAGES  = $(subst .svg,.png,$(FIGURES))

.PHONY: all clean

all : $(NAME).info $(NAME).pdf $(NAME).html

%.pdf: %.svg
	rsvg-convert --format=pdf $< > $@

%.png: %.svg
	rsvg-convert --format=png --dpi-x 200 --dpi-y 200 $< > $@

generated-version.texi: ../data/version-string.sexp
	$(SBCL) --noinform --disable-debugger --no-sysinit --no-userinit                           \
                --eval '(require :asdf)'                                                           \
                --eval '(format t "@macro sysversion~%~A~%@end macro" (uiop:read-file-form "$<"))' \
                --quit                                                                             \
	  > $@

$(NAME).info: $(INPUTS) $(IMAGES)
	makeinfo --output $@ $(NAME).texi

$(NAME).pdf: $(INPUTS) $(PDFS)
	texi2pdf $(NAME).texi

$(NAME).html: $(INPUTS) $(IMAGES) $(wildcard *.css)
	makeinfo --html --no-split --no-headers                                \
                 --css-include=style-common.css --css-include=style-single.css \
                 $(NAME).texi

clean:
	echo rm -f *.cp *.cps *.fn *.fns                 \
	      *.aux *.log *.toc                     \
	      $(NAME).info $(NAME).pdf $(NAME).html \
	      $(GENERATED) $(IMAGES) $(PDFS)
