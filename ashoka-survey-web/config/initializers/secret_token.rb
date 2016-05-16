# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
#SurveyWeb::Application.config.secret_token = ENV['SECRET_TOKEN']
SurveyWeb::Application.config.secret_token = ENV['SECRET_KEY_BASE']
SurveyWeb::Application.config.secret_key_base = '99ad4929714f3d1327d5faa8c9950cb169b4c85ae1d46cc2a7059c25499aa429d18072e59bf3879a2b67e3dc1bc28c0f0cc9b385bcfe2e62961456be8829715b'
