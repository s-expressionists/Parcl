SBCL ?= sbcl

NAME = parcl

SOURCES = $(wildcard *.texi)

GENERATED = generated-version.texi

INPUTS = $(SOURCES) $(GENERATED)

.PHONY: all clean

all : $(NAME).info $(NAME).pdf $(NAME).html

generated-version.texi: ../data/version-string.sexp
	$(SBCL) --noinform --disable-debugger --no-sysinit --no-userinit                           \
                --eval '(require :asdf)'                                                           \
                --eval '(format t "@macro sysversion~%~A~%@end macro" (uiop:read-file-form "$<"))' \
                --quit                                                                             \
	  > $@

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
	      $(NAME).info $(NAME).pdf $(NAME).html \
	      $(GENERATED)
