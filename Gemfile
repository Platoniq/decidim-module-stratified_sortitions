# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = "0.32.3"

gem "decidim", DECIDIM_VERSION
gem "decidim-stratified_sortitions", path: "."

gem "bootsnap", "~> 1.18.6", require: false

# COIN-OR CBC solver for LEXIMIN algorithm (ILP/LP optimization)
gem "puma", ">= 4.3"

gem "chartkick", "~> 5.1.5"
gem "wicked_pdf", "~> 2.8.2"

group :development, :test do
  gem "byebug", ">= 11.1.3"
  gem "decidim-dev", DECIDIM_VERSION
  gem "decidim-initiatives", DECIDIM_VERSION
  gem "rubocop"
  gem "rubocop-rails"
end

group :development do
  gem "faker"
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "web-console", "~> 3.5"
end
