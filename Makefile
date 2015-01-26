.PHONY: all clean

all: 
	pdflatex main.tex
	pdflatex main.tex
	pdflatex main.tex

clean:
	rm -f *.aux
	rm -f *.bbl
	rm -f *.blg
	rm -f *.log
	rm -f *.synctex.gz
	rm -f *.out
	rm -f *.toc
	rm -f *.lot
	rm -f *.lof

