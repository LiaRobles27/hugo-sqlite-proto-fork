.PHONY: help index build serve check clean check-invites test migrar maria

help:
	@echo "Comandos disponibles:"
	@echo "  make serve    - Genera índices con borradores y arranca el servidor local"
	@echo "  make build    - Genera índices y compila para producción en public/"
	@echo "  make clean    - Borra los archivos generados"

index:
	python3 tools/index.py

serve:
	python3 tools/index.py --drafts
	hugo server -D

build:
	python3 tools/index.py
	hugo --gc --minify

check: index
	python3 -c "import json, pathlib; [json.loads(pathlib.Path(f).read_text()) for f in ['static/search.json', 'data/tags.json']]; print('JSON OK')"

clean:
	rm -rf build/ static/search.json data/tags.json public/

test:   ## Prueba las funciones puras de tools/migrar.py
	python3 -m unittest discover -s tools -v

migrar:   ## Markdown → SQLite de Chyrp Lite: make migrar DESTINO=/ruta/copia.sqlite [SIMULACRO=1]
	@test -n "$(DESTINO)" || { echo "Uso: make migrar DESTINO=/ruta/copia.sqlite [SIMULACRO=1]"; exit 1; }
	python3 tools/migrar.py --destino "$(DESTINO)" $(if $(SIMULACRO),--simulacro,)

maria:   ## SQLite de Chyrp Lite → SQL para MariaDB: make maria ORIGEN=/ruta/blog.sqlite (escribe build/chyrp.sql)
	@test -n "$(ORIGEN)" || { echo "Uso: make maria ORIGEN=/ruta/blog.sqlite"; exit 1; }
	@mkdir -p build
	python3 tools/sqlite2maria.py --origen "$(ORIGEN)" > build/chyrp.sql
	@echo "build/chyrp.sql listo. Cárgalo con: mariadb -u chyrp -p chyrp < build/chyrp.sql"
