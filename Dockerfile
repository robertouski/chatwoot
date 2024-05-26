# Utiliza una imagen base oficial de Ruby con la versión que coincide con tu Gemfile
FROM ruby:3.2.2-slim as base

# Set environment variable to allow older OpenSSL algorithms
ENV NODE_OPTIONS=--openssl-legacy-provider

# Instalar dependencias necesarias para la aplicación y la compilación de gemas nativas
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libxslt1-dev \
    imagemagick \
    postgresql-client \
    git \
    --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Instalación de Node.js y Yarn a la versión específica requerida
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

# Configurar el directorio de trabajo en el contenedor
WORKDIR /app

# Copiar el Gemfile y Gemfile.lock
COPY Gemfile Gemfile.lock /app/

# Instalar dependencias de Ruby
RUN bundle install --jobs 20 --retry 5

# Asegurar que el directorio de logs existe
RUN mkdir -p /app/log && touch /app/log/development.log && touch /app/log/production.log

# Copiar el resto de los archivos del proyecto al directorio de trabajo
COPY . /app

# Instalar dependencias de JavaScript y compilar los activos
RUN yarn install && \
    yarn run webpack --mode production && \
    bundle exec rake assets:precompile --trace

# Definir el script de entrada y el comando por defecto
ENTRYPOINT ["docker/entrypoints/rails.sh"]
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
