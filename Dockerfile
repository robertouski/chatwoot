# Utiliza una imagen base oficial de Ruby con la versión que coincide con tu Gemfile
FROM ruby:3.2.2-slim as base

# Set Rails environment to production
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=4k*e&G3WkNYajv6Fp@to2zNn7WJ8sLXEi@vBuRfuVqE77TCx$Ru$AvUB#$wjedCWsPx8sb8Zwrz^oUVAynhaoPRFm7Fo#5iHrPJLncTHzp5yQUS5XXV$QGR%!yo!*!LF

# Instalar dependencias necesarias para la aplicación y la compilación de gemas nativas
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    git \
    curl \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libxslt1-dev \
    imagemagick \
    postgresql-client \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Instalar Yarn
RUN npm install -g yarn

# Configurar el directorio de trabajo en el contenedor
WORKDIR /app

# Copiar el Gemfile y Gemfile.lock
COPY Gemfile Gemfile.lock /app/

# Instalar dependencias de Ruby
RUN bundle install --jobs 20 --retry 5

# Ensure the log directory and files exist
RUN mkdir -p /app/log && touch /app/log/development.log && touch /app/log/production.log

# Set Rails environment to production
ENV RAILS_ENV=production

# Copiar el resto de los archivos del proyecto al directorio de trabajo
COPY . /app

# Precompilar activos de Rails para producción con trace para diagnóstico
RUN bundle exec rake assets:precompile --trace

# Definir el script de entrada y el comando por defecto
ENTRYPOINT ["docker/entrypoints/rails.sh"]
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
