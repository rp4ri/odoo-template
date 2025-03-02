init-project:
	chmod +x entrypoint.sh
	# docker compose down && docker compose up --build -d --force-recreate
	docker compose down && docker compose up --build --force-recreate
down:
	docker compose down
start:
	docker compose up -d