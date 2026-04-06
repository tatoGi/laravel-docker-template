#!/bin/bash
# ─────────────────────────────────────────────────────────────
# Laravel Docker Template — Setup Script
# გამოყენება:
#   bash setup.sh                    # მიმდინარე საქაღალდეში
#   bash setup.sh /path/to/project   # კონკრეტულ პროექტში
# ─────────────────────────────────────────────────────────────

TEMPLATE_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo "Template: $TEMPLATE_DIR"
echo "Target:   $TARGET_DIR"
echo ""

# docker საქაღალდე და docker-compose.yml კოპირება
cp -r "$TEMPLATE_DIR/docker" "$TARGET_DIR/"
cp "$TEMPLATE_DIR/docker-compose.yml" "$TARGET_DIR/"
echo "✓ docker/ and docker-compose.yml copied"

# .env — Docker ცვლადები დაამატე (თუ უკვე არ არის)
ENV_FILE="$TARGET_DIR/.env"
if [ -f "$ENV_FILE" ]; then
  if grep -q "DOCKER_PHP_VERSION" "$ENV_FILE"; then
    echo "✓ .env already has Docker vars — skipped"
  else
    # Docker block-ი ფაილის დასაწყისში ჩასვი
    TMP=$(mktemp)
    cat << 'EOF' > "$TMP"
# ─── Docker ───────────────────────────────────────────────
DOCKER_PHP_VERSION=8.2
DOCKER_MYSQL_VERSION=8.0
DOCKER_HTTP_PORT=8080
DOCKER_MYSQL_PORT=3307
DB_ROOT_PASSWORD=root

EOF
    cat "$TMP" "$ENV_FILE" > "$ENV_FILE.new" && mv "$ENV_FILE.new" "$ENV_FILE"
    rm "$TMP"
    echo "✓ Docker vars added to .env"
  fi
else
  # .env არ არის — .env.example-დან შევქმნათ
  cp "$TEMPLATE_DIR/.env.example" "$ENV_FILE"
  echo "✓ .env created from template"
fi

# .gitignore-ში docker volume folder-ები დაამატე
GITIGNORE="$TARGET_DIR/.gitignore"
if [ -f "$GITIGNORE" ] && ! grep -q "docker/mysql/data" "$GITIGNORE"; then
  echo "" >> "$GITIGNORE"
  echo "# Docker" >> "$GITIGNORE"
  echo "docker/mysql/data/" >> "$GITIGNORE"
  echo "✓ .gitignore updated"
fi

echo ""
echo "─────────────────────────────────────────────"
echo "Next steps:"
echo "  1. .env-ში შეცვალე DB_HOST=mysql"
echo "  2. DOCKER_PHP_VERSION და DOCKER_HTTP_PORT შეცვალე"
echo "  3. docker compose up -d --build"
echo "  4. docker compose exec app composer install"
echo "  5. docker compose exec app php artisan key:generate"
echo "  6. docker compose exec app php artisan migrate"
echo "─────────────────────────────────────────────"
